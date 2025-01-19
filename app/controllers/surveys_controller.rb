class SurveysController < ApplicationController
  before_action :authenticate_company!
  before_action :set_survey, only: [:show, :edit, :update, :destroy, :rankings]

  def index
    @surveys = current_company.surveys.order(created_at: :desc)
  end

  def show
    @survey = current_company.surveys.find(params[:id])
    @company_values = @survey.company_values.includes(:value_category, :responses) if @survey.company_values?
    respond_to do |format|
      format.html
      format.pdf do
        render template: "surveys/show",
               pdf: "resultats_#{@survey.title}",
               layout: "layouts/pdf",
               formats: [:pdf, :html],
               disposition: 'attachment'
      end
    end
  end

  def new
    @survey = current_company.surveys.build(survey_type: params[:type])
    @available_values = CompanyValue.all if params[:type] == 'company_values'
  end

  def create
    @survey = current_company.surveys.build(survey_params)
    if @survey.save
      redirect_to @survey, notice: 'Sondage créé avec succès.'
    else
      @available_values = CompanyValue.all if @survey.company_values?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @survey.update(survey_params)
      redirect_to @survey, notice: 'Sondage mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def send_reminders
    @survey = current_company.surveys.find(params[:id])
    # Trouver les employés actifs qui n'ont pas répondu
    non_respondent_employees = current_company.employees
      .where.not(invitation_accepted_at: nil) # employés actifs
      .where.not(
        id: Response.joins(company_value: :surveys)
            .where(surveys: { id: @survey.id })
            .select('DISTINCT employee_id')
      )

    # Envoyer les emails
    count = 0
    non_respondent_employees.each do |employee|
      SurveyMailer.reminder_email(employee, @survey).deliver_later
      count += 1
    end

    redirect_to employees_path,
                notice: "#{count} rappels envoyés avec succès."
  end

  def custom_values
    @survey = Survey.find(params[:id])
    @sort_column = params[:sort] || 'created_at'
    @sort_direction = params[:direction] || 'desc'
    @custom_values = CustomValue.where(survey: @survey)
                              .includes(:employee)
                              .order(@sort_column => @sort_direction)
  end

  def download_custom_values
    @survey = Survey.find(params[:id])
    @custom_values = CustomValue.where(survey: @survey).order(:name)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=nouvelles_valeurs_#{@survey.title.parameterize}.xlsx"
      }
    end
  end

  def results
    @survey = current_company.surveys.find(params[:id])
    @company_values = @survey.company_values.includes(:value_category, :responses)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "resultats_#{@survey.title}",
               template: "surveys/results",
               layout: "layouts/pdf",
               formats: [:pdf, :html],
               disposition: 'attachment'
      end
    end
  end

  def qvt_results
    @survey = current_company.surveys.find(params[:id])
    @themes = QvtTheme.includes(qvt_questions: [:qvt_choices, qvt_responses: :qvt_choices])
    @total_employees = current_company.employees.count
    @responding_employees = @survey.qvt_responses.select('DISTINCT employee_id').count

    @theme_stats = @themes.map do |theme|
      {
        theme: theme,
        questions: theme.qvt_questions.map do |question|
          {
            question: question,
            stats: calculate_qvt_question_stats(question, @survey)
          }
        end
      }
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "resultats_qvt_#{@survey.title}",
               template: "surveys/qvt_results",
               layout: "layouts/pdf",
               orientation: 'Portrait',
               page_size: 'A4',
               margin: { top: 15, bottom: 15, left: 15, right: 15 },
               footer: { right: '[page] sur [topage]' }
      end
    end
  end

  private

  def set_survey
    @survey = current_company.surveys.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:title, :end_date, :survey_type)
  end

  def get_available_survey_types
    types = []
    types << ['Sondage Valeurs', 'company_values'] unless current_company.surveys.company_values.exists?
    types << ['Sondage QVT', 'qvt'] unless current_company.surveys.qvt.exists?
    types
  end

  def calculate_response_stats(value)
    responses = value.responses.where(employee: current_company.employees)
    return nil if responses.empty?

    {
      average_rating: responses.average(:rating)&.round(2),
      total_responses: responses.count,
      distribution: calculate_rating_distribution(responses),
      sentiment: calculate_sentiment(responses)
    }
  end

  def calculate_rating_distribution(responses)
    distribution = responses.group(:rating).count
    (1..10).map { |rating| distribution[rating] || 0 }
  end

  def calculate_sentiment(responses)
    avg = responses.average(:rating).to_f
    case avg
    when 0..4
      'negative'
    when 4..7
      'neutral'
    else
      'positive'
    end
  end

  def calculate_qvt_question_stats(question, survey)
    case question.question_type
    when 'single_choice', 'multiple_choice'
      responses = question.qvt_responses.where(survey: survey)
      total_responses = responses.count.to_f

      question.qvt_choices.map do |choice|
        choice_count = QvtResponseChoice.joins(:qvt_response)
          .where(qvt_responses: { survey: survey, qvt_question: question })
          .where(qvt_choice: choice)
          .count

        {
          label: choice.content,
          value: total_responses > 0 ? (choice_count / total_responses * 100).round(1) : 0,
          count: choice_count
        }
      end
    when 'open'
      question.qvt_responses
             .where(survey: survey)
             .where.not(text_answer: nil)
             .where.not(text_answer: '')
             .pluck(:text_answer)
    end
  end
end
