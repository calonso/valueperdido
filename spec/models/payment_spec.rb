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
    before (:each) do
      @usr2 = Factory(:user, :email => Factory.next(:email))
      @event = Factory(:event, :user => @user)
      @bet1 = Factory(:bet, :user => @user, :event => @event,
                      :selected => true, :money => 10)
      @bet2 = Factory(:bet, :user => @usr2, :event => @event,
                      :selected => true, :money => 10,
                      :winner => true, :rate => 2)
      @pay1 = Factory(:payment, :user => @user)
      @pay2 = Factory(:payment, :user => @usr2)
    end
    it "should respond to full_accounts_info" do
      Payment.should respond_to(:full_accounts_info)
    end

    it "should retrieve the appropriated data" do
      data = Payment.full_accounts_info
      data.count.should == 4

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
