require 'spec_helper'

describe EventsController do
  render_views

  describe "for not logged users" do
    before(:each) do
      user = build_valid_user
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
      @user = build_valid_user
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
      @user = build_admin
      test_login @user
    end

    describe "GET 'index' and 'history'" do
      before(:each) do
        @events = []
      end
      describe "active events section" do
        before(:each) do
          @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow + 1.day)
          @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow + 1.day)
        end

        it "should only show the active events" do
          get :index
          assigns(:events).sort.should == @events.sort
        end

        it "should not get any closing event" do
          get :index
          assigns(:closing_events).should be_empty
        end

        it "should not get any running event" do
          get :index
          assigns(:running_events).should be_empty
        end

        it "historic should be empty" do
          get :history
          assigns(:events).should be_empty
        end
      end

      describe "closing events section" do
        before(:each) do
          @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          @events << Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
        end

        it "should not get any active events" do
          get :index
          assigns(:events).should be_empty
        end

        it "should show the closing events" do
          get :index
          assigns(:closing_events).sort.should == @events.sort
        end

        it "should not get any running event" do
          get :index
          assigns(:running_events).should be_empty
        end

        it "historic should be empty" do
          get :history
          assigns(:events).should be_empty
        end
      end

      describe "running events section" do
        before(:each) do
          evt = Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          Factory(:bet, :event => evt, :user => @user, :status => Bet::STATUS_PERFORMED, :money => 10, :odds => 2)
          Factory(:bet, :event => evt, :user => @user, :status => Bet::STATUS_IDLE)
          evt.update_attribute :date, Date.today

          evt2 = Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          Factory(:bet, :event => evt2, :user => @user, :status => Bet::STATUS_IDLE)
          evt2.update_attribute :date, Date.yesterday

          @events = [evt]
        end

        it "should not get any active events" do
          get :index
          assigns(:events).should be_empty
        end

        it "should not get any closing events" do
          get :index
          assigns(:closing_events).should be_empty
        end

        it "should show the running event" do
          get :index
          assigns(:running_events).should == @events
        end

        it "historic should have the event also as is historic" do
          get :history
          assigns(:events).should == @events
        end
      end

      describe "historic events" do
        before(:each) do
          evt1 = Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          Factory(:bet, :event => evt1, :user => @user, :status => Bet::STATUS_IDLE)
          evt1.update_attribute :date, Date.yesterday

          evt2 = Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          Factory(:bet, :event => evt2, :user => @user, :status => Bet::STATUS_LOSER, :money => 10, :odds => 2)
          evt2.update_attribute :date, Date.today

          evt3 = Factory(:event, :name => Factory.next(:name), :user => @user, :date => Date.tomorrow)
          Factory(:bet, :event => evt3, :user => @user, :status => Bet::STATUS_WINNER, :money => 10, :odds => 2, :earned => 20)
          evt3.update_attribute :date, Date.yesterday

          @events = [evt3, evt2]
        end

        it "should not get any active events" do
          get :index
          assigns(:events).should be_empty
        end

        it "should not get any closing events" do
          get :index
          assigns(:closing_events).should be_empty
        end

        it "should not get any running event" do
          get :index
          assigns(:running_events).should be_empty
        end

        it "historic should show the events" do
          get :history
          assigns(:events).should == @events
        end
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