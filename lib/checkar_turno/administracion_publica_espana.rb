URL_CITA_PREVIA_TURNOS = 'https://sede.administracionespublicas.gob.es/icpplus/icpplus'.freeze

class AdmistracionPublicaEspana

  def initialize(browser)
    @browser = browser
  end

  def turn_explorer
    begin
      @browser.goto(URL_CITA_PREVIA_TURNOS)
      @browser.select_list(id: 'form').select('/icpplustiem/citar?p=28&locale=es')
      @browser.button(id: 'btnAceptar').click
      # @browser.select_list(id: 'sede').select('14')
      @browser.select_list(id: 'tramiteGrupo[1]').select('4032')
      @browser.button(id: 'btnAceptar').click
      sleep 1
      @browser.execute_script('window.scrollBy(0,1000)')
      sleep 1
      @browser.button(id: 'btnEntrar').click
      @browser.radio(value: 'N.I.E.', id: 'rdbTipoDocNie').set
      @browser.text_field(id: 'txtIdCitado').set('Y8964450F')
      @browser.text_field(id: 'txtDesCitado').set('CARLOS ARIEL BADALAMENTI')
      @browser.text_field(id: 'txtAnnoCitado').set('1983')
      @browser.select_list(id: 'txtPaisNac').select('202')
      sleep 1
      @browser.execute_script('window.scrollBy(0,1000)')
      sleep 1
      @browser.button(id: 'btnEnviar').click
      @browser.button(id: 'btnEnviar').click # Solicitar Cita

      sleep 1

      return true if cita_previa_condition

      return false
    rescue StandardError => e
      puts "error navigating site: #{e}"

      return false
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
