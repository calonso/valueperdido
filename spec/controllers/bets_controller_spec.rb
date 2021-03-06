require 'spec_helper'

describe BetsController do
  render_views
  before(:each) do
    @user = build_valid_user
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

  describe "for passive users" do
    before(:each) do
      @user.update_attribute :passive, true

      user2 = build_not_valid_user
      @bet = Factory(:bet, :user => user2, :event => @event)

      test_login @user
    end

    it "should allow the 'index' action" do
      get :index, :event_id => @event
      response.should be_success
    end

    it "should protect the 'new' action" do
      get :new, :event_id => @event
      response.should redirect_to root_path
    end

    it "should protect the 'create' action" do
      post :create, :event_id => @event, :bet => @attr
      response.should redirect_to root_path
    end

    it "should protect the 'user_bets' action" do
      get :event_user_bets, :event_id => @event
      response.should redirect_to root_path
    end

    it "should protect the 'vote' action" do
      get :vote, :event_id => @event, :id => @bet
      response.should redirect_to root_path
    end

    it "should protect the 'unvote' action" do
      get :unvote, :event_id => @event, :id => @bet
      response.should redirect_to root_path
    end

    it "should allow the 'show' action" do
      get :show, :event_id => @event, :id => @bet
      response.should be_success
    end

    it "should protect the 'edit' action" do
      get :edit, :event_id => @event, :id => @bet
      response.should redirect_to root_path
    end

    it "should protect the 'update' action" do
      put :update, :event_id => @event, :id => @bet, :event => @attr
      response.should redirect_to root_path
    end

    it "should protect the 'destroy' action" do
      delete :destroy, :event_id => @event, :id => @bet
      response.should redirect_to root_path
    end
  end

  describe "for logged users" do
    before(:each) do
      @sec_user = build_valid_user
      @bets = []
      @bet = Factory(:bet, :user => @user, :event => @event)
      @bets << @bet
      @not_owned_bet = Factory(:bet, :user => @sec_user, :event => @event)
      @bets << @not_owned_bet

      sec_evt = Factory(:event, :name => Factory.next(:name), :user => @user)
      Factory(:bet, :user => @user, :event => sec_evt)
      Factory(:bet, :user => @sec_user, :event => sec_evt)
      test_login @user
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
        before(:each) do
          Valueperdido::Application.config.max_bets_per_user-1.times do
            Factory(:bet, :user => @user, :event => @event)
          end
        end

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
        before(:each) do
          Valueperdido::Application.config.max_bets_per_user-1.times do
            Factory(:bet, :user => @user, :event => @event)
          end
        end
        
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
          @user.update_attribute :admin, true
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
                  :status => Bet::STATUS_PERFORMED,
                  :money => 1.1,
                  :odds => 1.67}
      end

      describe "for non admin users" do
        it "should deny access" do
          put :update, :event_id => @event, :id => @bet, :bet => @attr
          response.should redirect_to(root_path)
        end
      end

      describe "for admin users" do
        before(:each) do
          @user.update_attribute :admin, true
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
                     :status => @bet.status,
                     :money => @bet.money,
                     :odds => @bet.odds,
                     :earned => @bet.earned }
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            @bet.reload
            @bet.title.should == prev[:title]
            @bet.description.should == prev[:description]
            @bet.status.should == prev[:status]
            @bet.money.should == prev[:money]
            @bet.odds.should == prev[:odds]
            @bet.earned.should == prev[:earned]
          end
        end

        describe "success" do
          it "should change the bet's attributes" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            @bet.reload
            @bet.title.should == @attr[:title]
            @bet.description.should == @attr[:description]
            @bet.status.should == @attr[:status]
            @bet.money.should == @attr[:money]
            @bet.odds.should == @attr[:odds]
          end

          it "should redirect to the bet's show path" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            response.should redirect_to event_bet_path(@event, @bet)
          end

          it "should display a flash message" do
            put :update, :event_id => @event, :id => @bet, :bet => @attr
            flash[:success].should =~ /successfully/i
          end

          describe "participants handle" do
            before(:each) do
              @users = []
              @users << @user
              @users << @sec_user
            end

            it "should assign all participants" do
              put :update, :event_id => @event, :id => @bet, :bet => @attr
              @bet.reload
              @bet.participants.sort.should == @users.sort
            end

            it "should create a new BetParticipant register for each participant" do
              lambda do
                put :update, :event_id => @event, :id => @bet, :bet => @attr
              end.should change(BetParticipant, :count).by(@users.count)
            end
          end

          describe "percentage recalculation at result" do
            before(:each) do
              @user.update_attribute :validated, true
              @user2 = build_valid_user
              @user3 = build_valid_user
              payment_at @user, Date.yesterday - 1.day
              payment_at @user2, Date.yesterday - 1.day
              payment_at @user3, Date.tomorrow
              @bet.participants = User.validated
              @bet.update_attributes!(:status => Bet::STATUS_PERFORMED, :money => 10.0, :odds => 2.0)
              @bet.update_attribute(:date_performed, Date.yesterday)
            end

            it "should not recalculate if no user paid" do
              put :update, :event_id => @event, :id => @bet, :bet => @bet.attributes.merge(:status => Bet::STATUS_WINNER, :earned => 18.5)
              [@user, @user2, @user3].each do |usr|
                usr.reload
                usr.percentage.round(5).should == 33.33333
              end
            end

            it "should recalculate if any user paid" do
              a_user = build_valid_user
              payment_at a_user, Date.today

              total = AccountSummary.total_money
              total += @bet.money + 18.5
              put :update, :event_id => @event, :id => @bet, :bet => @bet.attributes.merge(:status => Bet::STATUS_WINNER, :earned => 18.5)
              [@user, @user2, @user3].each do |usr|
                usr.reload
                usr.percentage.round(5).should == (((300.5 + (18.5 / 3)) / total) * 100).round(5)
              end
              a_user.reload
              a_user.percentage.round(5).should == ((300.5 / total) * 100).round(5)
            end
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
