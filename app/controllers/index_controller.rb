class IndexController < ActionController::Base
  protect_from_forgery with: :exception
  
  def index
    @presupuesto = Presupuesto.new
  end
  
  def create
    @presupuesto = Presupuesto.new(presupuesto_params)
    # flash[:success] = @presupuesto.name
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'presupuesto.tlf')

    xls = Roo::Spreadsheet.open(@presupuesto.file.path, extension: :xls).sheet(0)
    
    report.start_new_page do
      item(:date).value(Time.now.strftime("%d/%m/%Y"))
      
      $i = 6
      while !(xls.cell($i, 1) == nil) do
        $a = xls.cell($i, 1)
        $b = xls.cell($i, 2)
        $c = xls.cell($i, 3)
        $d = xls.cell($i, 4)
        $e = xls.cell($i, 5)
        puts("#$a | #$b | #$c | #$d | #$e")
        $i += 1
      end
      
      $total = xls.cell($i, 5)
      puts("Total: #$total")
      
    end
    
    # download_report(report)
  end
  
  private
    def presupuesto_params
      params.require(:presupuesto).permit(:name, :address, :city, :phone, :car, :patente, :chasis, :motor, :file)
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
