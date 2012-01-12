class Admin::UsersController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user

  def index
    @users = User.paginate(:page => params[:page])
  end

  def validate
    @user = User.find params[:id]
    if @user.update_attributes({ :validated => true })
      UserMailer.validated_account_email(@user).deliver
      flash[:success] = "User successfully validated"
    else
      flash[:error] = "User couldn't be validated"
    end
    redirect_to admin_users_path
  end

  def invalidate
    @user = User.find params[:id]
    if @user.update_attributes({ :validated => false })
      flash[:success] = "User successfully invalidated"
    else
      flash[:error] = "User couldn't be invalidated"
    end
    redirect_to admin_users_path
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User successfully destroyed"
    redirect_to admin_users_path
  end

end
