class Admin::UsersController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user

  def index
    @users = User.paginate(:page => params[:page])
  end

  def validate
    @user = User.find params[:id]
    if @user.update_attribute :validated, true
      UserMailer.validated_account_email(@user).deliver
      flash[:success] = t :user_validated_flash
    else
      flash[:error] = t :user_validated_flash_err
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
      UserMailer.passive_account_email(@user, true).deliver
      flash[:success] = t :user_passive_flash
    else
      flash[:error] = t :user_passive_flash_err
    end
    redirect_to admin_users_path
  end

  def destroy
    User.transaction do
      begin
        User.find(params[:id]).do_destroy
        flash[:success] = t :user_deleted_flash
      rescue Exception => e
        puts e
        flash[:error] = t :user_deleted_flash_err
        raise ActiveRecord::Rollback
      end
    end
    redirect_to admin_users_path
  end
end
