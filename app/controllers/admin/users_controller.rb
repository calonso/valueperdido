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
      flash[:success] = t :user_validated_flash
    else
      flash[:error] = t :user_validated_flash_err
    end
    redirect_to admin_users_path
  end

  def invalidate
    @user = User.find params[:id]
    if @user.update_attributes({ :validated => false })
      flash[:success] = t :user_invalidated_flash
    else
      flash[:error] = t :user_invalidated_flash_err
    end
    redirect_to admin_users_path
  end

  def activate
    @user = User.find params[:id]
    if @user.update_attribute :passive, false
      UserMailer.passive_account_email(@user, false).deliver
      flash[:success] = t :user_activated_flash
    else
      flash[:error] = t :user_activated_flash_err
    end
    redirect_to admin_users_path
  end

  def passive
    @user = User.find params[:id]
    if @user.update_attribute :passive, true
      UserMailer.passive_account_email(@user, false).deliver
      flash[:success] = t :user_passive_flash
    else
      flash[:error] = t :user_passive_flash_err
    end
    redirect_to admin_users_path
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t :user_deleted_flash
    redirect_to admin_users_path
  end

end
