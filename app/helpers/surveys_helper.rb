module SurveysHelper
  def survey_statistics(survey)
    @rating_counts = calculate_rating_counts(survey)  # Stockons les counts dans une variable d'instance

    {
      participation_rate: calculate_participation_rate(survey),
      responses_count: survey.responses.count,
      total_possible_responses: calculate_total_possible_responses(survey),
      active_employees_count: survey.company.employees.where(invitation_accepted: true).count,
      total_employees: survey.company.employees.count,
      average_rating: calculate_average_rating(survey),
      remaining_days: (survey.end_date.to_date - Date.current).to_i,
      end_date: survey.end_date,
      rating_counts: @rating_counts,
      department_stats: calculate_department_stats(survey)
    }
  end

  def theme_status_class(status)
    case status
    when :not_started
      "px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800"
    when :in_progress
      "px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-800"
    when :completed
      "px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800"
    end
  end

  def theme_status_text(status)
    case status
    when :not_started
      "Pas commencé"
    when :in_progress
      "En cours"
    when :completed
      "Terminé"
    end
  end

  def theme_button_class(status)
    base_classes = "inline-flex items-center px-4 py-2 text-sm font-medium rounded-md"
    case status
    when :not_started
      "#{base_classes} text-white bg-indigo-600 hover:bg-indigo-700"
    when :in_progress
      "#{base_classes} text-white bg-yellow-600 hover:bg-yellow-700"
    when :completed
      "#{base_classes} text-gray-700 bg-gray-100 hover:bg-gray-200"
    end
  end

  def theme_button_text(status)
    case status
    when :not_started
      "Commencer"
    when :in_progress
      "Continuer"
    when :completed
      "Revoir"
    end
  end

  private

  def calculate_participation_rate(survey)
    possible = calculate_total_possible_responses(survey)
    return 0 if possible.zero?
    (survey.responses.count.to_f / possible * 100)
  end

  def calculate_total_possible_responses(survey)
    survey.company.employees.where(invitation_accepted: true).count * survey.company_values.count
  end

  def calculate_average_rating(survey)
    survey.responses.average(:rating)&.round(1) || 0
  end

  def calculate_rating_counts(survey)
    survey.responses.group(:rating).count
  end

  def rating_percentage(rating)  # Supprimé le paramètre counts car on utilise @rating_counts
    return 0 if @rating_counts.empty?
    count = @rating_counts[rating] || 0
    (count.to_f / @rating_counts.values.sum * 100).round(1)
  end

  def calculate_department_stats(survey)
    survey.company.employees.group(:department).count.map do |dept, count|
      responses = survey.responses.joins(:employee)
                       .where(employees: { department: dept }).count
      possible_responses = count * survey.company_values.count
      rate = possible_responses.zero? ? 0 : (responses.to_f / possible_responses * 100)

      {
        name: dept || 'Sans département',
        participation_rate: rate
      }
    end
  end
end
