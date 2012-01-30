require 'spec_helper'

describe PagesController do
  render_views

  describe "as non logged user" do
    describe "GET 'home'" do
      it "should be successful" do
        get :home
        response.should be_success
      end

      it "should not show any messages" do
        get :home
        assigns(:messages).should be_nil
      end

      it "should not show the form" do
        get :home
        assigns(:message).should be_nil
      end
    end

    describe "GET 'terms'" do
      it "should be successful" do
        get 'terms'
        response.should be_success
      end
    end
  end

  describe "as logged users" do
    before(:each) do
      user = Factory(:user)
      @msgs = []
      5.times do
        @msgs << Factory(:message, :user => user)
      end

      test_login user
    end

    describe "GET 'home'" do
      it "should show messages" do
        get :home
        assigns(:messages).should == @msgs.reverse
      end

      it "should show the form" do
        get :home
        assigns(:message).should_not be_nil
      end
    end
  end
end
