class UsersController < ApplicationController

  def new
    @user = User.new
    @title = "Sign up"
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to ValuePerdido Community!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile successfully updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

end
