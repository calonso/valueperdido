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

      it "should not show active information" do
        get :home
        assigns(:active).should be_nil
      end

      it "should not show passive information" do
        get :home
        assigns(:passive).should be_nil
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
      before(:each) do
        Factory(:user, :email => Factory.next(:email), :validated => true)
        Factory(:user, :email => Factory.next(:email), :validated => true, :passive => true)
        Factory(:user, :email => Factory.next(:email), :validated => true)
      end

      it "should show messages" do
        get :home
        assigns(:messages).should == @msgs.reverse
      end

      it "should show the form" do
        get :home
        assigns(:message).should_not be_nil
      end

      it "should show active users information" do
        get :home
        assigns(:active).should == 2
      end

      it "should show passive users information" do
        get :home
        assigns(:passive).should == 1
      end
    end
  end
end
