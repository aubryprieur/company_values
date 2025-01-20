class Employee::SurveysController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_survey, only: [:show, :results, :qvt_results, :complete, :answer_theme]
  before_action :check_survey_completion, only: [:show]
  before_action :set_themes, only: [:show, :answer_theme]

  def index
    @surveys = Survey.joins(:survey_participants)
                    .where(survey_participants: { employee: current_employee })
                    .where('end_date > ?', Time.current)
  end

  def show
    @survey = Survey.find(params[:id])

    unless current_employee.invited_to_survey?(@survey)
      redirect_to employee_surveys_path,
        alert: "Vous n'avez pas été invité à participer à ce sondage."
      return
    end

    authorize @survey

    if @survey.company_values?
      show_company_values
    else
      redirect_to answer_theme_employee_survey_path(@survey, theme_id: QvtTheme.first.id)
    end
  end

  def results
    if @survey.company_values?
      show_values_results
    else
      redirect_to qvt_results_employee_survey_path(@survey)
    end
  end

  def qvt_results
    authorize @survey
    @themes = QvtTheme.includes(qvt_questions: :qvt_choices)
    @responses = current_employee.qvt_responses
                               .where(survey: @survey)
                               .includes(:qvt_choices)
                               .index_by(&:qvt_question_id)

    @theme_stats = @themes.map do |theme|
      {
        theme: theme,
        completion_rate: calculate_theme_completion(theme, @responses),
        questions: prepare_questions_data(theme.qvt_questions, @responses)
      }
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "resultats_qvt_#{@survey.title}",
               template: 'employee/surveys/qvt_results',
               layout: 'pdf',
               orientation: 'Portrait'
      end
    end
  end

  def complete
    if @survey.company_values?
      complete_values_survey
    else
      complete_qvt_survey
    end
  end

  def answer_theme
    authorize @survey
    @theme = QvtTheme.find(params[:theme_id])
    @current_theme_index = @themes.index(@theme)
    @next_theme = @themes[@current_theme_index + 1]
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def set_themes
    @themes = QvtTheme.all.order(:id)
  end

  def check_survey_completion
    return unless @survey.company_values? # Ne vérifie que pour les sondages de valeurs

    # Vérifier d'abord si l'employé est invité
    return unless current_employee.invited_to_survey?(@survey)

    if @survey.completed_by?(current_employee)
      redirect_to results_employee_survey_path(@survey),
                  notice: "Vous avez déjà complété ce sondage. Voici vos résultats."
    end
  end

  def show_company_values
    @company_values = @survey.company_values
                            .includes(:value_category)
                            .joins(:value_category)
                            .order('value_categories.name')
    @responses = current_employee.responses.where(company_value: @company_values)
    @grouped_values = @company_values.group_by(&:value_category)

    # Moyennes personnelles
    @category_averages = @survey.company_values
      .joins(:value_category, :responses)
      .where(responses: { employee: current_employee })
      .group('value_categories.name')
      .average('responses.rating')
      .transform_values { |v| v.to_f.round(2) }

    # Moyennes de l'entreprise
    @company_averages = @survey.company_values
      .joins(:value_category, :responses)
      .where(responses: { employee_id: @survey.company.employees.select(:id) })
      .group('value_categories.name')
      .average('responses.rating')
      .transform_values { |v| v.to_f.round(2) }

    @last_answered_category = @responses.joins(:company_value => :value_category)
                                      .order('responses.created_at DESC')
                                      .first&.company_value&.value_category

    @start_category = if @last_answered_category
                       ValueCategory.find(@last_answered_category.id)
                     else
                       @grouped_values.keys.first
                     end

    render :show_values
  end

  def show_qvt
    @themes = QvtTheme.includes(qvt_questions: :qvt_choices)
    render :show_qvt
  end

  def show_values_results
    @company_values = @survey.company_values
    @responses = current_employee.responses.where(company_value: @company_values)

    @value_stats = @company_values.map do |value|
      all_ratings = value.responses.pluck(:rating)
      {
        value: value,
        average_rating: all_ratings.present? ? (all_ratings.sum.to_f / all_ratings.length) : 0,
        total_responses: all_ratings.length,
        employee_rating: @responses.find_by(company_value: value)&.rating
      }
    end

    @category_averages = @survey.company_values
      .joins(:value_category, :responses)
      .where(responses: { employee: current_employee })
      .group('value_categories.name')
      .average('responses.rating')
      .transform_values { |v| v.to_f.round(2) }

    @category_averages ||= {}

    respond_to do |format|
      format.html { render :results }
      format.pdf do
        render pdf: "resultats_#{@survey.title}",
               template: 'employee/surveys/results',
               layout: 'pdf',
               javascript_delay: 2000,
               orientation: 'Portrait'
      end
    end
  end

  def complete_values_survey
    all_values = @survey.company_values.pluck(:id).sort
    answered_values = current_employee.responses
                                    .where(company_value_id: all_values)
                                    .pluck(:company_value_id)
                                    .sort

    if all_values == answered_values
      Response.transaction do
        current_employee.responses
                       .where(company_value_id: all_values)
                       .update_all(completed_at: Time.current)

        redirect_to results_employee_survey_path(@survey),
                    notice: 'Sondage terminé avec succès. Vos réponses sont maintenant verrouillées.'
      end
    else
      redirect_to employee_survey_path(@survey),
                  alert: 'Veuillez répondre à toutes les questions avant de terminer le sondage.'
    end
  end

  def complete_qvt_survey
    questions_count = QvtQuestion.count
    answered_count = current_employee.qvt_responses
                                   .where(survey: @survey)
                                   .count

    if questions_count == answered_count
      current_employee.qvt_responses
                     .where(survey: @survey)
                     .update_all(completed_at: Time.current)

      redirect_to qvt_results_employee_survey_path(@survey),
                  notice: 'Questionnaire QVT terminé avec succès.'
    else
      redirect_to employee_survey_path(@survey),
                  alert: 'Veuillez répondre à toutes les questions avant de terminer le questionnaire.'
    end
  end

  def calculate_theme_completion(theme, responses)
    total_questions = theme.qvt_questions.count
    answered_questions = responses.count { |_, response|
      theme.qvt_questions.pluck(:id).include?(response.qvt_question_id)
    }

    return 0 if total_questions.zero?
    (answered_questions.to_f / total_questions * 100).round(1)
  end

  def prepare_questions_data(questions, responses)
    questions.map do |question|
      response = responses[question.id]

      {
        question: question,
        response: format_response(question, response),
        answered: response.present?
      }
    end
  end

  def format_response(question, response)
    return nil unless response

    case question.question_type
    when 'single_choice', 'multiple_choice'
      response.qvt_choices.map(&:content).join(", ")
    when 'ranking'
      response.qvt_response_choices
             .order(:position) # Laissons la position telle quelle en base 0
             .map { |rc| "#{rc.position + 1}. #{rc.qvt_choice.content}" } # Ajoutons +1 uniquement pour l'affichage
             .join("\n")
    when 'open'
      response.text_answer
    end
  end
end
