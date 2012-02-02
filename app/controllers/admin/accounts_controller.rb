class Admin::AccountsController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user

  def index
    @items = Payment.full_accounts_info
    @summaries = AccountSummary.all
  end

end
