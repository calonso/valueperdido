require 'spec_helper'

describe AccountSummary do
  describe "summarize method" do
    before(:each) do
      user1 = Factory(:user)
      user2 = Factory(:user, :email => Factory.next(:email))
      user3 = Factory(:user, :email => Factory.next(:email))

      event = Factory(:event, :user => user1)
      event2 = Factory(:event, :user => user1, :name => "name2")

      Factory(:payment, :user => user1)
      Factory(:payment, :user => user2)
      Factory(:payment, :user => user3, :date => Date.yesterday)

      Factory(:bet, :user => user1, :event => event)
      Factory(:bet, :user => user2, :event => event,
              :selected => true, :money => 50, :odds => 2.0,
              :date_selected => Date.today)
      Factory(:bet, :user => user3, :event => event,
              :selected => true, :money => 50, :odds => 2.0,
              :date_selected => Date.yesterday, :winner => true,
              :earned => 100, :date_earned => Date.today)

      Factory(:bet, :user => user1, :event => event2)
      Factory(:bet, :user => user2, :event => event2,
              :selected => true, :money => 50, :odds => 2.0,
              :date_selected => Date.today)
      Factory(:bet, :user => user3, :event => event2,
              :selected => true, :money => 50, :odds => 2.0,
              :date_selected => Date.yesterday, :winner => true,
              :earned => 100, :date_earned => Date.today)
    end

    it "should respond to summarize" do
      AccountSummary.should respond_to(:summarize)
    end

    it "should create a new summarize object" do
      lambda do
        AccountSummary.summarize
      end.should change(AccountSummary, :count).by(1)
    end

    it "should summarize today if no day is specified" do
      AccountSummary.summarize
      summary = AccountSummary.find_by_date(Date.today)
      summary.date.should == Date.today
      summary.incoming.should == 601.0
      summary.bet.should == 100
      summary.earns.should == 200 + 100
    end

    it "should summarize the day specified by parameter" do
      AccountSummary.summarize Date.yesterday
      summary = AccountSummary.find_by_date(Date.yesterday)
      summary.date.should == Date.yesterday
      summary.incoming.should == 300.50
      summary.bet.should == 100
      summary.earns.should == 0
    end

    it "should send the email" do
      AccountSummary.summarize
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should re-summarize when an already summarized day is required" do
      summary = AccountSummary.summarize
      user = Factory(:user, :email => Factory.next(:email))
      payment = Factory(:payment, :user => user)
      sum2 = AccountSummary.summarize
      sum2.id.should == summary.id
      sum2.date.should == summary.date
      sum2.bet.should == summary.bet
      sum2.earns.should == summary.earns
      sum2.incoming.should == summary.incoming + payment.amount
    end

    it "should reuse the existing object when re-summarizing" do
      AccountSummary.summarize
      lambda do
        AccountSummary.summarize
      end.should_not change(AccountSummary, :count)
    end
  end

  describe "full summarize method" do
    before(:each) do
      @user = Factory(:user, :created_at => Date.today - 1.week)
    end

    it "should summarize every day since the first user creation" do
      lambda do
        AccountSummary.full_summarize
      end.should change(AccountSummary, :count).by(8)
    end
  end
end
