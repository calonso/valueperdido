class PagesController < ApplicationController

  def home
    if logged_in?
      @messages = Message.where("TRUE").paginate(:page => params[:page])
      @message = Message.new
      @active = User.where(:passive => false).count
      @passive = User.where(:passive => true).count
    end
  end

  def terms
  end

  def locales
  end

end
