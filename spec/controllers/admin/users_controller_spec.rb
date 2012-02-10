require 'spec_helper'

describe Admin::UsersController do
  render_views

  describe "as non admin users" do
    before(:each) do
      @user = Factory(:user)
      test_login @user
    end

    it "should protect the index page" do
      get :index
      response.should redirect_to(root_path)
    end

    it "should protect the validate action" do
      get :validate, :id => @user
      response.should redirect_to(root_path)
    end

    it "should protect the invalidate action" do
      get :invalidate, :id => @user
      response.should redirect_to(root_path)
    end

    it "should protect the activate action" do
      get :activate, :id => @user
      response.should redirect_to root_path
    end

    it "should protect the passive action" do
      get :passive, :id => @user
      response.should redirect_to root_path
    end

    it "should protect the destroy action" do
      delete :destroy, :id => @user
      response.should redirect_to(root_path)
    end
  end

  describe "as admin users" do
    before(:each) do
      @user = Factory(:user)
      @admin = Factory(:user, :email => Factory.next(:email), :admin => true)
      test_login @admin
    end

    describe "GET 'index'" do
      it "should be success" do
        get :index
        response.should be_success
      end

      it "should find users" do
        get :index
        assigns(:users).should == [@user, @admin]
      end
    end

    describe "GET 'validate'" do
      it "should validate the user" do
        get :validate, :id => @user
        @user.reload
        @user.validated.should be_true
      end

      it "should have a flash message" do
        get :validate, :id => @user
        flash[:success].should =~ /successfully/i
      end

      it "should redirect to index" do
        get :validate, :id => @user
        response.should redirect_to admin_users_path
      end

      it "should send the mail" do
        get :validate, :id => @user
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end

    describe "GET 'invalidate'" do
      before(:each) do
        @user.validated = true
        @user.save!
      end

      it "should invalidate the user" do
        get :invalidate, :id => @user
        @user.reload
        @user.validated.should_not be_true
      end

      it "should have a flash message" do
        get :invalidate, :id => @user
        flash[:success].should =~ /successfully/i
      end

      it "should redirect to index" do
        get :invalidate, :id => @user
        response.should redirect_to admin_users_path
      end
    end

    describe "GET 'activate'" do
      before(:each) do
        @user.passive = true
        @user.save!
      end
      it "should activate the user" do
        get :activate, :id => @user
        @user.reload
        @user.passive.should be_false
      end

      it "should have a flash message" do
        get :activate, :id => @user
        flash[:success].should =~ /successfully/i
      end

      it "should redirect to index" do
        get :activate, :id => @user
        response.should redirect_to admin_users_path
      end

      it "should send the mail" do
        get :activate, :id => @user
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end

    describe "GET 'passive'" do
      it "should passive the user" do
        get :passive, :id => @user
        @user.reload
        @user.passive.should be_true
      end

      it "should have a flash message" do
        get :passive, :id => @user
        flash[:success].should =~ /successfully/i
      end

      it "should redirect to index" do
        get :passive, :id => @user
        response.should redirect_to admin_users_path
      end

      it "should send the mail" do
        get :passive, :id => @user
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end

    describe "DELETE 'destroy'" do
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should have a flash message" do
        delete :destroy, :id => @user
        flash[:success].should =~ /deleted/i
      end

      it "should redirect to the index page" do
        delete :destroy, :id => @user
        response.should redirect_to admin_users_path
      end
    end
  end
end
