require 'spec_helper'

describe Admin::ExpensesController do
  render_views

  before(:each) do
    @attrs = { :value => 50.5, :description => "Desc" }
  end

  describe "for non logged users" do
    it "should protect the new action" do
      get :new
      response.should redirect_to login_path
    end

    it "should protect the create action" do
      post :create, :expense => @attrs
      response.should redirect_to login_path
    end
  end

  describe "for non admin users" do
    before(:each) do
      user = build_valid_user
      test_login user
    end

    it "should protect the new action" do
      get :new
      response.should redirect_to root_path
    end

    it "should protect the create action" do
      post :create, :expense => @attrs
      response.should redirect_to root_path
    end
  end

  describe "for admin users" do
    before(:each) do
      test_login build_admin
    end

    describe "GET 'new'" do
      it "should be success" do
        get :new
        response.should be_success
      end

      it "should render new template" do
        get :new
        response.should render_template 'new'
      end
    end

    describe "POST 'create'" do
      describe "failure" do
        before(:each) do
          @attrs = { :value => '', :description => ''}
        end

        it "should not create a new instance" do
          lambda do
            post :create, :expense => @attrs
          end.should_not change(Expense, :count)
        end

        it "should re-render the new page" do
          post :create, :expense => @attrs
          response.should render_template 'new'
        end
      end

      describe "success" do
        it "should create a new instance" do
          lambda do
            post :create, :expense => @attrs
          end.should change(Expense, :count).by(1)
        end

        it "should redirect to the admin accounts page" do
          post :create, :expense => @attrs
          response.should redirect_to admin_accounts_path
        end

        it "should show a flash message" do
          post :create, :expense => @attrs
          flash[:success].should =~ /successfully/i
        end
      end
    end
  end
end
