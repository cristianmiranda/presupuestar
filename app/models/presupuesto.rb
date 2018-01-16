class Presupuesto
  extend ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  
  def persisted?
    false
  end
  
  attr_accessor :name, :address, :city, :phone, :car, :patente, :chasis, :motor
  attr_accessor :file
  attr_accessor :chapa, :pintura, :repuestos, :mecanica, :electricidad, :carroceria, :carga_aa
  
end