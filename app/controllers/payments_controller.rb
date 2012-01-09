class PaymentsController < ApplicationController
  before_filter :authenticate
  before_filter :owner_or_admin

  def index
    @payments = Payment.find_all_by_user_id(params[:user_id])
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = @user.payments.build(params[:payment])
    if @payment.save
      flash[:success] = "Payment successfully saved"
      redirect_to user_payments_path, :user_id => @user
    else
      render 'new'
    end
  end

  def destroy
    @payment.destroy
    flash[:success] = "Payment successfully destroyed"
    redirect_to user_payments_path, :user_id => @user
  end

  private

    def owner_or_admin
      @user = User.find(params[:user_id])
      redirect_to (root_path) unless current_user?(@user) || current_user.admin?
      if params[:id]
        @payment = Payment.find(params[:id])
        redirect_to(root_path) unless @payment.user == @user
      end
    end
end
