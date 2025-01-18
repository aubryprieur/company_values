class Admin::CompaniesController < Admin::BaseController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.where.not(role: 'super_admin')
  end

  def show
    @employees = @company.employees
    @surveys = @company.surveys
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to admin_company_path(@company), notice: 'Entreprise mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_dashboard_path, notice: 'Entreprise supprimée avec succès.'
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :email)
  end
end
