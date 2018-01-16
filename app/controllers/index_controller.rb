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
      item(:chapa).value($presupuesto.chapa)
      item(:pintura).value($presupuesto.pintura)
      item(:repuestos).value($presupuesto.repuestos)
      item(:mecanica).value($presupuesto.mecanica)
      item(:electricidad).value($presupuesto.electricidad)
      item(:carroceria).value($presupuesto.carroceria)
      item(:carga_aa).value($presupuesto.carga_aa)
      
      if (xls != nil)
        
        list.header do |header|
          header.item(:header_pieza).value('PIEZA')
          header.item(:header_descripcion).value('DESCRIPCIÓN')
          header.item(:header_precio_unitario).value('PRECIO UNITARIO')
          header.item(:header_cantidad).value('CANTIDAD')
          header.item(:header_precio).value('PRECIO')
        end
        
        $i = 6
        while (xls.cell($i, 1) != nil) do
          list.add_row do |row|
            row.item(:detail_pieza).value(xls.cell($i, 1))
            row.item(:detail_descripcion).value(xls.cell($i, 2))
            row.item(:detail_precio_unitario).value(xls.cell($i, 3))
            row.item(:detail_cantidad).value(xls.cell($i, 4))
            row.item(:detail_precio).value(xls.cell($i, 5))
          end
          $i += 1
        end
        
        $total = xls.cell($i, 5)
        item(:total_repuestos).value($total)
      end

    end
    
    download_report(report)
  end
  
  private
    def presupuesto_params
      params.require(:presupuesto).permit(:name, :address, :city, :phone, :car, :patente, :chasis, :motor, :file, :chapa, :pintura, :repuestos, :mecanica, :electricidad, :carroceria, :carga_aa)
    end
    
    def download_report(report)
      filename = 'presupuesto.pdf'
      report.generate(filename: filename)
      File.open(filename, 'r') do |f|
        send_data f.read.force_encoding('BINARY'), :filename => filename, :type => "application/pdf", :disposition => "attachment"
      end
      File.delete(filename)
    end
  
end
