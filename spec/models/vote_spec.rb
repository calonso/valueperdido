require 'spec_helper'

describe Vote do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event, :user => @user)
    bet = Factory(:bet, :user => @user, :event => @event)
    @attr = {
        :event => @event,
        :bet => bet
    }
  end

  it "should create a new instance given valid attributes" do
    @user.votes.create!(@attr)
  end

  it "should have the right attributes" do
    vote = @user.votes.create(@attr)
    vote.user.should == @user
    vote.user_id.should == @user.id
    vote.event.should == @event
    vote.event_id.should == @event.id
    vote.bet.should == @attr[:bet]
    vote.bet_id.should == @attr[:bet].id
  end

  describe "validations" do
    it "should require an event" do
      invalid_vote = @user.votes.build(@attr.merge(:event => nil))
      invalid_vote.should_not be_valid
    end

    it "should require a bet" do
      invalid_vote = @user.votes.build(@attr.merge(:bet => nil))
      invalid_vote.should_not be_valid
    end

    it "should reject more than max votes per event allowed" do
      max = Valueperdido::Application.config.max_votes_per_user
      max.times {
        usr = Factory(:user, :email => Factory.next(:email))
        bet = Factory(:bet, :user => usr, :event => @event)
        @user.votes.create!(@attr.merge(:bet => bet))
      }
      extra_vote = @user.votes.build(@attr)
      extra_vote.should_not be_valid
    end

    it "should reject a vote to an already voted bet" do
      @user.votes.create!(@attr)
      repeated = @user.votes.build(@attr)
      repeated.should_not be_valid
    end
  end

  describe "associations" do
    before(:each) do
      @vote = @user.votes.create!(@attr)
    end

    it "should have an user attribute" do
      @vote.should respond_to(:user)
    end

    it "should have the right associated user" do
      @vote.user.should == @user
      @vote.user_id.should == @user.id
    end

    it "should have an event attribute" do
      @vote.should respond_to(:event)
    end

    it "should have the right associated event" do
      @vote.event_id.should == @attr[:event].id
      @vote.event.should == @attr[:event]
    end

    it "should have a bet attribute" do
      @vote.should respond_to(:bet)
    end

    it "should have the right associated bet" do
      @vote.bet_id.should == @attr[:bet].id
      @vote.bet.should == @attr[:bet]
    end
  end

end
