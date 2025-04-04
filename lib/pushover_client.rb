require 'pushover'

class PushoverClient
  def initialize(api_key, user_key)
    @api_key = api_key
    @user_key = user_key
  end

  def send_push_notification(message)
    Pushover::Message.new(token: @api_key, user: @user_key, message: message).push
  end
end