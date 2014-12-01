class VideoDecorator < Draper::Decorator
  delegate_all

  def average_rating_string
    avg_val = self.average_rating
    if avg_val > 0
      if ((avg_val % 1) > 0)
        # this is not an integer, so use sprintf to format
        return sprintf("%.1f / 5.0", avg_val)
      else
        # this is an integer so just return the string value
        return "#{avg_val.to_i} / 5.0"
      end
    else
      return "No ratings"
    end
  end

end
