class MessagesController < ApplicationController
  before_filter :authenticate

  def create
    @message = current_user.messages.build(params[:message])
    if @message.save
      flash[:success] = t :message_created_flash
      redirect_to root_path
    else
      @messages = Message.where("TRUE").paginate(:page => params[:page])
      render 'pages/home'
    end
  end

end
