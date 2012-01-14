class UsersController < ApplicationController
  before_filter :authenticate, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize,    :only => [:edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.user_account_created_email(@user).deliver
      flash[:success] = "Welcome to ValuePerdido Community!"
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile successfully updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User destroyed"
    logout
    redirect_to root_path
  end

  private
    def authorize
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) || current_user.admin?
    end

end
