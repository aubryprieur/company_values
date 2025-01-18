module ResponsesHelper
  def rating_color(rating)
    case rating
    when 1..3
      "bg-red-500"
    when 4..6
      "bg-yellow-500"
    when 7..8
      "bg-lime-500"
    else
      "bg-green-500"
    end
  end
end
