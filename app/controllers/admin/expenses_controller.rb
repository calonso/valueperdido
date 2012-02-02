class Admin::ExpensesController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(params[:expense])
    if @expense.save
      flash[:success] = t :expense_created_flash
      redirect_to admin_accounts_path
    else
      render 'new'
    end
  end
end
