class Admin::AccountsController < ApplicationController
  before_filter :admin_user

  def index
    @items = Payment.full_acounts_info
  end

end
