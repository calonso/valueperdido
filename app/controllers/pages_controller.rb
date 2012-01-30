class PagesController < ApplicationController

  def home
    @messages = Message.where("TRUE").paginate(:page => params[:page]) if logged_in?
    @message = Message.new if logged_in?
  end

  def terms
  end

  def locales
  end

end
