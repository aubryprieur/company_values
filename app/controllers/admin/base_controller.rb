class Admin::BaseController < ApplicationController
  before_action :authenticate_company!
  before_action :ensure_super_admin!

  private

  def ensure_super_admin!
    unless current_company&.super_admin?
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
end
