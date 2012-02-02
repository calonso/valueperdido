class PaymentsController < ApplicationController
  before_filter :authenticate
  before_filter :owner_or_admin

  def index
    @payments = @user.payments.paginate(:page => params[:page])
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = @user.payments.build(params[:payment])
    if @payment.save
      flash[:success] = t :payment_created_flash
      redirect_to user_payments_path, :user_id => @user
    else
      render 'new'
    end
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
