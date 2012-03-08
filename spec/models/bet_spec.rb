require 'spec_helper'

describe Bet do
  before(:each) do
    @user = build_valid_user
    @event = Factory(:event, :user => @user)
    @attr = { :title => "The title",
              :description => "This is the description",
              :event_id => @event.id }
  end

  it "should define STATUS_IDLE constant" do
    Bet::STATUS_IDLE.should_not be_nil
  end

  it "should define STATUS_PERFORMED constant" do
    Bet::STATUS_PERFORMED.should_not be_nil
  end

  it "should define STATUS_LOSER constant" do
    Bet::STATUS_LOSER.should_not be_nil
  end

  it "should define STATUS_WINNER constant" do
    Bet::STATUS_WINNER.should_not be_nil
  end

  it "should create a new instance given valid attributes" do
    @user.bets.create!(@attr)
  end

  it "should have the right attributes" do
    bet = @user.bets.create(@attr)
    bet.user.should == @user
    bet.user_id.should == @user.id
    bet.title.should == @attr[:title]
    bet.description.should == @attr[:description]
    bet.event.should == @event
    bet.event_id.should == @event.id
  end

  it "should be idle by default" do
    bet = @user.bets.create(@attr)
    bet.should_not be_performed
  end

  describe "associations" do
    before(:each) do
      @bet = @user.bets.create(@attr)
    end

    it "should have an user attribute" do
      @bet.should respond_to(:user)
    end

    it "should have the right associated user" do
      @bet.user.id.should == @user.id
      @bet.user.should == @user
    end

    it "should have an event attribute" do
      @bet.should respond_to(:event)
    end

    it "should have the right associated event" do
      @bet.event.id.should == @event.id
      @bet.event.should == @event
    end
  end

  describe "validations" do
    it "should require a title" do
      invalid_bet = @user.bets.build(@attr.merge(:title => ""))
      invalid_bet.should_not be_valid
    end

    it "should reject too long titles" do
      invalid_bet = @user.bets.build(@attr.merge(:title => "a" * 46))
      invalid_bet.should_not be_valid
    end

    it "should require a description" do
      invalid_bet = @user.bets.build(@attr.merge(:description => ""))
      invalid_bet.should_not be_valid
    end

    it "should require an event" do
      invalid_bet = @user.bets.build(@attr.merge(:event_id => nil))
      invalid_bet.should_not be_valid
    end

    it "should require an active event" do
      closed_event = Factory(:event, :user => @user, :date => Date.yesterday)
      invalid_bet = @user.bets.build(@attr.merge(:event_id => closed_event.id))
      invalid_bet.should_not be_valid
    end

    it "should reject invalid money amounts" do
      invalid_bet = @user.bets.build(@attr.merge(:money => "a01.1"))
      invalid_bet.should_not be_valid
    end

    it "should reject invalid odds amounts" do
      invalid_bet = @user.bets.build(@attr.merge(:odds => "a01.1"))
      invalid_bet.should_not be_valid
    end

    it "should accept valid money amounts" do
      valid_nums = %w[1000 1.000 999.0]
      valid_nums.each do |num|
        valid_bet = @user.bets.build(@attr.merge(:money => num))
        valid_bet.should be_valid
      end
    end

    it "should accept valid odds amounts" do
      valid_nums = %w[1000 1.000 999.0]
      valid_nums.each do |num|
        valid_bet = @user.bets.build(@attr.merge(:odds => num))
        valid_bet.should be_valid
      end
    end

    it "should reject invalid earned amounts" do
      invalid_bet = @user.bets.build(@attr.merge(:earned => "a01.1"))
      invalid_bet.should_not be_valid
    end

    it "should accept valid earned amounts" do
      valid_nums = %w[1000 1.000 999.0]
      valid_nums.each do |num|
        valid_bet = @user.bets.build(@attr.merge(:earned => num))
        valid_bet.should be_valid
      end
    end

    it "should reject more than max bets per user and event" do
      max = Valueperdido::Application.config.max_bets_per_user
      max.times { @user.bets.create!(@attr)}
      extra_bet = @user.bets.build(@attr)
      extra_bet.should_not be_valid
    end

    it "should reject invalid status values" do
      invalid_bet = @user.bets.build(@attr.merge(:status => 'invalid_status'))
      invalid_bet.should_not be_valid
    end

    it "should accept valid status values" do
      statuses = [Bet::STATUS_IDLE, Bet::STATUS_PERFORMED, Bet::STATUS_LOSER, Bet::STATUS_WINNER]
      statuses.each do |status|
        valid_bet = @user.bets.build(@attr.merge(:status => status, :money => 1.0, :odds => 1.0, :earned => 1.0))
        valid_bet.should be_valid
      end
    end

    it "should require a money amount if selected" do
      invalid_bet = @user.bets.build(@attr.merge(:status => Bet::STATUS_PERFORMED, :odds => 1.1))
      invalid_bet.should_not be_valid
    end

    it "should require an odds amount if selected" do
      invalid_bet = @user.bets.build(@attr.merge(:status => Bet::STATUS_PERFORMED, :money => 5))
      invalid_bet.should_not be_valid
    end

    it "should require an earned amount if winner" do
      select_hash = { :status => Bet::STATUS_WINNER, :money => 5, :odds => 1.6 , :winner => true }
      invalid_bet = @user.bets.build(@attr.merge(select_hash))
      invalid_bet.should_not be_valid
    end

    describe "non editable attrs if performed" do
      before(:each) do
        @bet = Factory(:bet, :user => @user, :event => @event,
                       :status => Bet::STATUS_PERFORMED, :money => 10,
                       :odds => 2.0, :date_performed => Date.today)
      end

      it "should not allow to edit the status back to idle" do
        @bet.status = Bet::STATUS_IDLE
        @bet.should_not be_valid
      end

      it "should not allow to edit the money attribute" do
        @bet.money = 5
        @bet.should_not be_valid
      end

      it "should not allow to edit the odds attribute" do
        @bet.odds = 1.1
        @bet.should_not be_valid
      end
    end
    describe "non editable attrs if finished" do
      before(:each) do
        @bet = Factory(:bet, :user => @user, :event => @event,
                       :status => Bet::STATUS_WINNER, :money => 10,
                       :odds => 2.0, :date_performed => Date.today,
                       :earned => 10, :date_finished => Date.today)
      end

      it "should not allow to edit the status attribute" do
        @bet.status = Bet::STATUS_LOSER
        @bet.should_not be_valid
      end

      it "should not allow to edit the earned attribute" do
        @bet.earned = 5
        @bet.should_not be_valid
      end
    end
  end

  describe "scopes" do
    describe "performed scope" do
      before(:each) do
        sec_user = build_valid_user
        sec_user.bets.create!(@attr)
        @sel_bet = @user.bets.create!(@attr.merge(:status => Bet::STATUS_PERFORMED, :money => 1.0, :odds => 1.5))
        third_user = build_valid_user
        @loser_bet = third_user.bets.create!(@attr.merge(:status => Bet::STATUS_LOSER, :money => 1.0, :odds => 1.1, :earned => 0.0))
        fourth_user = build_valid_user
        @winner_bet = fourth_user.bets.create!(@attr.merge(:status => Bet::STATUS_WINNER, :money => 1.0, :odds => 1.1, :earned => 10.0))
      end

      it "should have the performed scope" do
        Bet.should respond_to(:performed)
      end

      it "should retrieve performed, winner and loser bets" do
        Bet.performed.should == [@winner_bet, @loser_bet, @sel_bet]
      end
    end

    describe "votes info scope" do
      before(:each) do
        bet = @user.bets.create!(@attr)
        sec_user = build_valid_user
        Factory(:vote, :event => @event, :bet => bet, :user => @user)
        Factory(:vote, :event => @event, :bet => bet, :user => sec_user)
      end

      it "should respond to the with votes info for event scope" do
        Bet.should respond_to(:with_votes_for_event)
      end

      it "should retrieve the bet with the votes and author info" do
        bets = Bet.with_votes_for_event(@event, @user.id)
        bets.count.should == 1
        bet = bets[0]
        bet["title"].should == @attr[:title]
        bet["votes"].to_i.should == 2
        bet["voted"].to_i.should == 1
        bet["status"].should == Bet::STATUS_IDLE
        bet["user_id"].to_i.should == @user.id
        bet["author"].should == "#{@user.name} #{@user.surname}"
      end
    end
  end

  describe "votes association" do
    before(:each) do
      @bet = Factory(:bet, :user => @user, :event => @event)
      @vote = Factory(:vote, :user => @user, :event => @event, :bet => @bet)
    end

    it "should have a votes attribute" do
      @bet.should respond_to(:votes)
    end

    it "should assign the right votes" do
      @bet.votes.should == [@vote]
    end

    it "should destroy associated votes" do
      @bet.destroy
      Vote.find_by_id(@vote.id).should be_nil
    end
  end

  describe "callbacks" do
    describe "set_dates callback" do
      before(:each) do
        @bet = Factory(:bet, :event => @event, :user => @user)
      end

      it "should have performed date to nil" do
        @bet.date_performed.should be_nil
      end

      it "should have finished date to nil" do
        @bet.date_finished.should be_nil
      end

      it "should set the performed date upon performance" do
        @bet.update_attributes(:status => Bet::STATUS_PERFORMED, :money => 5, :odds => 2.0)
        @bet.reload
        @bet.date_performed.should == Date.today
      end

      describe "with a selected bet" do
        before(:each) do
          @bet.update_attributes( :status => Bet::STATUS_PERFORMED, :money => 5, :odds => 2 )
        end

        it "should set the finished date upon winning" do
          @bet.update_attributes(:status => Bet::STATUS_WINNER, :earned => 20)
          @bet.reload
          @bet.date_finished.should == Date.today
        end

        it "should set the finished date upon losing" do
          @bet.update_attributes(:status => Bet::STATUS_LOSER)
          @bet.reload
          @bet.date_finished.should == Date.today
        end

        it "should keep the performed date upon winning" do
          performed_date = @bet.date_performed
          @bet.update_attributes(:status => Bet::STATUS_WINNER, :earned => 20)
          @bet.reload
          @bet.date_performed.should == performed_date
        end

        it "should keep the performed date upon losing" do
          performed_date = @bet.date_performed
          @bet.update_attributes(:status => Bet::STATUS_LOSER)
          @bet.reload
          @bet.date_performed.should == performed_date
        end
      end
    end
  end

  describe "participants association" do
    before(:each) do
      @bet = Factory(:bet, :user => @user, :event => @event)
    end

    it "should have the participants attribute" do
      @bet.should respond_to :participants
    end

    it "should create a new BetParticipant object" do
      lambda do
        @bet.participants = [@user]
      end.should change(BetParticipant, :count).by(1)
    end

    it "should assign the right participants" do
      @bet.participants = [@user]
      @bet.reload
      @bet.participants.should == [@user]
    end
  end
end
