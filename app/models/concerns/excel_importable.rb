module ExcelImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_excel(file, company)
      spreadsheet = Roo::Spreadsheet.open(file)
      header = spreadsheet.row(1)

      # Vérifier que les colonnes requises sont présentes
      required_columns = ["Prénom", "Nom", "Email"]
      missing_columns = required_columns - header

      if missing_columns.any?
        raise "Colonnes manquantes : #{missing_columns.join(', ')}"
      end

      # Valider le format des emails avant import
      invalid_emails = []
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        unless row['Email'] =~ URI::MailTo::EMAIL_REGEXP
          invalid_emails << "Ligne #{i}: #{row['Email']}"
        end
      end

      if invalid_emails.any?
        raise "Emails invalides détectés :\n#{invalid_emails.join('\n')}"
      end

      true
    end
  end
end
