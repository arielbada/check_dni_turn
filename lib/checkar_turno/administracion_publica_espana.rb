require 'autoit'

require_relative '../webdriver_class'
URL_CITA_PREVIA_TURNOS = 'https://icp.administracionelectronica.gob.es/icpplus'.freeze
RETRY_COUNT = 5

class AdmistracionPublicaEspana
  def initialize
    @autoit = AutoIt::Control.new
  end

  def onhover_click(element)
    javaScript = "var evObj = document.createEvent('MouseEvents');" +
                    "evObj.initMouseEvent(\"mouseover\",true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);" +
                    "#{element}.dispatchEvent(evObj);";
    @browser.execute_script(javaScript, element)
    @browser.execute_script("#{element}.click()")
  end
  

  def turn_explorer
    failed_count = 0
    begin
      @browser = start_webdriver
      @browser.goto(URL_CITA_PREVIA_TURNOS)
      sleep rand(2..3)
      @browser.execute_script("document.querySelector('select[name=\"form\"]').value = '/icpplus/citar?p=17&locale=es';")
      sleep rand(1..1.5)
      # Click aceptar
      @browser.execute_script('document.getElementById("btnAceptar").click()')
      #onhover_click('document.getElementById("btnAceptar")')
      #@autoit.click_on("Proceso automático para la solicitud de cita previa - Google Chrome", 100, 100, 1, 0)

      # Click on the button
      #@browser.select_list(name: 'sede').select('2')
      @browser.execute_script("document.querySelector('select[name=\"sede\"]').value = '1';")
      sleep rand(1.5..2.5)

      # Select the tramite
      #@browser.select_list(name: 'tramiteGrupo[0]').select('4010')
      @browser.execute_script("document.querySelector('select[name=\"tramiteGrupo[1]\"]').value = '4010';")
      sleep rand(1..2.4)
      @browser.execute_script('window.scrollBy(0,210)')
      sleep rand(1..1.4)
      @browser.execute_script('document.getElementById("btnAceptar").click()')
      #@browser.form(id: 'portadaForm').submit
      #@browser.button(id: 'btnAceptar').click
      # the webpage is deteting the bot, so we need to emulate the click of the button with javascript
      sleep 1
      @browser.execute_script('document.getElementById("btnEntrar").click()')
      
      # puts "Waiting for the certificate selection dialog..."
      # sleep 1
      # load_press_enter # Thread to press enter in 3 seconds
      # alert_popup = @browser.switch_to.alert
      # alert_popup.accept
      # puts "Certificate selected"
      @browser.radio(value: 'N.I.E.', id: 'rdbTipoDocNie').set
      @browser.text_field(id: 'txtIdCitado').set('Y8964450F')
      @browser.text_field(id: 'txtDesCitado').set('CARLOS ARIEL BADALAMENTI')
      @browser.select_list(id: 'txtPaisNac').select('202')
      sleep 0.5
      @browser.execute_script('window.scrollBy(0,300)')
      sleep rand(0.2..0.5)
      @browser.execute_script('window.scrollBy(0,450)')
      sleep rand(0.2..0.5)
      @browser.execute_script('window.scrollBy(0,320)')
      sleep rand(0.2..0.4)
      @browser.button(id: 'btnEnviar').click
      @browser.button(id: 'btnEnviar').click # Solicitar Cita

      sleep 1

      return true if cita_previa_conditionr

      return false
    rescue StandardError => e
      puts "error navigating site: #{e}"
      if @browser.text.include?('The requested URL was rejected. Please consult with your administrador.')        
        puts 'The requested URL was rejected. Please consult with your administrador.'
        @browser.close
        @browser = nil
        failed_count += 1
        sleep rand((failed_count+1)/2 * 60)
        retry
      else
        puts e
      end
    end
  end

  def cita_previa_condition
    return true if @browser.div(id: 'divtxtTelefonoCitado').exist?

    msg_info = @browser.p(class: 'mf-msg__info')

    return false unless msg_info.exist?

    return false if msg_info.text.match('En este momento no hay citas disponibles.')

    true
  end
end
