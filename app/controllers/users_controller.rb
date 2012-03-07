class UsersController < ApplicationController
  before_filter :authenticate, :only => [:show, :edit, :update]
  before_filter :authorize,    :only => [:show, :edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.user_account_created_email(@user).deliver
      flash[:success] = t :welcome_flash
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = t :user_update_flash
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
  def authorize
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user) || current_user.admin?
  end
end
