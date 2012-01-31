require 'spec_helper'

describe BetsController do
  render_views
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event, :user => @user)
    @attr = { :title => "The title",
              :description => "This is the description",
              :event_id => @event}
  end

  describe "for non logged users" do
    before(:each) do
      @bet = Factory(:bet, :user => @user, :event => @event)
    end
    
    it "should protect the 'index' action" do
      get :index, :event_id => @event
      response.should redirect_to(login_path)
    end

    it "should protect the 'new' action" do
      get :new, :event_id => @event
      response.should redirect_to(login_path)
    end

    it "should protect the 'create' action" do
      post :create, :event_id => @event, :bet => @attr
      response.should redirect_to(login_path)
    end

    it "should protect the 'user_bets' action" do
      get :event_user_bets, :event_id => @event
      response.should redirect_to(login_path)
    end

    it "should protect the 'vote' action" do
      get :vote, :event_id => @event, :id => @bet
      response.should redirect_to(login_path)
    end

    it "should protect the 'unvote' action" do
      get :unvote, :event_id => @event, :id => @bet
      response.should redirect_to(login_path)
    end

    it "should protect the 'show' action" do
      get :show, :event_id => @event, :id => @bet
      response.should redirect_to(login_path)
    end

    it "should protect the 'edit' action" do
      get :edit, :event_id => @event, :id => @bet
      response.should redirect_to(login_path)
    end

    it "should protect the 'update' action" do
      put :update, :event_id => @event, :id => @bet, :event => @attr
      response.should redirect_to(login_path)
    end

    it "should protect the 'destroy' action" do
      delete :destroy, :event_id => @event, :id => @bet
      response.should redirect_to(login_path)
    end
  end

  describe "for logged users" do
    before(:each) do
      sec_user = Factory(:user, :email => Factory.next(:email))
      @bets = []
      @bet = Factory(:bet, :user => @user, :event => @event)
      @bets << @bet
      @not_owned_bet = Factory(:bet, :user => sec_user, :event => @event)
      @bets << @not_owned_bet

      sec_evt = Factory(:event, :name => Factory.next(:name), :user => @user)
      Factory(:bet, :user => @user, :event => sec_evt)
      Factory(:bet, :user => sec_user, :event => sec_evt)
      test_login(@user)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get :index, :event_id => @event
        response.should be_success
      end

      it "should only retrieve bets belonging to the requested event" do
        get :index, :event_id => @event
        assigns(:bets).each do |bet|
          @bets.any? { |original|
            bet["id"].to_i == original.id && bet["title"] == original.title
          }.should be_true
        end
      end
    end

    describe "GET 'new'" do
      describe "for user with no other bet created" do
        before(:each) do
          @bet.destroy
        end

        it "should be successful" do
          get :new, :event_id => @event
          response.should be_success
        end

        it "should render the 'new' template" do
          get :new, :event_id => @event
          response.should render_template('new')
        end
      end

      describe "for users with other bets created" do
        it "should redirect to the user's bets page" do
          get :new, :event_id => @event
          response.should redirect_to event_user_bets_path(@event)
        end

      end
    end

    describe "POST 'create'" do
      describe "for user with no other bet created" do
        before(:each) do
          @bet.destroy
        end

        describe "success" do
          it "should create a new bet" do
            lambda do
              post :create, :event_id => @event, :bet => @attr
            end.should change(Bet, :count).by(1)
          end

          it "should redirect to the event bets path" do
            post :create, :event_id => @event, :bet => @attr
            response.should redirect_to event_bets_path
          end

          it "should have a flash message" do
            post :create, :event_id => @event, :bet => @attr
            flash[:success].should =~ /successfully/i
          end
        end

        describe "failure" do
          before(:each) do
            @attr = @attr.merge(:title => "")
          end

          it "should not create a bet" do
            lambda do
              post :create, :event_id => @event, :bet => @attr
            end.should_not change(Bet, :count)
          end

          it "should render the new page again" do
            post :create, :event_id => @event, :bet => @attr
            response.should render_template('new')
          end
        end
      end

      describe "for user with other bets created" do
        it "should not create a bet" do
          lambda do
            post :create, :event_id => @event, :bet => @attr
          end.should_not change(Bet, :count)
        end

        it "should render the 'list' template" do
          get :new, :event_id => @event
          response.should redirect_to event_user_bets_path(@event)
        end

      end
    end

    describe "GET 'event user bets'" do
      it "should be success" do
        get :event_user_bets, :event_id => @event
        response.should be_success
      end

      it "should retrieve the logged user's bets for the required event" do
        get :event_user_bets, :event_id => @event
        assigns(:bets).should == [@bet]
      end
    end

    describe "GET 'show'" do
      it "should be success" do
        get :show, :event_id => @event, :id => @bet
        response.should be_success
      end

      it "should find the required bet" do
        get :show, :event_id => @event, :id => @bet
        assigns(:bet).should == @bet
      end
    end

    describe "GET 'edit'" do
      describe "for non admin users" do
        it "should deny access" do
          get :edit, :event_id => @event, :id => @bet
          response.should redirect_to(root_path)
        end
      end

      describe "for admin users" do
        before(:each) do
          @user.admin = true
        end

        it "should be success" do
          get :edit, :event_id => @event, :id => @bet
          response.should be_success
        end

        it "should find the right bet" do
          get :edit, :event_id => @event, :id => @bet
          assigns(:bet).should == @bet
        end
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        @attr = { :title => "The new title",
                  :description => "The new description",
                  :selected => true,
                  :money => 1.1,
                  :odds => 1.67,
                  :winner => true,
                  :earned => 40}
      end

      describe "for non admin users" do
        it "should deny access" do
          put :update, :event_id => @event, :id => @bet, :bet => @attr
          response.should redirect_to(root_path)
        end
      end

      describe "for admin users" do
        before(:each) do
          @user.admin = true
        end

        describe "failure" do
          before(:each) do
            @attr = @attr.merge(:title => "")
          end
          it "should re-render the edit page" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            response.should render_template('edit')
          end
          it "should not change the bet's attributes" do
            prev = { :title => @bet.title,
                     :description => @bet.description,
                     :selected => @bet.selected,
                     :money => @bet.money,
                     :odds => @bet.odds,
                     :winner => @bet.winner,
                     :earned => @bet.earned }
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            @bet.reload
            @bet.title.should == prev[:title]
            @bet.description.should == prev[:description]
            @bet.selected.should == prev[:selected]
            @bet.money.should == prev[:money]
            @bet.odds.should == prev[:odds]
            @bet.winner.should == prev[:winner]
            @bet.earned.should == prev[:earned]
          end
        end

        describe "success" do
          it "should change the bet's attributes" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            @bet.reload
            @bet.title.should == @attr[:title]
            @bet.description.should == @attr[:description]
            @bet.selected.should == @attr[:selected]
            @bet.money.should == @attr[:money]
            @bet.odds.should == @attr[:odds]
            @bet.winner.should == @attr[:winner]
            @bet.earned.should == @attr[:earned]
          end

          it "should redirect to the bet's show path" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            response.should redirect_to event_bet_path(@event, @bet)
          end

          it "should display a flash message" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            flash[:success].should =~ /successfully/i
          end
        end
      end
    end

    describe "DELETE 'destroy'" do
      describe "for not the owner" do
        it "should block the operation" do
          delete :destroy, :event_id => @event, :id => @not_owned_bet
          response.should redirect_to(root_path)
        end

        it "should not delete the bet" do
          lambda do
            delete :destroy, :event_id => @event, :id => @not_owned_bet
          end.should_not change(Bet, :count)
        end
      end

      describe "for the owner user" do
        it "should destroy the bet" do
          lambda do
            delete :destroy, :event_id => @event, :id => @bet
          end.should change(Bet, :count).by(-1)
        end

        it "should redirect to the user's bets page" do
          delete :destroy, :event_id => @event, :id => @bet
          response.should redirect_to event_user_bets_path(@event)
        end

        it "should have a flash message" do
          delete :destroy, :event_id => @event, :id => @bet
          flash[:success].should =~ /successfully/i
        end
      end
    end

    describe "GET 'vote'" do
      it "should add a vote for the bet" do
        lambda do
          get :vote, :event_id => @event, :id => @bet
        end.should change(@bet.votes, :count).by(1)
      end

      it "should have a flash message" do
        get :vote, :event_id => @event, :id => @bet
        flash[:success].should =~ /successfully/i
      end
    end

    describe "GET 'unvote'" do
      describe "when the vote exists" do
        before(:each) do
          @user.votes.create({ :event => @event, :bet => @bet })
        end

        it "should remove the vote for the bet" do
          lambda do
            get :unvote, :event_id => @event, :id => @bet
          end.should change(@bet.votes, :count).by(-1)
        end

        it "should have a flash message" do
          get :unvote, :event_id => @event, :id => @bet
          flash[:success].should =~ /successfully/i
        end
      end

      describe "when the vote doesn't exist'" do
        it "should not remove any votes" do
          lambda do
            get :unvote, :event_id => @event, :id => @bet
          end.should_not change(@bet.votes, :count)
        end

        it "should have a flash message" do
          get :unvote, :event_id => @event, :id => @bet
          flash[:error].should =~ /found/i
        end
      end
    end
  end
end
