TRAMITE_SANTAFE_UNIONES_CONVIVENCIALES = '233'
TRAMITE_SANTAFE_DNI = '159'
LOCALIDAD_ROSARIO = '295'
#OFICINAS_ROSARIO = ['352','3', '441']
OFICINAS_ROSARIO = ['441']
URL_SANTAFE_TURNOS = 'http://turnos.santafe.gov.ar/turnos/web/frontend.php'.freeze

class SantaFe
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

  private

  def santafe_condition
    @browser.h1(class: 'campo_texto_titulo').text != 'Todos los turnos ya se encuentran asignados, lo invitamos a que intente más tarde.'
  end
  
end