require_relative '../lib/checkar_turno/credentials.rb'
require_relative '../lib/pushover_client.rb'

message = 'Testing message'
PushoverClient.new(PUSHOVER_API_KEY, PUSHOVER_USER_KEY).send_push_notification(message)