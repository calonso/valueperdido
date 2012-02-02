require 'spec_helper'

describe Bet do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event, :user => @user)
    @attr = { :title => "The title",
              :description => "This is the description",
              :event_id => @event.id }
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

  it "should not be selected by default" do
    bet = @user.bets.create(@attr)
    bet.should_not be_selected
  end

  it "should not be winner by default" do
    bet = @user.bets.create(@attr)
    bet.should_not be_winner
  end

  describe "associations" do
    before(:each) do
      @bet = @user.bets.create(@attr)
    end

    it "should have an user attribute" do
      @bet.should respond_to(:user)
    end

    it "should have the right associated user" do
      @bet.user_id.should == @user.id
      @bet.user.should == @user
    end

    it "should have an event attribute" do
      @bet.should respond_to(:event)
    end

    it "should have the right associated event" do
      @bet.event_id.should == @event.id
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
      second_bet = @user.bets.build(@attr)
      second_bet.should_not be_valid
    end

    it "should require a money amount if selected" do
      invalid_bet = @user.bets.build(@attr.merge(:selected => true, :odds => 1.1))
      invalid_bet.should_not be_valid
    end

    it "should require an odds amount if selected" do
      invalid_bet = @user.bets.build(@attr.merge(:selected => true, :money => 5))
      invalid_bet.should_not be_valid
    end

    it "should require an earned amount if winner" do
      select_hash = { :selected => true, :money => 5, :odds => 1.6 , :winner => true }
      invalid_bet = @user.bets.build(@attr.merge(select_hash))
      invalid_bet.should_not be_valid
    end

    describe "non editable attrs if selected" do
      before(:each) do
        @bet = Factory(:bet, :user => @user, :event => @event,
                       :selected => true, :money => 10, :odds => 2.0,
                       :date_selected => Date.today)
      end

      it "should not allow to edit the selected attribute" do
        @bet.selected = false
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
    describe "non editable attrs if winner" do
      before(:each) do
        @bet = Factory(:bet, :user => @user, :event => @event,
                       :selected => true, :money => 10, :odds => 2.0,
                       :date_selected => Date.today, :winner => true,
                       :earned => 10, :date_earned => Date.today)
      end

      it "should not allow to edit the winner attribute" do
        @bet.winner = false
        @bet.should_not be_valid
      end

      it "should not allow to edit the earned attribute" do
        @bet.earned = 5
        @bet.should_not be_valid
      end
    end
  end

  describe "scopes" do
    describe "selected scope" do
      before(:each) do
        sec_user = Factory(:user, :email => Factory.next(:email))
        sec_user.bets.create!(@attr)
        @sel_bet = @user.bets.create!(@attr.merge(:selected => true, :money => 1.0, :odds => 1.5))
      end

      it "should have the selected scope" do
        Bet.should respond_to(:selected)
      end

      it "should retrieve selected bets" do
        Bet.selected.should == [@sel_bet]
      end
    end

    describe "votes info scope" do
      before(:each) do
        bet = @user.bets.create!(@attr)
        sec_user = Factory(:user, :email => Factory.next(:email))
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
        bet["selected"].should == "f"
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

    it "should destroy associated votes" do
      @bet.destroy
      Vote.find_by_id(@vote.id).should be_nil
    end
  end

  describe "callbacks" do
    before(:each) do
      @bet = Factory(:bet, :event => @event, :user => @user)
    end

    it "should have selected date to nil" do
      @bet.date_selected.should be_nil
    end

    it "should have earned date to nil" do
      @bet.date_earned.should be_nil
    end

    it "should set the selected date upon selection" do
      @bet.update_attributes(:selected => true, :money => 5, :odds => 2.0)
      @bet.reload
      @bet.date_selected.should == Date.today
    end

    describe "with a selected bet" do
      before(:each) do
        @bet.update_attributes( :selected => true, :money => 5, :odds => 2 )
      end

      it "should set the earned date upon earning" do
        @bet.update_attributes(:winner => true, :earned => 20)
        @bet.reload
        @bet.date_earned.should == Date.today
      end
    end
  end
end
