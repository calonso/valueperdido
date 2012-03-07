require 'spec_helper'

describe PaymentsController do
  render_views

  before(:each) do
    @user = build_valid_user
    @attr = { :amount => 100.10 }
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
        @payments << payment_at(@user)
        @payments << payment_at(@user)
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
        other_usr = build_valid_user
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
          @attr = { :amount => nil }
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
      @admin = build_admin
      @payment = payment_at @user
      payment_at @admin
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
    # and percentages also
    before(:each) do
      @payment = payment_at @user
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

  describe "percentages" do
    describe "for one user" do
      before(:each) do
        test_login @user
        post :create, :user_id => @user, :payment => @attr
      end

      it "should give 100% to the first user" do
        @user.reload
        @user.percentage.should == 100
      end

      it "should still give 100% if makes a new payment" do
        post :create, :user_id => @user, :payment => { :amount => 5 }
        @user.reload
        @user.percentage.should == 100
      end
    end

    describe "for various users" do
      before(:each) do
        payment_at @user, Time.now, 100.2
        @user2 = build_valid_user
        @user3 = build_valid_user
        test_login @user2
      end

      it "should be 50% if all same amount" do
        post :create, :user_id => @user2, :payment => { :amount => 100.2 }
        [@user, @user2].each do |usr|
          usr.reload
          usr.percentage.should == 50
        end
        @user3.reload
        @user3.percentage.should == 0
      end

      it "should respect the amounts relation" do
        post :create, :user_id => @user2, :payment => { :amount => 50.1 }
        @user.reload
        @user.percentage.round(2).should == 66.67
        @user2.reload
        @user2.percentage.round(2).should == 33.33
        @user3.reload
        @user3.percentage.should == 0
      end

      it "should be 0 if no money paid" do
        post :create, :user_id => @user2, :payment => { :amount => 0 }
        @user.reload
        @user.percentage.round(2).should == 100.0
        @user2.reload
        @user2.percentage.round(2).should == 0.0
        @user3.reload
        @user3.percentage.should == 0
      end
    end

    describe "with not validated users" do
      before(:each) do
        payment_at @user, Time.now, 100.2
        @user2 = build_not_valid_user
        @user2.percentage = 11
        @user2.save!
        @user3 = build_valid_user
        test_login @user3
      end

      it "should not count invalidated users" do
        post :create, :user_id => @user3, :payment => { :amount => 100.2 }
        @user.reload
        @user2.reload
        @user3.reload
        @user.percentage.round(2).should == 50.0
        @user2.percentage.round(2).should == 11
        @user3.percentage.round(2).should == 50.0
      end
    end

    describe "when failing" do
      before(:each) do
        payment_at @user, Time.now, 100.2
        @user2 = build_valid_user
        payment_at @user2, Time.now, 100.2
        @user3 = build_valid_user
        test_login @user3
      end

      it "should keep the previous percentages" do
        post :create, :user_id => @user3, :payment => { :amount => 'abc' }
        @user.reload
        @user.percentage.round(2).should == 50.0
        @user2.reload
        @user2.percentage.round(2).should == 50.0
        @user3.reload
        @user3.percentage.should == 0
      end

      it "should keep the percentages if an error with percentages happens" do
        @user.update_attribute :percentage, 200
        post :create, :user_id => @user3, :payment => { :amount => 50 }
        @user.reload
        @user.percentage.round(2).should == 200.0
        @user2.reload
        @user2.percentage.round(2).should == 50.0
        @user3.reload
        @user3.percentage.should == 0
      end

      it "should not create the payment if an error with percentages happens" do
        @user.update_attribute :percentage, 200
        lambda do
          post :create, :user_id => @user3, :payment => { :amount => 50 }
        end.should_not change(Payment, :count)
      end
    end
  end
end
