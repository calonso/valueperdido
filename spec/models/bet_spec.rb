require 'spec_helper'

describe Bet do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event, :user => @user)
    @attr = { :description => "This is the description",
              :event => @event}
  end

  it "should create a new instance given valid attributes" do
    @user.bets.create!(@attr)
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
    it "should require a description" do
      invalid_bet = @user.bets.build(@attr.merge(:description => ""))
      invalid_bet.should_not be_valid
    end

    it "should require an event" do
      invalid_bet = @user.bets.build(@attr.merge(:event => nil))
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
  end

end
