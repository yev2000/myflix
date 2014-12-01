require Rails.root.to_s + "/lib/myflix_exception"

class VideoQueueEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  delegate :categories, to: :video

  # a video queue entry must have a position to denote where it appears in order
  # for a user's queue.
  validates_presence_of :position, :video, :user
  validates :position, numericality: { greater_than_or_equal_to: 1 }
  
  # The same video cannot appear in a users's queue more than once
  validates_uniqueness_of :video, scope: [:user_id]

  def review
    # finds the review that was created by this queue entry's user
    # for the queue entry's video.  Returns nil if no such review was
    # found.
    video_review = Review.find_by(video_id: video.id, user_id: user.id)
  end

  def rating_summary_string
    # returns the string representation of a user's review of the video
    # associated with this queue entry
    self.review ? self.review.rating_summary_string : Review.unrated_string
  end

  def rating_star_string
    # returns the string representation of a user's review of the video
    # associated with this queue entry
    self.review ? self.review.rating_star_string : Review.unrated_string
  end

  def rating_value
    self.review ? self.review.rating : Review.unrated_value
  end

  def self.update_queue_positions!(entry_to_position_mapping_array)
    queue_entry_array = []

    # actually set the "position" attribute of each of the video_queue_entry
    # elements of the mapping array.  We accumulate those in the queue_entry_array
    # so that we can then call to normalize the position values and persist
    # the model.
    entry_to_position_mapping_array.each do |mapping_entry|
      mapping_entry[:entry].position = mapping_entry[:new_position]
      queue_entry_array << mapping_entry[:entry]
    end

    normalize_positions!(queue_entry_array)
  end

  def self.normalize_positions!(video_queue_entry_array)
    # Normalize position values of the video queue entries in the
    # input array.
    # EXPECTS: None
    # RESULTS: The position values of the elemets in the passed in array are renumbered starting at 1.
    #          The position values are assigned based on the relative order of items based on their
    #          current 'position' values.
    #          The elements of the passed-in array are persisted.
    # RETURNS: true on success.  false on failure.  If save failure occurs,
    #          no position changes for any elements are persisted.
    video_queue_entry_array.sort! do |x,y|
      if (x.position == y.position)
        raise(DuplicatePositionIDError, "You cannot give the same position to more than one video.  \
          Videos #{x.video.title} and #{y.video.title} were given the same position.")
      end

      x.position <=> y.position
    end

    # and let's renumber starting at 1 (this is to handle the case that some ID
    # was moved to the end of the array from the front or middle without other
    # positions being renumbered by the user)
    return VideoQueueEntry.renumber_positions!(video_queue_entry_array)
  end

  def self.renumber_positions!(video_queue_entry_array)
    # Renumber the position values of the videos in the array that is
    # passed in.
    # EXPECTS: The order of the entries in the input array is the intended
    #          positional order (the first entry will get position value "1".
    # RESULTS: The position values for the elements of the passed-in array are
    #          persisted (saved).
    # RETURNS: true on success.  false on failure.  If save failure occurs,
    #          no position changes for any elements are persisted.

    begin
      VideoQueueEntry.transaction do
        video_queue_entry_array.each_with_index do |entry, index|
          entry.position = index + 1

          # this will throw an exception if the save could not be done
          # and therefore cause the entire transaction to fail
          entry.save!
        end
      end # transaction
    rescue 
      return false
    end

    return true
  end

  def self.renumber_positions_non_transactional!(video_queue_entry_array)
    # Renumber the position values of the videos in the array that is
    # passed in.
    # EXPECTS: The order of the entries in the input array is the intended
    #          positional order (the first entry will get position value "1".
    # RESULTS: The position values for the elements of the passed-in array are
    #          persisted (saved).
    # RETURNS: true on success.  false on failure.  If save failure occurs,
    #          no position changes for any elements are persisted.

    video_queue_entry_array.each_with_index { |entry, index| entry.position = index + 1 }
    video_queue_entry_array.each { |entry| return false if !entry.valid? }
    video_queue_entry_array.each { |entry| entry.save! }
    return true
  end

end
