require 'spec_helper'

describe MessagesController do
  render_views
  before(:each) do
    @user = build_valid_user
    @attr = { :message => "The message" }
  end

  describe "as non logged users" do
    it "should protect the create action" do
      post :create, :message => @attr
      response.should redirect_to(login_path)
    end
  end
  
  describe "as logged user" do
    before(:each) do
      test_login @user
    end

    describe "failure" do
      before(:each) do
        @attr = { :message => '' }
      end

      it "should not create a message" do
        lambda do
          post :create, :message => @attr
        end.should_not change(Message, :count)
      end

      it "should render the home page" do
        post :create, :message => @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do
      it "should create a new message" do
        lambda do
          post :create, :message => @attr
        end.should change(Message, :count).by(1)
      end

      it "should redirect to root path" do
        post :create, :message => @attr
        response.should redirect_to(root_path)
      end

      it "should have a flash message" do
        post :create, :message => @attr
        flash[:success] =~ /succesfully/i
      end
    end
  end
end
