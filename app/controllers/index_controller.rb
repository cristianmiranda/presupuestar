class IndexController < ActionController::Base
  protect_from_forgery with: :exception
  
  def index
    @person = Person.new
  end
  
  def create
    @person = Person.new(person_params)
    flash[:success] = @person.age
    render :index
  end
  
  private
    def person_params
      params.require(:person).permit(:age)
    end
  
end
