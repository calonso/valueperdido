require 'spec_helper'

describe PaymentsController do
  render_views

  before (:each) do
    @user = Factory(:user)
    @attr = { :amount => 100.10,
                    :date => Date.yesterday }
  end

  describe "for non logged users" do
    it "should protect the 'index' page" do
      get :index, :user_id => @user
      response.should redirect_to(login_path)
    end

    it "should protect the 'new' action" do
      get :new, :user_id => @user
      response.should redirect_to (login_path)
    end

    it "should protect the 'create' action" do
      post :create, :user_id => @user, :payment => @attr
      response.should redirect_to(login_path)
    end


  end

  describe "for logged users" do
    before(:each) do
      test_login @user
    end

    describe "GET 'index'" do
      before(:each) do
        @payments = []
        @payments << Factory(:payment, :user => @user, :date => Date.today - 1.month)
        @payments << Factory(:payment, :user => @user)
      end

      it "should be success" do
        get :index, :user_id => @user
        response.should be_success
      end

      it "should display all user's payments date ordered" do
        get :index, :user_id => @user
        assigns(:payments).should == @payments.reverse
      end

      it "should protect other's payments" do
        other_usr = Factory(:user, :email => Factory.next(:email))
        get :index, :user_id => other_usr
        response.should redirect_to(root_path)
      end
    end

    describe "GET 'new'" do
      it "should be success" do
        get :new, :user_id => @user
        response.should be_success
      end

      it "should render the 'new' template" do
        get :new, :user_id => @user
        response.should render_template ('new')
      end
    end

    describe "POST 'create'" do

      describe "success" do
        it "should create a new payment" do
          lambda do
            post :create, :user_id => @user, :payment => @attr
          end.should change(@user.payments, :count).by(1)
        end

        it "should redirect to the payment index page" do
          post :create, :user_id => @user, :payment => @attr
          response.should redirect_to(user_payments_path(@user))
        end

        it "should have a flash message" do
          post :create, :user_id => @user, :payment => @attr
          flash[:success].should =~ /successfully/i
        end
      end

      describe "failure" do
        before(:each) do
          @attr = { :amount => nil,
                    :date => Date.yesterday }
        end

        it "should not create any payment" do
          lambda do
            post :create, :user_id => @user, :payment => @attr
          end.should_not change(Payment, :count)
        end

        it "should render the new page again" do
          post :create, :user_id => @user, :payment => @attr
          response.should render_template('new')
        end
      end
    end
  end

  describe "for admin users" do
    before(:each) do
      @admin = Factory(:user, :email => Factory.next(:email), :admin => true)
      @payment = Factory(:payment, :user => @user)
      Factory(:payment, :user => @admin)
      test_login @admin
    end

    describe "GET 'index'" do
      it "should be success" do
        get :index, :user_id => @user
        response.should be_success
      end

      it "should see requested user's payments" do
        get :index, :user_id => @user
        assigns(:payments).should == [@payment]
      end
    end
  end

  describe "unsupported methods" do
    # If is required to respond to this methods,
    # make sure that the AccountSummary is updated
    before(:each) do
      @payment = Factory(:payment, :user => @user)
    end

    it "should not respond to edit" do
      lambda do
        get :edit, :user_id => @user, :id => @payment
      end.should raise_error ActionController::RoutingError
    end

    it "should not respond to update" do
      lambda do
        put :update, :user_id => @user, :id => @payment, :payment => {}
      end.should raise_error ActionController::RoutingError
    end

    it "should not respond to destroy" do
      lambda do
        delete :destroy, :user_id => @user, :id => @payment
      end.should raise_error ActionController::RoutingError
    end
  end
end
