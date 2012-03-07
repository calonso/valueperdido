require 'spec_helper'

describe Payment do
  before(:each) do
    @user = build_valid_user
    @attr = { :amount => 300.50 }
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

    it "should require the user to be validated" do
      @user.update_attribute :validated, false
      invalid_payment = @user.payments.build @attr
      invalid_payment.should_not be_valid
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

  describe "percentage recalculation" do
    describe "percentages" do
      before(:each) do
        @payment = payment_at @user, Time.now, 100.2
      end

      it "should respond to recalculate percentages" do
        @payment.should respond_to :recalculate_percentages
      end

      describe "for one user" do
        it "should give 100% to the first user" do
          @user.reload
          @user.percentage.should == 100
        end

        it "should still give 100% if makes a new payment" do
          payment_at @user, Time.now, 5
          @user.reload
          @user.percentage.should == 100
        end
      end

      describe "for various users" do
        before(:each) do
          @user2 = build_valid_user
          @user3 = build_valid_user
        end

        it "should be 50% if all same amount" do
          payment_at @user2, Time.now, 100.2
          [@user, @user2].each do |usr|
            usr.reload
            usr.percentage.should == 50
          end
          @user3.reload
          @user3.percentage.should == 0
        end

        it "should respect the amounts relation" do
          payment_at @user2, Time.now, 50.1
          @user.reload
          @user.percentage.round(2).should == 66.67
          @user2.reload
          @user2.percentage.round(2).should == 33.33
          @user3.reload
          @user3.percentage.should == 0
        end

        it "should be 0 if no money paid" do
          payment_at @user2, Time.now, 0
          @user.reload
          @user.percentage.round(2).should == 100.0
          @user2.reload
          @user2.percentage.round(2).should == 0.0
          @user3.reload
          @user3.percentage.should == 0
        end
      end
    end
  end
end
