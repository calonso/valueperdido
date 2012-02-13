require 'spec_helper'

describe AccountSummary do
  before(:each) do
    @attrs = {
        :date => Date.today,
        :incoming => 100,
        :bet => 100,
        :earns => 100,
        :expenses => 10 }
  end

  it "should create a new instance given valid attributes" do
    AccountSummary.create!(@attrs)
  end

  it "should have the right attributes" do
    summary = AccountSummary.create!(@attrs)
    summary.date.should == @attrs[:date]
    summary.incoming.should == @attrs[:incoming]
    summary.bet.should == @attrs[:bet]
    summary.earns.should == @attrs[:earns]
    summary.expenses.should == @attrs[:expenses]
  end

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

      Factory(:expense)
      Factory(:expense, :date => Date.yesterday)
      Factory(:expense, :date => Date.yesterday)
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
      summary.expenses.should == 10.40
    end

    it "should summarize the day specified by parameter" do
      AccountSummary.summarize Date.yesterday
      summary = AccountSummary.find_by_date(Date.yesterday)
      summary.date.should == Date.yesterday
      summary.incoming.should == 300.50
      summary.bet.should == 100
      summary.earns.should == 0
      summary.expenses.should == 20.80
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
      sum2.expenses.should == summary.expenses
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

  describe "full accounts info method" do
    before(:each) do
      @user = Factory(:user)
      @usr2 = Factory(:user, :name => "Frotacho", :email => Factory.next(:email))
      @event = Factory(:event, :user => @user)
      @bet1 = Factory(:bet, :user => @user, :event => @event,
                      :selected => true, :money => 10, :odds => 1.6,
                      :date_selected => Date.yesterday)
      @bet2 = Factory(:bet, :user => @usr2, :event => @event,
                      :selected => true, :money => 10, :odds => 2.0,
                      :date_selected => Date.today, :winner => true,
                      :earned => 20, :date_earned => Date.tomorrow)
      @pay1 = Factory(:payment, :user => @user, :date => Date.today - 2.days)
      @pay2 = Factory(:payment, :user => @usr2, :date => Date.today)
      @expense = Factory(:expense, :date => Date.tomorrow + 1.day)
    end
    it "should respond to full_accounts_info" do
      AccountSummary.should respond_to(:full_accounts_info)
    end

    it "should retrieve the appropriated data in the right order" do
      data = AccountSummary.full_accounts_info
      data.count.should == 6
      data[0]["id"].to_i.should == @user.id
      data[1]["id"].to_i.should == @event.id
      data[2]["id"].to_i.should == @event.id
      data[3]["id"].to_i.should == @usr2.id
      data[4]["id"].to_i.should == @event.id
      data[5]["id"].to_i.should == 0
    end

    it "should set the right amounts" do
      data = AccountSummary.full_accounts_info
      data[0]["amount"].to_f.should == @pay1.amount
      data[1]["amount"].to_f.should == -1 * @bet1.money
      data[2]["amount"].to_f.should == -1 * @bet2.money
      data[3]["amount"].to_f.should == @pay2.amount
      data[4]["amount"].to_f.should == @bet2.money + @bet2.earned
      data[5]["amount"].to_f.should == -1 * @expense.value
    end

    it "should set the right names" do
      data = AccountSummary.full_accounts_info
      data[0]["name"].should == "#{@user.surname}, #{@user.name}"
      data[1]["name"].should == @bet1.event.name
      data[2]["name"].should == @bet2.event.name
      data[3]["name"].should == "#{@usr2.surname}, #{@usr2.name}"
      data[4]["name"].should == @bet2.event.name
      data[5]["name"].should == @expense.description
    end

    it "should set the right types" do
      data = AccountSummary.full_accounts_info
      data[0]["type"].should == 'payment'
      data[1]["type"].should == 'bet'
      data[2]["type"].should == 'bet'
      data[3]["type"].should == 'payment'
      data[4]["type"].should == 'bet'
      data[5]["type"].should == 'expense'
    end
  end
end
