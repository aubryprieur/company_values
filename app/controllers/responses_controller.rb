class ResponsesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_company_value
  before_action :check_survey_status

  def create
    @response = current_employee.responses.build(response_params)
    @response.company_value = @company_value

    if @response.save
      redirect_to @company_value.survey, notice: 'Réponse enregistrée.'
    else
      redirect_to @company_value.survey, alert: 'Erreur lors de l\'enregistrement.'
    end
  end

  def update
    @response = current_employee.responses.find(params[:id])
    if @response.update(response_params)
      redirect_to @company_value.survey, notice: 'Réponse mise à jour.'
    else
      redirect_to @company_value.survey, alert: 'Erreur lors de la mise à jour.'
    end
  end

  private

  def set_company_value
    @company_value = CompanyValue.find(params[:company_value_id])
  end

  def check_survey_status
    if @company_value.survey.closed?
      redirect_to @company_value.survey, alert: 'Le sondage est terminé.'
    end
  end

  def response_params
    params.require(:response).permit(:rating, :comment)
  end
end
