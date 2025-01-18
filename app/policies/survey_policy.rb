class SurveyPolicy < ApplicationPolicy
  def show?
    if user.is_a?(Employee)
      record.company == user.company
    elsif user.is_a?(Company)
      record.company == user
    end
  end

  def qvt_results?
    show?
  end

  def answer_theme?
    show?
  end
end
