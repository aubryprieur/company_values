# app/controllers/admin/company_values_controller.rb
class Admin::CompanyValuesController < Admin::BaseController
  before_action :set_company_value, only: [:edit, :update, :destroy]
  before_action :set_categories, only: [:new, :create, :edit, :update]

  def index
    @company_values = CompanyValue.all
  end

  def new
    @company_value = CompanyValue.new
  end

  def create
    @company_value = CompanyValue.new(company_value_params)
    if @company_value.save
      redirect_to admin_company_values_path, notice: 'Valeur créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company_value.update(company_value_params)
      redirect_to admin_company_values_path, notice: 'Valeur mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @company_value.responses.any?
      redirect_to admin_company_values_path, alert: "Cette valeur ne peut pas être supprimée car elle a déjà des réponses associées."
    else
      @company_value.destroy
      redirect_to admin_company_values_path, notice: 'Valeur supprimée avec succès.'
    end
  end

  private

  def set_company_value
    @company_value = CompanyValue.find(params[:id])
  end

  def set_categories
    @categories = ValueCategory.all
  end

  def company_value_params
    params.require(:company_value).permit(:name, :description, :value_category_id)
  end
end
