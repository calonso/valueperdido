require 'spec_helper'

describe "Users" do
  describe "signup" do
    describe "failure" do
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in :name,                  :with => ""
          fill_in :surname,               :with => ""
          fill_in :email,                 :with => ""
          fill_in :password,              :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end

    describe "success" do
      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in :name,                  :with => "thename"
          fill_in :surname,               :with => "thesurname"
          fill_in :email,                 :with => "user@example.com"
          fill_in :password,              :with => "ThePAssw0rd"
          fill_in "Confirmation", :with => "ThePAssw0rd"
          click_button
          response.should render_template('users/show')
          response.should have_selector("div.flash.success",
                                        :content => "Welcome")
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "log in/out" do
    describe "failure" do
      it "should not log the user in" do
        visit login_path
        fill_in :email,     :with => ""
        fill_in :password,  :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Wrong")
      end
    end

    describe "success" do
      it "should log the user in and out" do
        user = Factory(:user)
        visit login_path
        fill_in :email,     :with => user.email
        fill_in :password,  :with => user.password
        click_button
        controller.should be_logged_in
        click_link "Log out"
        controller.should_not be_logged_in
      end
    end
  end
end