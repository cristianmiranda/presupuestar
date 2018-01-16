class IndexController < ActionController::Base
  protect_from_forgery with: :exception
  
  def index
    @presupuesto = Presupuesto.new
  end
  
  def create
    @presupuesto = Presupuesto.new(presupuesto_params)
    # flash[:success] = @presupuesto.name
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'presupuesto.tlf')
    report.start_new_page do
      item(:date).value(Time.now.strftime("%d/%m/%Y"))
    end
    
    download_report(report)
  end
  
  private
    def presupuesto_params
      params.require(:presupuesto).permit(:name, :address, :city, :phone, :car, :patente, :chasis, :motor)
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
