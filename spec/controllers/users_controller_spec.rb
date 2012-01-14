require 'spec_helper'

describe UsersController do
  render_views
  before(:each) do
    @user = Factory(:user)
    @attr = {:name => "username", :surname => "usersurname",
             :email => "user@example.com", :password => "UserPAssw0rd",
             :password_confirmation => "UserPAssw0rd"}
  end

  describe "for non logged users" do
    describe "GET 'new'" do
      it "should be success" do
        get :new
        response.should be_success
      end

      it "should render the 'new' template" do
        get :new
        response.should render_template('new')
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

        it "should send the mail" do
          post :create, :user => @attr
          ActionMailer::Base.deliveries.should_not be_empty
        end
      end
    end

    it "should protect the 'show' action" do
      get :show, :id => @user
      response.should redirect_to login_path
    end

    it "should protect the 'edit' action" do
      get :edit, :id => @user
      response.should redirect_to login_path
    end

    it "should protect the 'update' action" do
      put :update, :id => @user, :user => @attr
      response.should redirect_to login_path
    end

    it "should protect the 'destroy' action" do
      delete :destroy, :id => @user
      response.should redirect_to login_path
    end
  end

  describe "for logged users" do
    before(:each) do
      test_login @user
    end

    describe "GET 'show'" do
      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end

      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end
    end

    describe "GET 'edit'" do
      describe "as auth user" do
        it "should be successful" do
          get :edit, :id => @user
          response.should be_success
        end

        it "should retrieve the right user" do
          get :edit, :id => @user
          assigns(:user).should == @user
        end
      end

      describe "as not auth user" do
        it "should protect the page" do
          other_user = Factory(:user, :email => Factory.next(:email))
          get :edit, :id => other_user
          response.should redirect_to root_path
        end
      end
    end

    describe "PUT 'update'" do
      describe "as auth user" do
        describe "failure" do
          before(:each) do
            @attr = { :email => "", :name => "", :surname => "",
                      :password => "", :password_confirmation => "" }
          end

          it "should render the 'edit' page" do
            put :update, :id => @user, :user => @attr
            response.should render_template('edit')
          end

          it "should not update the user's attributes" do
            put :update, :id => @user, :user => @attr
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

          describe "without pass modification" do
            before(:each) do
              @attr = { :name => "New Name", :email => "user@example.org", :surname => "surname" }
            end

            it "should change the user's attributes" do
              put :update, :id => @user, :user => @attr
              @user.reload
              @user.name.should  == @attr[:name]
              @user.surname.should == @attr[:surname]
              @user.email.should == @attr[:email]
            end

            it "should keep the password and salt" do
              put :update, :id => @user, :user => @attr
              prev_pass = @user.encrypted_password
              prev_salt = @user.salt
              @user.reload
              @user.encrypted_password.should == prev_pass
              @user.salt.should == prev_salt
            end
          end
        end
      end
      describe "as not auth user" do
        before(:each) do
          @other = Factory(:user, :email => Factory.next(:email))
          @attr = { :name => "New Name", :email => "user@example.org", :surname => "surname",
                    :password => "TheNewPassw0rd", :password_confirmation => "TheNewPassw0rd" }
        end

        it "should protect the page" do
          put :update, :id => @other, :user => @attr
          response.should redirect_to root_path
        end

        it "should not update the user's attributes" do
          put :update, :id => @other, :user => @attr
          prev = {:name => @other.name, :surname => @other.surname, :email => @other.email}
          @other.reload
          @other.name.should == prev[:name]
          @other.surname.should == prev[:surname]
          @other.email.should == prev[:email]
        end
      end
    end

    describe "DELETE 'destroy'" do
      describe "as auth user" do
        it "should destroy the user" do
          lambda do
            delete :destroy, :id => @user
          end.should change(User, :count).by(-1)
        end

        it "should redirect to the root page" do
          delete :destroy, :id => @user
          response.should redirect_to root_path
        end

        it "should log the user out" do
          delete :destroy, :id => @user
          controller.should_not be_logged_in
        end
      end

      describe "as not auth user" do
        it "should not destroy the user" do
          other_user = Factory(:user, :email => Factory.next(:email))
          lambda do
            delete :destroy, :id => other_user
          end.should_not change(User, :count)
        end
      end
    end
  end

  describe "for admin users" do
    before(:each) do
      @admin = Factory(:user, :email => Factory.next(:email), :admin => true)
      test_login @admin
    end

    describe "GET 'show'" do
      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end

      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end
    end

    describe "GET 'edit'" do
      it "should be successful" do
        get :edit, :id => @user
        response.should be_success
      end

      it "should retrieve the right user" do
        get :edit, :id => @user
        assigns(:user).should == @user
      end
    end

    describe "PUT 'update'" do
      describe "failure" do
        before(:each) do
          @attr = { :email => "", :name => "", :surname => "",
                    :password => "", :password_confirmation => "" }
        end

        it "should render the 'edit' page" do
          put :update, :id => @user, :user => @attr
          response.should render_template('edit')
        end

        it "should not update the user's attributes" do
          put :update, :id => @user, :user => @attr
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

    describe "DELETE 'destroy'" do
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the root page" do
        delete :destroy, :id => @user
        response.should redirect_to root_path
      end
    end
  end
end
