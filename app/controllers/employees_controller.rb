class EmployeesController < ApplicationController
  before_action :authenticate_company!, only: [:activate, :set_password]
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :reinvite]

  def index
    @employees = current_company.employees
  end

  def show
    @responses = @employee.responses.includes(company_value: :survey)
    @surveys_participated = @employee.responses.map(&:company_value).map(&:survey).uniq
    @participation_rate = calculate_participation_rate(@employee)
  end

  def new
    @employee = current_company.employees.build
  end

  def create
    @employee = current_company.employees.build(employee_params)
    generated_password = SecureRandom.hex(8)
    @employee.password = generated_password
    @employee.password_confirmation = generated_password
    @employee.generate_invitation_token

    if @employee.save
      EmployeeMailer.with(employee: @employee).invitation_email.deliver_later
      redirect_to employees_path, notice: 'Invitation envoyée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "L'employé a été supprimé avec succès."
  end

  def reinvite
    @employee.generate_invitation_token
    @employee.save
    EmployeeMailer.with(employee: @employee).invitation_email.deliver_later
    redirect_to employees_path, notice: 'Invitation renvoyée avec succès.'
  end

  def activate
    @employee = Employee.find_by(invitation_token: params[:token])

    if @employee.nil?
      redirect_to root_path, alert: "Token d'invitation invalide."
    elsif @employee.invitation_accepted?
      redirect_to new_employee_session_path, alert: 'Ce compte a déjà été activé.'
    elsif @employee.invitation_expired?
      redirect_to root_path, alert: "Le lien d'invitation a expiré."
    end
  end

  def set_password
    @employee = Employee.find_by(invitation_token: params[:token])

    if @employee&.update(password_params)
      @employee.accept_invitation!
      redirect_to new_employee_session_path, notice: 'Votre compte a été activé. Vous pouvez maintenant vous connecter.'
    else
      render :activate, status: :unprocessable_entity
    end
  end

  def import
    if params[:file].blank?
      redirect_to employees_path, alert: "Veuillez sélectionner un fichier à importer."
      return
    end

    unless File.extname(params[:file].original_filename) == ".xlsx"
      redirect_to employees_path, alert: "Le fichier doit être au format .xlsx"
      return
    end

    begin
      imported_count = 0
      existing_count = 0
      file = params[:file]
      spreadsheet = Roo::Spreadsheet.open(file)
      header = spreadsheet.row(1)

      # Vérification des colonnes requises
      required_columns = ["Prénom", "Nom", "Email"]
      missing_columns = required_columns - header

      if missing_columns.any?
        redirect_to employees_path, alert: "Colonnes manquantes : #{missing_columns.join(', ')}"
        return
      end

      # Import des employés
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        # Vérifier si l'email existe déjà
        if Employee.exists?(email: row['Email'])
          existing_count += 1
          next
        end

        generated_password = SecureRandom.hex(8)
        employee = current_company.employees.build(
          first_name: row['Prénom'],
          last_name: row['Nom'],
          email: row['Email'],
          password: generated_password,
          password_confirmation: generated_password
        )

        if employee.save
          imported_count += 1
          employee.generate_invitation_token
          EmployeeMailer.with(employee: employee).invitation_email.deliver_later
        end
      end

      if imported_count > 0
        message = "#{imported_count} employé(s) importé(s) avec succès"
        message += ", #{existing_count} déjà existant(s)" if existing_count > 0
        redirect_to employees_path, notice: message
      else
        redirect_to employees_path, flash: { warning: "0 employé importé, #{existing_count} déjà existant(s)" }
      end

    rescue StandardError => e
      redirect_to employees_path, alert: "Une erreur est survenue lors de l'import : #{e.message}"
    end
  end

  def download_template
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="modele_import_employes.xlsx"'
        workbook = RubyXL::Workbook.new
        worksheet = workbook[0]

        # Ajouter les en-têtes
        worksheet.add_cell(0, 0, "Prénom")
        worksheet.add_cell(0, 1, "Nom")
        worksheet.add_cell(0, 2, "Email")

        # Exemple de ligne
        worksheet.add_cell(1, 0, "Jean")
        worksheet.add_cell(1, 1, "Dupont")
        worksheet.add_cell(1, 2, "jean.dupont@exemple.com")

        send_data workbook.stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      }
    end
  end

  private

  def set_employee
    @employee = current_company.employees.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:email, :first_name, :last_name)
  end

  def password_params
    params.require(:employee).permit(:password, :password_confirmation)
  end

  def calculate_participation_rate(employee)
    total_values = employee.company.surveys.sum { |survey| survey.company_values.count }
    return 0 if total_values.zero?
    (employee.responses.count.to_f / total_values * 100).round(2)
  end

end
