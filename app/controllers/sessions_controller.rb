class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.authenticate(params[:session][:email],
                              params[:session][:password])
    if user.nil?
      flash.now[:error] = t :login_flash_err
      render 'new'
    else
      login user
      redirect_back_or root_path
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

end
