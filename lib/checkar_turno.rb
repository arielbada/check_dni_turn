require 'watir'
require 'net_http_ssl_fix'
require 'pushover'
require_relative './checkar_turno/credentials.rb'

TRAMITE_SANTAFE_UNIONES_CONVIVENCIALES = '233'
TRAMITE_SANTAFE_DNI = '159'
LOCALIDAD_ROSARIO = '295'
#OFICINAS_ROSARIO = ['352','3', '441']
OFICINAS_ROSARIO = ['441']
CHROMEDRIVER_PATH = './ext/chromedriver.exe'.freeze
PLAYER_PATH = './ext/cmdmp3win.exe'.freeze
MP3_PATH_OK = './assets/inputok.mp3'.freeze
URL_MIARGENTINA_LOGIN = 'https://id.argentina.gob.ar/ingresar'.freeze
URL_MIARGENTINA_TURNOS = 'https://mi.argentina.gob.ar/turnos/seleccion-turno/768'.freeze
URL_SANTAFE_TURNOS = 'http://turnos.santafe.gov.ar/turnos/web/frontend.php'.freeze
DEBUG = true
INTERVAL = 120 #seconds

class CheckTurn
  def initialize
    @username = USERNAME
    @password = PASSWORD
    Selenium::WebDriver::Chrome::Service.driver_path = CHROMEDRIVER_PATH
    at_exit do
      @browser.close if @browser
    end
  end

  def run
    count = 0
    turn_not_available = true
    play_sound

    while turn_not_available  # infinite loop until turno available
      puts "intento: #{count += 1}"
      if santafe_turn_explorer || miargentina_turn_explorer
        send_push_notification
        20.times { play_sound }
        turn_not_available = false
        puts 'Encontramos turno!'
        sleep 200000
      end
      sleep rand(INTERVAL..INTERVAL*2)
    end
  end

  def miargentina_turn_explorer
    begin
      start_webdriver
      if login_miargentina
        @browser.goto(URL_MIARGENTINA_TURNOS)
        @browser.radio(value: '1', name: 'forWhomIsIt').set
        sleep 1        
        @browser.button(class: 'btn btn-success'.split(' ')).click

        return true if miargentina_condition
        #@browser.select(name: 'appointment.locality')

        @login = nil
      else
        puts 'error login in miargentina'
        @browser.close
      end
      sleep 2
      @browser.close
      return false
    rescue StandardError => e
      puts "error navigating site: #{e} "
      @login = nil
      @browser.close
    end
  end

  def santafe_turn_explorer
    begin
      start_webdriver
      OFICINAS_ROSARIO.each do |office_number|
        @browser.goto(URL_SANTAFE_TURNOS)
        @browser.select_list(name: 'tramite').select(TRAMITE_SANTAFE_UNIONES_CONVIVENCIALES)
        @browser.select_list(name: 'localidad').select(LOCALIDAD_ROSARIO)
        @browser.select_list(name: 'oficina').select(office_number)
        @browser.button(name: 'SolicitarTurno').click
        sleep 1

        return true if santafe_condition
      end
      sleep 1
      @browser.close
      return false
    rescue StandardError => e
      puts "error navingating site: #{e}"
      @browser.close if @browser
      return false
    end
  end

  def santafe_condition
    @browser.h1(class: 'campo_texto_titulo').text != 'Todos los turnos ya se encuentran asignados, lo invitamos a que intente más tarde.'
  end

  def miargentina_condition
    @browser.select(name: 'appointment.province').children.count > 2
  end

  def login_miargentina
    unless @login
      @browser.goto(URL_MIARGENTINA_LOGIN)

      @browser.text_field('id': 'cuil').set(@username)
      @browser.text_field('id': 'password_confirmacion').set(@password)
      sleep 1
      @browser.button(class: 'btn btn-success'.split(' ')).click
      sleep 1

      @login = true
    end

    @browser
  end

  def play_sound
    `#{PLAYER_PATH} #{MP3_PATH_OK}`
  end

  def start_webdriver
    options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
      o.add_option(:detach, true)
      o.add_argument('--no-sandbox')
      o.add_argument('--disable-infobars')
      o.add_argument('--disable-browser-side-navigation')
      o.add_argument('--headless') unless DEBUG
      o.add_argument('--disable-gpu')
      o.add_argument('--log-level=3')
      o.add_argument("--window-size=1600,900")
    end

    @browser = Watir::Browser.new :chrome, options: options
    @browser.driver.manage.timeouts.page_load = 90

    @browser
  end

  def send_push_notification
    Pushover::Message.new(token: PUSHOVER_API_KEY, user: PUSHOVER_USER_KEY, message: URL_SANTAFE_TURNOS).push    
  end
end

CheckTurn.new.run
