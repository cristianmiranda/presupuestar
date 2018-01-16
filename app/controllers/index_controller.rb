class IndexController < ActionController::Base
  protect_from_forgery with: :exception
  
  def index
    @presupuesto = Presupuesto.new
  end
  
  def create
    @presupuesto = Presupuesto.new(presupuesto_params)
    # flash[:success] = @presupuesto.name
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'presupuesto.tlf')
    
    if (@presupuesto.file != nil)
      xls = Roo::Spreadsheet.open(@presupuesto.file.path, extension: :xls).sheet(0)
    end
    
    $presupuesto = @presupuesto
    
    report.start_new_page do
      item(:date).value(Time.now.strftime("%d/%m/%Y"))
      item(:name).value($presupuesto.name)
      item(:address).value($presupuesto.address)
      item(:city).value($presupuesto.city)
      item(:phone).value($presupuesto.phone)
      item(:car).value($presupuesto.car)
      item(:patente).value($presupuesto.patente)
      item(:chasis).value($presupuesto.chasis)
      item(:motor).value($presupuesto.motor)
      
      $total_repuestos = 0;
      if (xls != nil)
        list.header do |header|
          header.item(:header_pieza).value('PIEZA')
          header.item(:header_descripcion).value('DESCRIPCIÓN')
          header.item(:header_precio_unitario).value('P. UNITARIO')
          header.item(:header_cantidad).value('CANTIDAD')
          header.item(:header_precio).value('PRECIO')
        end
        
        $i = 6
        while (xls.cell($i, 1) != nil) do
          list.add_row do |row|
            $pieza = xls.cell($i, 1)
            $descripcion = xls.cell($i, 2)
            $precio_unitario = xls.cell($i, 3).tr('$','').tr(' ','').to_f
            $cantidad = xls.cell($i, 4).to_i
            $precio = xls.cell($i, 5).tr('$','').tr(' ','').to_f
            
            row.item(:detail_pieza).value($pieza.floor)
            row.item(:detail_descripcion).value($descripcion)
            row.item(:detail_precio_unitario).value("$ " + $precio_unitario.to_s)
            row.item(:detail_cantidad).value($cantidad.floor)
            row.item(:detail_precio).value("$ " + $precio.to_s)
          end
          $i += 1
        end
        
        $total_repuestos = xls.cell($i, 5).tr('$','').tr(' ','').to_f
      end

      item(:total_repuestos).value($total_repuestos)
      $total_repuestos *= 1.21
      
      $chapa = $presupuesto.chapa == nil ? 0 : $presupuesto.chapa.to_f
      $pintura = $presupuesto.pintura == nil ? 0 : $presupuesto.pintura.to_f
      $mecanica = $presupuesto.mecanica == nil ? 0 : $presupuesto.mecanica.to_f
      $electricidad = $presupuesto.electricidad == nil ? 0 : $presupuesto.electricidad.to_f
      $carroceria = $presupuesto.carroceria == nil ? 0 : $presupuesto.carroceria.to_f
      $carga_aa = $presupuesto.carga_aa == nil ? 0 : $presupuesto.carga_aa.to_f
      
      item(:chapa).value("$ " + $chapa.to_s)
      item(:pintura).value("$ " + $pintura.to_s)
      item(:repuestos).value("$ " + $total_repuestos.to_s)     
      item(:mecanica).value("$ " + $mecanica.to_s)
      item(:electricidad).value("$ " + $electricidad.to_s)
      item(:carroceria).value("$ " + $carroceria.to_s)
      item(:carga_aa).value("$ " + $carga_aa.to_s)
      
      item(:total).value("$ " + ($chapa + $pintura + $mecanica + $electricidad + $carroceria + $carga_aa + $total_repuestos).to_s)

    end
    
    download_report(report, $presupuesto.name.tr(' ', '_').upcase)
  end
  
  private
    def presupuesto_params
      params.require(:presupuesto).permit(:name, 
                                          :address, 
                                          :city, 
                                          :phone, 
                                          :car, 
                                          :patente, 
                                          :chasis, 
                                          :motor, 
                                          :file, 
                                          :chapa, 
                                          :pintura, 
                                          :mecanica, 
                                          :electricidad, 
                                          :carroceria, 
                                          :carga_aa)
    end
    
    def download_report(report, pdf_name)
      puts pdf_name
      filename = pdf_name + ".pdf"
      report.generate(filename: filename)
      File.open(filename, 'r') do |f|
        send_data f.read.force_encoding('BINARY'), :filename => filename, :type => "application/pdf", :disposition => "attachment"
      end
      File.delete(filename)
    end
  
end
