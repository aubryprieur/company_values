class Admin::DashboardController < Admin::BaseController
  def index
    @companies = Company.where.not(role: 'super_admin')
    @employees_count = Employee.count
    @surveys_count = Survey.count
    @responses_count = Response.count
  end
end
