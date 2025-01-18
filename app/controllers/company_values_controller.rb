class CompanyValuesController < ApplicationController
  before_action :authenticate_company!, except: [:index, :show]
  before_action :set_survey
  before_action :set_company_value, only: [:show, :edit, :update, :destroy]

  def index
    @company_values = @survey.company_values
  end

  def new
    @company_value = @survey.company_values.build
  end

  def create
    @company_value = @survey.company_values.build(company_value_params)

    if @company_value.save
      redirect_to survey_company_value_path(@survey, @company_value),
                  notice: 'Valeur ajoutée avec succès.'
    else
      render :new
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_company_value
    @company_value = @survey.company_values.find(params[:id])
  end

  def company_value_params
    params.require(:company_value).permit(:name, :description)
  end
end
