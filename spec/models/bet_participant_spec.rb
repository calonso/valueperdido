require 'spec_helper'

describe BetParticipant do
  before(:each) do
    @user = build_valid_user
    payment_at @user
    @user.reload #Reload so that the user gets the percentage calculated
    event = Factory(:event, :user => @user)
    @bet = Factory(:bet, :event => event, :user => @user)
  end

  describe "callbacks" do
    describe "set percentage" do
      before(:each) do
        @bet.participants = [@user]
      end

      it "should have set the percentage" do
        BetParticipant.all.each do |part|
          part.percentage.should == part.user.percentage
        end
      end
    end
  end

  describe "associations" do
    before(:each) do
      @bet.participants = [@user]
    end
    it "should have user attribute" do
      BetParticipant.all.each do |part|
        part.should respond_to :user
      end
    end

    it "should have bet attribute" do
      BetParticipant.all.each do |part|
        part.should respond_to :bet
      end
    end
  end
end
