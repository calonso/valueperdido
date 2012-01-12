require 'spec_helper'

describe Admin::AccountsController do
  render_views

  describe "for non logged users" do
    it "should protect the index page" do
      get :index
      response.should redirect_to login_path
    end
  end

  describe "for non admin users" do
    before(:each) do
      test_login Factory(:user)
    end
    it "should protect the index page" do
      get :index
      response.should redirect_to root_path
    end
  end

  describe "for admin users" do
    before(:each) do
      test_login Factory(:user, :admin => true)
    end
    it "should be success" do
      get :index
      response.should be_success
    end
  end
end
