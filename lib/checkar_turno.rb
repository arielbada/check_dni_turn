require 'watir'
require 'net_http_ssl_fix'

require_relative './checkar_turno/credentials.rb'
require_relative './checkar_turno/administracion_publica_espana'
require_relative './pushover_client.rb'
PLAYER_PATH = './ext/cmdmp3win.exe'.freeze
MP3_PATH_OK = './assets/inputok.mp3'.freeze

DEBUG = true
INTERVAL = 800 #seconds

if ARGV.length != 1
  puts "Wrong number of arguments"
  exit
end

class CheckTurn

  def run
    count = 0
    turn_not_available = true
    #play_sound    

    case ARGV[0]
    when 'mi_argentina'
      sede = MiArgentina.new
    when 'sede_electronica'
      sede = AdmistracionPublicaEspana.new
    end

    while turn_not_available # infinite loop until turno available
      puts "#{timestamp} intento: #{count += 1}"

      if (message = sede.turn_explorer)
        send_push_notification(message)
        5.times { play_sound }
        turn_not_available = false
        puts "#{timestamp} Encontramos turno!"
        sleep 200000
      end

      interval = INTERVAL..INTERVAL*2
      interval = rand(interval)
      puts "#{timestamp} waiting for the next check #{interval/60} mins..."
      sleep interval
    end
  end

  def play_sound
    `#{PLAYER_PATH} #{MP3_PATH_OK}`
  end

  def send_push_notification(message)
    PushoverClient.new(PUSHOVER_API_KEY, PUSHOVER_USER_KEY).send_push_notification(message)
  end

  def timestamp
    return Time.now.utc.iso8601
  end
end

CheckTurn.new.run
