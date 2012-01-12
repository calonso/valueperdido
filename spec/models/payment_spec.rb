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
    before(:each) do
      @usr2 = Factory(:user, :name => "Frotacho", :email => Factory.next(:email))
      @event = Factory(:event, :user => @user, :date => Date.yesterday)
      @bet1 = Factory(:bet, :user => @user, :event => @event,
                      :selected => true, :money => 10)
      @bet2 = Factory(:bet, :user => @usr2, :event => @event,
                      :selected => true, :money => 10,
                      :winner => true, :rate => 2)
      @pay1 = Factory(:payment, :user => @user, :date => Date.today - 2.days)
      @pay2 = Factory(:payment, :user => @usr2, :date => Date.today)
    end
    it "should respond to full_accounts_info" do
      Payment.should respond_to(:full_accounts_info)
    end

    it "should retrieve the appropriated data in the right order" do
      data = Payment.full_accounts_info
      data.count.should == 4
      data[0][0].should == @user.id
      data[1][0].should == @bet1.id
      data[2][0].should == @bet2.id
      data[3][0].should == @usr2.id
    end

    it "should set the right amounts" do
      data = Payment.full_accounts_info
      data[0][2].should == @pay1.amount
      data[1][2].should == -1 * @bet1.money
      data[2][2].should == @bet2.money * @bet2.rate
      data[3][2].should == @pay2.amount
    end

    it "should set the right names" do
      data = Payment.full_accounts_info
      data[0][3].should == "#{@user.surname}, #{@user.name}"
      data[1][3].should == @bet1.event.name
      data[2][3].should == @bet2.event.name
      data[3][3].should == "#{@usr2.surname}, #{@usr2.name}"
    end

    it "should set the right types" do
      data = Payment.full_accounts_info
      data[0][4].should == 'payment'
      data[1][4].should == 'bet'
      data[2][4].should == 'bet'
      data[3][4].should == 'payment'
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