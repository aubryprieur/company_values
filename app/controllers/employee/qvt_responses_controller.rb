class Employee::QvtResponsesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_survey
  before_action :check_survey_completion, only: [:create, :update, :submit_page]

  def create
    @response = current_employee.qvt_responses.build(qvt_response_params)
    @response.survey = @survey

    if @response.save
      render json: { success: true }
    else
      render json: { success: false, errors: @response.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    @response = current_employee.qvt_responses.find_by(
      survey: @survey,
      qvt_question_id: qvt_response_params[:qvt_question_id]
    )

    if @response.update(qvt_response_params)
      render json: { success: true }
    else
      render json: { success: false, errors: @response.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def submit_page
    return render json: { success: false, error: "Thème manquant" }, status: :unprocessable_entity unless params[:theme_id].present?

    @theme = QvtTheme.find_by(id: params[:theme_id])
    return render json: { success: false, error: "Thème non trouvé" }, status: :unprocessable_entity unless @theme

    begin
      ActiveRecord::Base.transaction do
        params[:responses].each do |response_params|
          response = current_employee.qvt_responses.find_or_initialize_by(
            survey: @survey,
            qvt_question_id: response_params[:qvt_question_id]
          )

          case response_params[:question_type]
          when 'single_choice', 'multiple_choice'
            handle_choice_response(response, response_params)
          when 'ranking'
            handle_ranking_response(response, response_params)
          when 'open'
            handle_open_response(response, response_params)
          end
        end
      end

      # Trouver la thématique suivante s'il y en a une
      current_theme_index = QvtTheme.all.order(:id).index(@theme)
      next_theme = QvtTheme.all.order(:id)[current_theme_index + 1] if current_theme_index

      # Rendu du status avec le bon format
      theme_status = render_to_string(
        partial: 'employee/surveys/theme_status',
        formats: [:html],
        locals: { theme: @theme, survey: @survey }
      )

      render json: {
        success: true,
        theme_status_html: theme_status,
        theme_completed: @theme.completion_status(@survey, current_employee) == :completed,
        next_theme_id: next_theme&.id
      }
    rescue => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def check_survey_completion
    if @survey.completed_qvt_by?(current_employee)
      render json: {
        success: false,
        error: 'Ce sondage a déjà été complété'
      }, status: :unprocessable_entity
    end
  end

  def qvt_response_params
    params.require(:qvt_response).permit(
      :qvt_question_id,
      :text_answer,
      qvt_response_choices_attributes: [:qvt_choice_id, :position]
    )
  end

  def handle_choice_response(response, params)
    response.qvt_response_choices.destroy_all
    choice_ids = Array(params[:choice_ids])

    choice_ids.each do |choice_id|
      response.qvt_response_choices.build(qvt_choice_id: choice_id)
    end

    response.save!
  end

  def handle_ranking_response(response, params)
    return unless params[:rankings].present?

    # S'assurer que la réponse est sauvegardée avant d'ajouter les choix
    response.save! if response.new_record?

    # Supprimer les anciens choix si la réponse existe déjà
    response.qvt_response_choices.destroy_all

    # Trier les rankings par position avant de les créer
    sorted_rankings = params[:rankings].sort_by { |ranking| ranking[:position].to_i }

    # Créer les nouveaux choix en utilisant la position envoyée
    sorted_rankings.each do |ranking|
      response.qvt_response_choices.create!(
        qvt_choice_id: ranking[:choice_id],
        position: ranking[:position] # Utiliser la position envoyée au lieu de l'index
      )
    end
  end

  def handle_open_response(response, params)
    response.text_answer = params[:text_answer]
    response.save!
  end
end
