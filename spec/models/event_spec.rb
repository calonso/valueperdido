require 'spec_helper'

describe Event do

  before(:each) do
    @user = build_valid_user
    @attr = {
        :name => "Event name",
        :date => Date.today,
    }
  end

  it "should create a new instance given valid attributes" do
    @user.events.create!(@attr)
  end

  it "should have the right attributes" do
    event = @user.events.create(@attr)
    event.user.should == @user
    event.user_id.should == @user.id
    event.name.should == @attr[:name]
    event.date.should == @attr[:date]
  end

  describe "user associations" do
    before(:each) do
      @event = @user.events.create(@attr)
    end

    it "should have an user attribute" do
      @event.should respond_to(:user)
    end

    it "should have the right associated user" do
      @event.user_id.should == @user.id
      @event.user.should == @user
    end
  end

  describe "validations" do
    it "should not require a user id" do
      Event.new(@attr).should be_valid
    end

    it "should require a non-blank name" do
      invalid_event = @user.events.build(@attr.merge(:name => ''))
      invalid_event.should_not be_valid
    end

    it "should require a date" do
      invalid_event = @user.events.build(@attr.merge(:date => nil))
      invalid_event.should_not be_valid
    end

    it "should require a valid date" do
      invalid_event = @user.events.build(@attr.merge(:date => "aaa"))
      invalid_event.should_not be_valid
    end

    it "should reject long names" do
      invalid_event = @user.events.build(@attr.merge(:name => "a" * 46))
      invalid_event.should_not be_valid
    end

    it "should reject same names on same dates" do
      @user.events.create(@attr)
      sec_event = @user.events.create(@attr)
      sec_event.should_not be_valid
    end

    it "should accept same names on different dates" do
      @user.events.create(@attr)
      sec_event = @user.events.create(@attr.merge(:date => Date.today + 1.day))
      sec_event.should be_valid
    end
  end

  describe "scopes" do
    before(:each) do
      @with_finished_bets = Factory(:event, :user => @user)
      Factory(:bet, :user => @user, :event => @with_finished_bets,
                    :status => Bet::STATUS_LOSER, :money => 10.0, :odds => 1.1)
      @with_finished_bets.update_attribute :date, Date.yesterday

      @past_with_bets = Factory(:event, :user => @user)
      Factory(:bet, :user => @user, :event => @past_with_bets,
              :status => Bet::STATUS_PERFORMED, :money => 10.0, :odds => 1.1)
      @past_with_bets.update_attribute :date, Date.yesterday - 1.day

      past2 = Factory(:event, :user => @user)
      Factory(:bet, :user => @user, :event => past2)
      past2.update_attribute :date, Date.yesterday

      @past = Factory(:event, :user => @user, :date => Date.today)
      @closing = Factory(:event, :user => @user, :date => Date.tomorrow)
      @future = Factory(:event, :user => @user, :date => Date.tomorrow + 1.day)
    end

    describe "closing scope" do
      it "should respond to closing_events scope" do
        Event.should respond_to(:closing_events)
      end

      it "should retrieve only closing events" do
        Event.closing_events.should == [@closing]
      end
    end

    describe "active scope" do
      it "should respond to active_events scope" do
        Event.should respond_to(:active_events)
      end

      it "should retrieve only active events" do
        Event.active_events.should == [@future]
      end
    end

    describe "past scope" do
      it "should respond to past_events scope" do
        Event.should respond_to(:past_events)
      end

      it "should retrieve only the past events and those with performed bets" do
        Event.past_events.should == [@past, @with_finished_bets]
      end
    end

    describe "running scope" do
      it "should respond to running_events scope" do
        Event.should respond_to(:running_events)
      end

      it "should retrieve the running events" do
        Event.running_events.should == [@past_with_bets]
      end
    end
  end

  describe "is active method" do
    it "should say no to a past event" do
      @event = Factory(:event, :user => @user, :date => Date.today)
      @event.should_not be_active
    end

    it "should say yes to a future event" do
      @event = Factory(:event, :user => @user, :date => Date.tomorrow)
      @event.should be_active
    end
  end

  describe "bets associations" do
    before(:each) do
      @event = Factory(:event, :user => @user)
      @bet = Factory(:bet, :user => @user, :event => @event)
    end

    it "should have a bets attribute" do
      @event.should respond_to(:bets)
    end

    it "should destroy associated bets" do
      @event.destroy
      Bet.find_by_id(@bet.id).should be_nil
    end
  end

  describe "votes associations" do
    before(:each) do
      @event = Factory(:event, :user => @user)
      bet = Factory(:bet, :user => @user, :event => @event)
      @vote = Factory(:vote, :user => @user, :event => @event, :bet => bet)
    end

    it "should have a votes attribute" do
      @event.should respond_to(:votes)
    end

    it "should indirectly destroy associated votes" do
      @event.destroy
      Vote.find_by_id(@vote.id).should be_nil
    end
  end
end
