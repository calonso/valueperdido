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

  describe "callbacks" do
    describe "recalculate_percentages" do
      describe "for one user" do
        before(:each) do
          @user.payments.create!(:amount => 100.2)
        end

        it "should give 100% to the first user" do
          @user.reload
          @user.percentage.should == 100
        end

        it "should still give 100% if makes a new payment" do
          @user.payments.create!(:amount => 5)
          @user.reload
          @user.percentage.should == 100
        end
      end

      describe "for various users" do
        before(:each) do
          @user.payments.create!(:amount => 100.2)
          @user2 = Factory(:user, :email => Factory.next(:email))
        end

        it "should be 50% if all same amount" do
          @user2.payments.create!(:amount => 100.2)
          [@user, @user2].each do |usr|
            usr.reload
            usr.percentage.should == 50
          end
        end

        it "should respect the amounts relation" do
          @user2.payments.create!(:amount => 50.1)
          @user.reload
          @user.percentage.round(2).should == 66.67
          @user2.reload
          @user2.percentage.round(2).should == 33.33
        end
      end
    end
  end
end
