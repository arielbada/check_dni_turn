require 'watir'
require 'net_http_ssl_fix'
require 'pushover'
require_relative './checkar_turno/credentials.rb'
require_relative './checkar_turno/administracion_publica_espana'
CHROMEDRIVER_PATH = './ext/chromedriver.exe'.freeze
PLAYER_PATH = './ext/cmdmp3win.exe'.freeze
MP3_PATH_OK = './assets/inputok.mp3'.freeze

DEBUG = true
INTERVAL = 800 #seconds

if ARGV.length != 1
  puts "Wrong number of arguments"
  exit
end

class CheckTurn
  def initialize
    Selenium::WebDriver::Chrome::Service.driver_path = CHROMEDRIVER_PATH
  end

  def run
    count = 0
    turn_not_available = true
    play_sound
    browser = start_webdriver

    case ARGV[0]
    when 'mi_argentina'
      sede = MiArgentina.new(browser)
    when 'sede_electronica'
      sede = AdmistracionPublicaEspana.new(browser)
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

  def start_webdriver
    options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
      o.add_option(:detach, true)
      o.add_argument('--window-size=1920,1080')
      o.add_argument('--no-sandbox')
      o.add_argument('--disable-infobars')
      o.add_argument('--disable-browser-side-navigation')
      o.add_argument('--headless') unless DEBUG
      o.add_argument('--disable-gpu')
      o.add_argument('--log-level=3')
    end

    browser = Watir::Browser.new :chrome, options: options
    browser.driver.manage.timeouts.page_load = 90

    at_exit do
      browser.close if browser
    end

    browser
  end

  def send_push_notification(message)
    Pushover::Message.new(token: PUSHOVER_API_KEY, user: PUSHOVER_USER_KEY, message: message).push
  end

  def timestamp
    return Time.now.utc.iso8601
  end
end

CheckTurn.new.run
