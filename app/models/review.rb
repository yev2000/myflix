class Review < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :video

  validates_uniqueness_of :user, scope: [:video_id]

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5}
  validates :title, :body, :rating, presence: true

  def rating_string
    if self.rating == 0
      return "Not rated"
    else
      return "#{self.rating} / 5"
    end
  end

end
