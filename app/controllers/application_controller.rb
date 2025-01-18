class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern

  def pundit_user
    current_company || current_employee
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Company)
      surveys_path
    else
      employee_surveys_path # Nous allons créer cette route
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :organization_type])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :company_id]) # Pour Employee
  end

end
