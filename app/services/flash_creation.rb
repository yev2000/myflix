class FlashCreation
  def initialize(message_hash)
    @message_hash = message_hash
  end

  def set_flash(type, message)
    @message_hash[type] = message
  end
end
