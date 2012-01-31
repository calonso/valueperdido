require 'spec_helper'

describe Payment do
  before(:each) do
    @user = Factory(:user)
    @attr = { :amount => 300.50,
              :date => Date.today }
  end

  it "should create an instance given valid attributes" do
    @user.payments.create!(@attr)
  end

  it "should have the right attributes" do
    payment = @user.payments.create(@attr)
    payment.user.should == @user
    payment.user_id.should == @user.id
    payment.amount.should == @attr[:amount]
    payment.date.should == @attr[:date]
  end

  describe "validations" do
    it "should require a user" do
      Payment.new(@attr).should_not be_valid
    end

    it "should require an amount" do
      invalid_payment = @user.payments.build(@attr.merge(:amount => nil))
      invalid_payment.should_not be_valid
    end

    it "should reject invalid amounts" do
      invalid_amounts = %w[300,50 ,123 a300 200a.1]
      invalid_amounts.each do |amount|
        invalid_payment = @user.payments.build(@attr.merge(:amount => amount))
        invalid_payment.should_not be_valid
      end
    end

    it "should require a date" do
      invalid_payment = @user.payments.build(@attr.merge(:date => nil))
      invalid_payment.should_not be_valid
    end

    it "should reject invalid dates" do
      invalid_payment = @user.payments.build(@attr.merge(:date => "aaa"))
      invalid_payment.should_not be_valid
    end
  end

  describe "full accounts info method" do
    before(:each) do
      @usr2 = Factory(:user, :name => "Frotacho", :email => Factory.next(:email))
      @event = Factory(:event, :user => @user)
      @bet1 = Factory(:bet, :user => @user, :event => @event,
                      :selected => true, :money => 10, :odds => 1.6)
      @bet2 = Factory(:bet, :user => @usr2, :event => @event,
                      :selected => true, :money => 10, :odds => 2.0,
                      :winner => true, :earned => 20)
      @event[:date] = Date.yesterday
      @event.save!
      @pay1 = Factory(:payment, :user => @user, :date => Date.today - 2.days)
      @pay2 = Factory(:payment, :user => @usr2, :date => Date.today)
    end
    it "should respond to full_accounts_info" do
      Payment.should respond_to(:full_accounts_info)
    end

    it "should retrieve the appropriated data in the right order" do
      data = Payment.full_accounts_info
      data.count.should == 4
      data[0]["id"].to_i.should == @user.id
      data[1]["id"].to_i.should == @event.id
      data[2]["id"].to_i.should == @event.id
      data[3]["id"].to_i.should == @usr2.id
    end

    it "should set the right amounts" do
      data = Payment.full_accounts_info
      data[0]["amount"].to_f.should == @pay1.amount
      data[1]["amount"].to_f.should == @bet2.earned
      data[2]["amount"].to_f.should == -1 * @bet1.money
      data[3]["amount"].to_f.should == @pay2.amount
    end

    it "should set the right names" do
      data = Payment.full_accounts_info
      data[0]["name"].should == "#{@user.surname}, #{@user.name}"
      data[1]["name"].should == @bet2.event.name
      data[2]["name"].should == @bet1.event.name
      data[3]["name"].should == "#{@usr2.surname}, #{@usr2.name}"
    end

    it "should set the right types" do
      data = Payment.full_accounts_info
      data[0]["type"].should == 'payment'
      data[1]["type"].should == 'bet'
      data[2]["type"].should == 'bet'
      data[3]["type"].should == 'payment'
    end
  end

  describe "user association" do
    before(:each) do
      @payment = @user.payments.create(@attr)
    end
    it "should have an user attribute" do
      @payment.should respond_to(:user)
    end

    it "should have the right associated user" do
      @payment.user_id.should == @user.id
      @payment.user.should == @user
    end
  end
end
