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
      event3 = Factory(:event, :user => user1, :name => "name3")

      Factory(:payment, :user => user1)
      Factory(:payment, :user => user2)
      Factory(:payment, :user => user3, :date => Date.yesterday)

      Factory(:bet, :user => user1, :event => event)
      Factory(:bet, :user => user2, :event => event,
              :status => Bet::STATUS_PERFORMED, :money => 50,
              :odds => 2.0, :date_performed => Date.today)
      Factory(:bet, :user => user3, :event => event,
              :status => Bet::STATUS_WINNER, :money => 50,
              :odds => 2.0, :date_performed => Date.yesterday,
              :earned => 100, :date_finished => Date.today)

      Factory(:bet, :user => user1, :event => event2)
      Factory(:bet, :user => user2, :event => event2,
              :status => Bet::STATUS_PERFORMED, :money => 50,
              :odds => 2.0, :date_performed => Date.today)
      Factory(:bet, :user => user3, :event => event2,
              :status => Bet::STATUS_WINNER, :money => 50,
              :odds => 2.0, :date_performed => Date.yesterday,
              :earned => 100, :date_finished => Date.today)
      Factory(:bet, :user => user1, :event => event3,
              :status => Bet::STATUS_LOSER, :money => 50,
              :odds => 2.0, :date_performed => Date.yesterday)

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
      summary.bet.should == 150
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
      @usr2 = Factory(:user, :name => Factory.next(:name), :email => Factory.next(:email))
      @event = Factory(:event, :user => @user)
    end

    it "should respond to full_accounts_info" do
      AccountSummary.should respond_to(:full_accounts_info)
    end

    describe "for payments" do
      before(:each) do
        @pay1 = Factory(:payment, :user => @user)
        @pay2 = Factory(:payment, :user => @usr2, :date => Date.tomorrow)
      end

      it "should retrieve the payments in the appropriate order" do
        data = AccountSummary.full_accounts_info
        data.count.should == 2
        data[0]["id"].to_i.should == @user.id
        data[1]["id"].to_i.should == @usr2.id
      end

      it "should have the right amounts" do
        data = AccountSummary.full_accounts_info
        data[0]["amount"].to_f.should == @pay1.amount
        data[1]["amount"].to_f.should == @pay2.amount
      end

      it "should set the right names" do
        data = AccountSummary.full_accounts_info
        data[0]["name"].should == "#{@user.surname}, #{@user.name}"
        data[1]["name"].should == "#{@usr2.surname}, #{@usr2.name}"
      end

      it "should set the right types" do
        data = AccountSummary.full_accounts_info
        data[0]["type"].should == 'payment'
        data[1]["type"].should == 'payment'
      end

      it "should set the right extra" do
        data = AccountSummary.full_accounts_info
        data[0]["extra"].to_i.should == 0
        data[1]["extra"].to_i.should == 0
      end
    end

    describe "for performed and long term bets" do
      before(:each) do
        @usr3 = Factory(:user, :name => Factory.next(:name), :email => Factory.next(:email))
        @performed = Factory(:bet, :user => @user, :event => @event,
                             :status => Bet::STATUS_PERFORMED, :money => 10,
                             :odds => 1.6, :date_performed => Date.yesterday - 3.days)
        @lt_winner = Factory(:bet, :user => @usr2, :event => @event,
                             :status => Bet::STATUS_WINNER, :money => 10,
                             :odds => 1.6, :date_performed => Date.yesterday - 2.days,
                             :date_finished => Date.yesterday, :earned => 16)
        @lt_loser = Factory(:bet, :user => @usr3, :event => @event,
                            :status => Bet::STATUS_LOSER, :money => 10,
                            :odds => 1.6, :date_performed => Date.yesterday - 1.day,
                            :date_finished => Date.today)
      end

      it "should retrieve the bets in the appropriate order" do
        data = AccountSummary.full_accounts_info
        data.count.should == 5
        data[0]["id"].to_i.should == @performed.id
        data[1]["id"].to_i.should == @lt_winner.id
        data[2]["id"].to_i.should == @lt_loser.id
        data[3]["id"].to_i.should == @lt_winner.id
        data[4]["id"].to_i.should == @lt_loser.id
      end

      it "should have the right amounts" do
        data = AccountSummary.full_accounts_info
        data[0]["amount"].to_f.should == -@performed.money
        data[1]["amount"].to_f.should == -@lt_winner.money
        data[2]["amount"].to_f.should == -@lt_loser.money
        data[3]["amount"].to_f.should == @lt_winner.money + @lt_winner.earned
        data[4]["amount"].to_f.should == 0.0
      end

      it "should have the right names" do
        data = AccountSummary.full_accounts_info
        data[0]["name"].should == @performed.title
        data[1]["name"].should == @lt_winner.title
        data[2]["name"].should == @lt_loser.title
        data[3]["name"].should == @lt_winner.title
        data[4]["name"].should == @lt_loser.title
      end

      it "should have the right types" do
        data = AccountSummary.full_accounts_info
        (0..4).each do |i|
          data[i]["type"].should == 'bet'
        end
      end

      it "should set the right extra" do
        data = AccountSummary.full_accounts_info
        data[0]["extra"].to_i.should == @performed.event_id
        data[1]["extra"].to_i.should == @lt_winner.event_id
        data[2]["extra"].to_i.should == @lt_loser.event_id
        data[3]["extra"].to_i.should == @lt_winner.event_id
        data[4]["extra"].to_i.should == @lt_loser.event_id
      end
    end

    describe "for same days bets" do
      before(:each) do
        @winner = Factory(:bet, :user => @user, :event => @event,
                          :status => Bet::STATUS_WINNER, :money => 10,
                          :odds => 1.6, :date_performed => Date.yesterday,
                          :date_finished => Date.yesterday, :earned => 16)
        @loser = Factory(:bet, :user => @usr2, :event => @event,
                         :status => Bet::STATUS_LOSER, :money => 10,
                         :odds => 1.6, :date_performed => Date.today,
                         :date_finished => Date.today)
      end

      it "should retrieve the bets in the appropriate order" do
        data = AccountSummary.full_accounts_info
        data.count.should == 2
        data[0]["id"].to_i.should == @winner.id
        data[1]["id"].to_i.should == @loser.id
      end

      it "should have the right amounts" do
        data = AccountSummary.full_accounts_info
        data[0]["amount"].to_f.should == @winner.earned
        data[1]["amount"].to_f.should == -@loser.money
      end

      it "should have the right names" do
        data = AccountSummary.full_accounts_info
        data[0]["name"].should == @winner.title
        data[1]["name"].should == @loser.title
      end

      it "should set the right types" do
        data = AccountSummary.full_accounts_info
        data[0]["type"].should == 'bet'
        data[1]["type"].should == 'bet'
      end

      it "should set the right extra" do
        data = AccountSummary.full_accounts_info
        data[0]["extra"].to_i.should == @winner.event_id
        data[1]["extra"].to_i.should == @loser.event_id
      end
    end

    describe "for expenses" do
      before(:each) do
        @expense1 = Factory(:expense)
        @expense2 = Factory(:expense, :value => 40, :date => Date.tomorrow)
      end

      it "should retrieve the bets in the appropriate order" do
        data = AccountSummary.full_accounts_info
        data.count.should == 2
        data[0]["id"].to_i.should == 0
        data[1]["id"].to_i.should == 0
      end

      it "should have the right amounts" do
        data = AccountSummary.full_accounts_info
        data[0]["amount"].to_f.should == -@expense1.value
        data[1]["amount"].to_f.should == -@expense2.value
      end

      it "should have the right names" do
        data = AccountSummary.full_accounts_info
        data[0]["name"].should == @expense1.description
        data[1]["name"].should == @expense2.description
      end

      it "should set the right types" do
        data = AccountSummary.full_accounts_info
        data[0]["type"].should == 'expense'
        data[1]["type"].should == 'expense'
      end

      it "should set the right extra" do
        data = AccountSummary.full_accounts_info
        data[0]["extra"].to_i.should == 0
        data[1]["extra"].to_i.should == 0
      end
    end
  end
end
