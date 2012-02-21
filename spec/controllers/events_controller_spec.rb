require 'spec_helper'

describe EventsController do
  render_views

  describe "for not logged users" do
    before(:each) do
      user = Factory(:user)
      @evt = Factory(:event, :user => user)
    end
    it "should deny the access to 'index'" do
      get :index
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'history'" do
      get :history
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'new'" do
      get :new
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'create'" do
      post :create
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'edit'" do
      get :edit, :id => @evt
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'update'" do
      put :update, :id => @evt
      response.should redirect_to(login_path)
    end

    it "should deny the access to 'destroy'" do
      delete :destroy, :id => @evt
      response.should redirect_to(login_path)
    end
  end

  describe "logged users" do
    before(:each) do
      @user = Factory(:user)
      @evt = Factory(:event, :user => @user)
      test_login @user
    end

    it "should be able to access 'index'" do
      get :index
      response.should be_success
    end

    it "should be able to access 'history'" do
      get :history
      response.should be_success
    end

    it "should deny the access to 'new'" do
      get :new
      response.should redirect_to(root_path)
    end

    it "should deny the access to 'create'" do
      post :create
      response.should redirect_to(root_path)
    end

    it "should deny the access to 'edit'" do
      get :edit, :id => @evt
      response.should redirect_to(root_path)
    end

    it "should deny the access to 'update'" do
      post :update, :id => @evt
      response.should redirect_to(root_path)
    end

    it "should deny the access to 'destroy'" do
      delete :destroy, :id => @evt
      response.should redirect_to(root_path)
    end
  end

  describe "admin users" do
    before(:each) do
      @user = Factory(:user, :admin => true)
      test_login @user
    end

    describe "GET 'index' and 'history'" do
      before(:each) do
        @events = []
        @past_events = []
        @closing_events = []
        @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow + 1.day)
        @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow + 1.day)
        @closing_events << Factory(:event, :name => Factory.next(:name), :user => @user)
        @closing_events << Factory(:event, :name => Factory.next(:name), :user => @user)
        @past_events << Factory(:event, :name => Factory.next(:name), :date => Date.today, :user => @user)
        evt = Factory(:event, :name => Factory.next(:name), :user => @user)
        @past_events << evt
        Factory(:bet, :event => evt, :user => @user, :status => Bet::STATUS_PERFORMED, :money => 10.0, :odds => 1.1)
        evt.date = Date.yesterday
        evt.save!
      end

      it "index should only show the following events, not past ones" do
        get :index
        assigns(:events).sort.should == @events.sort
      end

      it "index should separate closing events" do
        get :index
        assigns(:closing_events).sort.should == @closing_events.sort
      end

      it "history should show recently closed events and events with bets performed" do
        get :history
        assigns(:events).sort.should == @past_events.sort
      end
    end

    describe "GET 'new'" do
      it "should be successful" do
        get :new
        response.should be_success
      end
    end

    describe "POST 'create'" do
      describe "failure" do
        before(:each) do
          @attrs = { :name => "", :date => nil}
        end

        it "should not create the event" do
          lambda do
            post :create, :event => @attrs
          end.should_not change(Event, :count)
        end

        it "should re-render the 'new' page" do
          post :create, :event => @attrs
          response.should render_template('new')
        end
      end

      describe "success" do
        before(:each) do
          @attrs = { :name => "Event name",
                     :date => Date.tomorrow }
        end

        it "should create a new event" do
          lambda do
            post :create, :event => @attrs
          end.should change(Event, :count).by(1)
        end

        it "should redirect to the events index page" do
          post :create, :event => @attrs
          response.should redirect_to(events_path)
        end
      end
    end

    describe "GET 'edit'" do
      before(:each) do
        @evt = Factory(:event, :user => @user)
      end

      it "should be successful" do
        get :edit, :id => @evt
        response.should be_success
      end

      it "should find the right event" do
        get :edit, :id => @evt
        assigns[:event].should == @evt
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        @evt = Factory(:event, :user => @user)
      end
      describe "failure" do
        before(:each) do
          @attrs = { :name => "",
                    :date => nil }
        end

        it "should not update the event's attributes" do
          put :update, :id => @evt, :event => @attrs
          prev = {:name => @evt.name, :date => @evt.date}
          @evt.reload
          @evt.name.should == prev[:name]
          @evt.date.should == prev[:date]
        end

        it "should re-render the edit page" do
          put :update, :id => @evt, :event => @attrs
          response.should render_template('edit')
        end
      end

      describe "success" do
        before(:each) do
          @attrs = { :name => "New name",
                     :date => Date.today + 10.days }
        end

        it "should redirect to the event's show page" do
          put :update, :id => @evt, :event => @attrs
          response.should redirect_to(event_path(@evt))
        end

        it "should update event's attributes" do
          put :update, :id => @evt, :event => @attrs
          @evt.reload
          @evt.name.should == @attrs[:name]
          @evt.date.should == @attrs[:date]
        end

        it "should have a flash message" do
          put :update, :id => @evt, :event => @attrs
          flash[:success].should =~ /updated/i
        end
      end
    end

    describe "DELETE 'destroy'" do
      before(:each) do
        @evt = Factory(:event, :user => @user)
      end

      it "should destroy the event" do
        lambda do
          delete :destroy, :id => @evt
        end.should change(Event, :count).by(-1)
      end

      it "should redirect to the event's index page" do
        delete :destroy, :id => @evt
        response.should redirect_to(events_path)
      end

      it "should have a flash message" do
        delete :destroy, :id => @evt
        flash[:success].should =~ /destroyed/i
      end
    end

  end
end