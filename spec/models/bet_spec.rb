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

    it "should reject invalid rate amounts" do
      invalid_bet = @user.bets.build(@attr.merge(:rate => "a01.1"))
      invalid_bet.should_not be_valid
    end

    it "should accept valid money amounts" do
      valid_nums = %w[1000 1.000 999.0]
      valid_nums.each do |num|
        valid_bet = @user.bets.build(@attr.merge(:money => num))
        valid_bet.should be_valid
      end
    end

    it "should accept valid rate amounts" do
      valid_nums = %w[1000 1.000 999.0]
      valid_nums.each do |num|
        valid_bet = @user.bets.build(@attr.merge(:rate => num))
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
      invalid_bet = @user.bets.build(@attr.merge(:selected => true))
      invalid_bet.should_not be_valid
    end

    it "should require a rate amount if winner" do
      invalid_bet = @user.bets.build(@attr.merge(:winner => true))
      invalid_bet.should_not be_valid
    end
  end

  describe "scopes" do
    describe "selected scope" do
      before(:each) do
        sec_user = Factory(:user, :email => Factory.next(:email))
        sec_user.bets.create!(@attr)
        @sel_bet = @user.bets.create!(@attr.merge(:selected => true, :money => 1.0))
      end

      it "should have the selected scope" do
        Bet.should respond_to(:selected)
      end

      it "should retrieve selected scopes" do
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

end
