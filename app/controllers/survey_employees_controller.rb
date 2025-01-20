# app/controllers/survey_employees_controller.rb
class SurveyEmployeesController < ApplicationController
  before_action :set_survey

  def index
    @participants = @survey.survey_participants.includes(:employee)
    @available_employees = current_company.employees.where.not(id: @survey.employees)
  end

  def new
    @employee = current_company.employees.build
  end

  def create
    # Chercher d'abord si l'employé existe déjà
    @employee = current_company.employees.find_by(email: employee_params[:email])

    if @employee
      # Si l'employé existe déjà, vérifie s'il est déjà invité à ce sondage
      if @employee.invited_to_survey?(@survey)
        redirect_to survey_survey_employees_path(@survey),
          alert: "Cet employé est déjà invité à ce sondage."
        return
      end

      # Ajoute l'employé existant au sondage
      @survey.survey_participants.create!(employee: @employee, invited_at: Time.current)
      EmployeeMailer.with(employee: @employee, survey: @survey).survey_invitation_email.deliver_later
      redirect_to survey_survey_employees_path(@survey),
        notice: 'Invitation envoyée avec succès.'
    else
      # Créer un nouvel employé si l'email n'existe pas
      @employee = current_company.employees.build(employee_params)
      generated_password = SecureRandom.hex(8)
      @employee.password = generated_password
      @employee.password_confirmation = generated_password
      @employee.generate_invitation_token

      if @employee.save
        @survey.survey_participants.create!(employee: @employee, invited_at: Time.current)
        EmployeeMailer.with(employee: @employee, survey: @survey).invitation_email.deliver_later
        redirect_to survey_survey_employees_path(@survey),
          notice: 'Employé créé et invitation envoyée avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def import
    if params[:file].blank?
      redirect_to survey_survey_employees_path(@survey), alert: "Veuillez sélectionner un fichier à importer."
      return
    end

    unless File.extname(params[:file].original_filename) == ".xlsx"
      redirect_to survey_survey_employees_path(@survey), alert: "Le fichier doit être au format .xlsx"
      return
    end

    begin
      imported_count = 0
      existing_count = 0
      file = params[:file]
      spreadsheet = Roo::Spreadsheet.open(file)
      header = spreadsheet.row(1)

      required_columns = ["Prénom", "Nom", "Email"]
      missing_columns = required_columns - header

      if missing_columns.any?
        redirect_to survey_survey_employees_path(@survey), alert: "Colonnes manquantes : #{missing_columns.join(', ')}"
        return
      end

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        employee = Employee.find_by(email: row['Email'])
        if employee
          unless @survey.employees.include?(employee)
            @survey.add_participant(employee)
            imported_count += 1
          else
            existing_count += 1
          end
        else
          generated_password = SecureRandom.hex(8)
          employee = current_company.employees.build(
            first_name: row['Prénom'],
            last_name: row['Nom'],
            email: row['Email'],
            password: generated_password,
            password_confirmation: generated_password
          )

          if employee.save
            employee.generate_invitation_token
            @survey.add_participant(employee)
            EmployeeMailer.with(employee: employee, survey: @survey).invitation_email.deliver_later
            imported_count += 1
          end
        end
      end

      if imported_count > 0
        message = "#{imported_count} employé(s) importé(s) avec succès"
        message += ", #{existing_count} déjà existant(s)" if existing_count > 0
        redirect_to survey_survey_employees_path(@survey), notice: message
      else
        redirect_to survey_survey_employees_path(@survey), flash: { warning: "0 employé importé, #{existing_count} déjà existant(s)" }
      end

    rescue StandardError => e
      redirect_to survey_survey_employees_path(@survey), alert: "Une erreur est survenue lors de l'import : #{e.message}"
    end
  end

  private

  def set_survey
    @survey = current_company.surveys.find(params[:survey_id])
  end

  def employee_params
    params.require(:employee).permit(:email, :first_name, :last_name)
  end
end
