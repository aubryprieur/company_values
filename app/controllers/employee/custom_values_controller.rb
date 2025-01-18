class Employee::CustomValuesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_survey
  before_action :check_survey_completion

  def new
    @existing_values = current_employee.custom_values.where(survey: @survey)
    @remaining_slots = 3 - @existing_values.count
  end

  def create
    submitted_values = params[:custom_values].to_unsafe_h.values.reject { |v| v[:name].blank? }

    if submitted_values.any?
      custom_values = submitted_values.map do |value_params|
        current_employee.custom_values.build(
          name: value_params[:name].capitalize,
          description: value_params[:description].capitalize,
          survey: @survey
        )
      end

      if custom_values.all?(&:valid?) && custom_values.all?(&:save)
        redirect_to employee_surveys_path, notice: 'Vos propositions ont été enregistrées.'
      else
        flash.now[:alert] = 'Erreur lors de l\'enregistrement des valeurs.'
        render :new
      end
    else
      redirect_to employee_surveys_path, alert: 'Veuillez proposer au moins une valeur.'
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def check_survey_completion
    unless @survey.completed_by?(current_employee)
      redirect_to employee_survey_path(@survey), alert: 'Complétez d\'abord le sondage sur les valeurs.'
    end
  end

  def custom_value_params
    params.require(:custom_value).permit(:name, :description)
  end
end
