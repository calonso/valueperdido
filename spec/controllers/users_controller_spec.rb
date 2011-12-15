require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do
    describe "for non logged users" do
      it "should deny access" do
        get :index
        response.should redirect_to(login_path)
        flash[:notice] =~ /login/i
      end
    end

    describe "for logged users" do
      before(:each) do
        @user = test_login(Factory(:user))
        second = Factory(:user, :email => "second@example.com")
        third = Factory(:user, :email => "third@example.com")

        @users = [@user, second, third]

        30.times do
          @users << Factory(:user, :name => Factory.next(:name),
                                  :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => 'All users')
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign up")
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
      test_login @user
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = {:name => "", :surname => "", :email => "",
                 :password => "", :password_confirmation => ""}
      end

      it "should not create a new user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "username", :surname => "usersurname",
                  :email => "user@example.com", :password => "UserPAssw0rd",
                  :password_confirmation => "UserPAssw0rd"}
      end

      it "should create a new user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user's show page" do
        post :create, :user => @attr
        response.should render_template('create')
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to ValuePerdido Community!/i
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_login(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => 'Edit user')
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_login(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", :surname => "",
                  :password => "", :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end

      it "should not update the user's attributes" do
        put :update, id => @user, :user => @attr
        prev = {:name => @user.name, :surname => @user.surname, :email => @user.email}
        @user.reload
        @user.name.should == prev[:name]
        @user.surname.should == prev[:surname]
        @user.email.should == prev[:email]
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org", :surname => "surname",
                  :password => "TheNewPassw0rd", :password_confirmation => "TheNewPassw0rd" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.surname.should == @attr[:surname]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication on protected pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-logged users" do
      it "should deny the access to show" do
        get :show, :id => @user
        response.should redirect_to(login_path)
      end

      it "should deny the access to edit" do
        get :edit, :id => @user
        response.should redirect_to(login_path)
      end

      it "should deny access to update" do
        get :edit, :id => @user, :user => {}
        response.should redirect_to(login_path)
      end
    end

    describe "for logged-in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "wrong@wrong.com")
        test_login wrong_user
      end

      it "should require matching users for 'show'" do
        get :show, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "as non-logged user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(login_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should_not change(User, :count)
      end
    end

    describe "as non-admin user" do
      before(:each) do
        test_login @user
      end
      it "should protect the page" do
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should_not change(User, :count)
      end
    end

    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_login(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end

end
