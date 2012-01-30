require 'spec_helper'

describe "LayoutLinks" do
  it "should have a Home page at '/'" do
    get root_path
    response.should be_success
  end

  it "should have a Terms page at '/terms'" do
    get terms_path
    response.should be_success
  end

  it "should have a signup page at '/signup'" do
    get signup_path
    response.should be_success
  end

  describe "when not logged in" do
    it "should have a login link" do
      visit root_path
      response.should have_selector('a', :content => 'Log in')
    end
  end

  describe "when logged in" do
    before(:each) do
      @user = Factory(:user, :validated => true)
      visit login_path(:locale => :en)
      fill_in :Email,     :with => @user.email
      fill_in :password,  :with => @user.password
      click_button
    end

    it "should have a logout link" do
      visit root_path
      response.should have_selector('a', :content => 'Log out')
    end
  end
end
