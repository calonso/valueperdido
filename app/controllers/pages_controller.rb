class PagesController < ApplicationController

  def home
    @title = "Home"
  end

  def terms
    @title = "Terms and Conditions"
  end

end
