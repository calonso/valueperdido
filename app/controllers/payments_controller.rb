class PaymentsController < ApplicationController
  before_filter :authenticate
  before_filter :owner_or_admin, :only => :index
  before_filter :admin, :only => [:new, :create]

  def index
    @payments = @user.payments.paginate(:page => params[:page])
  end

  def new
    @payment = Payment.new
  end

  def create
    @user = User.find(params[:user_id])
    @payment = @user.payments.build(params[:payment])
    Payment.transaction do
      begin
        @payment.save!
        @payment.recalculate_percentages
        flash[:success] = t :payment_created_flash
        redirect_to user_payments_path, :user_id => @user
      rescue Exception
        render 'new'
        raise ActiveRecord::Rollback
      end
    end
  end

  private
  def admin
    redirect_to (root_path) unless current_user.admin?
  end

  def owner_or_admin
    @user = User.find(params[:user_id])
    redirect_to (root_path) unless current_user?(@user) || current_user.admin?
  end
end
