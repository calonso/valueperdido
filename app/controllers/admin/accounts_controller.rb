class Admin::AccountsController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user

  def index
    @items = AccountSummary.full_accounts_info
    @summaries = AccountSummary.all
  end

end
