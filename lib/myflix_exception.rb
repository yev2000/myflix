class QueuePositionError < StandardError
end

class QueueReviewError < StandardError
end

class ReviewCreationError < StandardError
end

class PaymentError < StandardError
end

class DuplicatePositionIDError < QueuePositionError
end

