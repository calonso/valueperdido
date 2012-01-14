class PagesController < ApplicationController

  def home
    @title = "Home"
    @messages = Message.where("TRUE").paginate(:page => params[:page]) if logged_in?
    @message = Message.new if logged_in?
  end

  def terms
    @title = "Terms and Conditions"
  end

end
