class Review < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :video

  validates_uniqueness_of :user, scope: [:video_id]

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5}
  validates :title, :body, :rating, presence: true

  def self.unrated_value
    0
  end

  def self.unrated_string
    "Not rated"
  end

  def self.valid_rating?(rating_value)
    return true unless (rating_value < 0 || rating_value > 5)

    return false
  end

  def self.rating_choices_string_array
    # returns an array of strings which represents the
    # choices for review ratings "levels"
    [unrated_string] + ((1..5).inject([]) { |memo,n| memo << rating_star_string(n) } ).reverse
  end

  def self.rating_only_review_create!(entry)
    # creates a review object where only a rating (but no review body) is provided
    # the entry is a hash containing the rating value and the user and video information
    # for the review.
    rating = entry[:rating]

    # the following does not perform any validations, so it will return a record
    # with no title and body
    # so we should at least check that the rating value is valid
    return nil unless valid_rating?(rating)

    new_review = self.new(video: entry[:video], user: entry[:user])

    # this will save the review record, even if it's invalid
    new_review.update_attribute(:rating, rating)

    return new_review
  end

  def rating_summary_string
    # returns a string appropriate for providing as a brief textual summary of
    # the review's rating value
    return "#{self.rating} / 5" unless self.rating == Review.unrated_value

    return Review.unrated_string
  end

  private

  def self.rating_star_string(rating_value)
    rating_value == unrated_value ? unrated_string : "#{rating_value} " + "Star".pluralize(rating_value)
  end


end
