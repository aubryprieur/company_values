class Employee::ResponsesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :update]
  before_action :authenticate_employee!
  before_action :set_survey
  before_action :set_company_value
  before_action :check_response_modifiable, only: [:create, :update]

  def create
    @response = current_employee.responses.find_or_initialize_by(company_value: @company_value)
    @response.rating = params[:rating]

    if @response.save
      handle_response_success
    else
      render json: { success: false, errors: @response.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    @response = current_employee.responses.find_by(company_value: @company_value)
    if @response.update(rating: params[:rating])
      handle_response_success
    else
      render json: { success: false, errors: @response.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_company_value
    @company_value = CompanyValue.find(params[:company_value_id])
  end

  def handle_response_success
    render json: { success: true }
  end

  def check_response_modifiable
    existing_response = current_employee.responses
                                      .find_by(company_value: @company_value)
    if existing_response&.completed?
      render json: {
        success: false,
        errors: ['Ce sondage a été finalisé et ne peut plus être modifié']
      }, status: :unprocessable_entity
    end
  end
end
