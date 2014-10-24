class Review < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :video

  validates_uniqueness_of :user, scope: [:video_id]

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5}
  validates :title, :body, :rating, presence: true

  def rating_summary_string
    if self.rating == Review.unrated_value
      return Review.unrated_string
    else
      return "#{self.rating} / 5"
    end
  end

  def rating_star_string
    Review.star_rating_string(self.rating)
  end

  def self.unrated_value
    0
  end

  def self.unrated_string
    "Not rated"
  end

  def self.rating_choices_string_array
    # returns an array of strings which represents the
    # choices for review ratings "levels"
    [unrated_string] + ((1..5).inject([]) { |memo,n| memo << rating_star_string(n) } ).reverse
  end

  def self.rating_only_review_create!(entry)
    rating = entry[:rating]
    return nil if (rating < 0 || rating > 5)

    new_review = self.new(video: entry[:video], user: entry[:user])

    # the following does not perform any validations, so it will return a record
    # with no title and body
    # so we should at least check that the rating value is valid    
    new_review.update_attribute(:rating, rating)
    return new_review
  end

  private

  def self.rating_star_string(n)
    n == unrated_value ? unrated_string : "#{n} " + "Star".pluralize(n)
  end


end
