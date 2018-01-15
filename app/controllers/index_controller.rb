class IndexController < ActionController::Base
  protect_from_forgery with: :exception
  
  def index
    @person = Person.new
    @person.age = 10
    flash[:success] = @person.age
  end
  
  def create
    flash[:success] = 'Success!'
  end
end
