class Presupuesto
  extend ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  
  def persisted?
    false
  end
  
  attr_accessor :name, 
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
                :carga_aa
  
end