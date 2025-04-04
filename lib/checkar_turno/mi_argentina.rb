require_relative '../webdriver_class'
URL_MIARGENTINA_LOGIN = 'https://id.argentina.gob.ar/ingresar'.freeze
URL_MIARGENTINA_TURNOS = 'https://mi.argentina.gob.ar/turnos/seleccion-turno/768'.freeze
class MiArgentina
  def initialize
    @username = USERNAME
    @password = PASSWORD
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

      false
    rescue StandardError => e
      puts "error navigating site: #{e} "
      @login = nil
      @browser.close
    end
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

  def miargentina_condition
    @browser.select(name: 'appointment.province').children.count > 2
  end
end