require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do
    describe "invalid login" do
      before(:each) do
        @attr = { :email => "user@example.com", :password => "invalid"}
      end

      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end

      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /wrong/i
      end
    end

    describe "valid login" do
      before(:each) do
        @user = build_valid_user
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "should log the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_logged_in
      end

      it "should redirect to the home page" do
        post :create, :session => @attr
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = build_valid_user
      test_login(@user)
    end

    it "should log the user out" do
      delete :destroy
      controller.should_not be_logged_in
      response.should redirect_to(root_path)
    end
  end
end
