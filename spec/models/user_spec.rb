# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  surname            :string(255)
#  email              :string(255)
#  admin              :boolean(1)      default(FALSE)
#  validated          :boolean(1)      default(FALSE)
#  encrypted_password :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Example user",
              :surname => "Example surname",
              :email => "user@example.com",
              :password => "thepassword",
              :password_confirmation => "thepassword",
              :terms => "1" }
  end

  it "should create a new instance given valid attributes" do
    User.create! @attr
  end

  it "should have the right attributes" do
    user = User.create @attr
    user.name.should == @attr[:name]
    user.surname.should == @attr[:surname]
    user.email.should == @attr[:email]
    user.encrypted_password.should_not be_blank
  end

  it "should not be an admin by default" do
    user = User.new(@attr)
    user.should_not be_admin
  end

  it "should not be validated by default" do
    user = User.new(@attr)
    user.should_not be_validated
  end

  describe "validations" do
    it "should require a name" do
      invalid_user = User.new(@attr.merge(:name => ''))
      invalid_user.should_not be_valid
    end

    it "should require a surname" do
      invalid_user = User.new(@attr.merge(:surname => ''))
      invalid_user.should_not be_valid
    end

    it "should require an email" do
      invalid_user = User.new(@attr.merge(:email => ''))
      invalid_user.should_not be_valid
    end

    it "should reject too long names" do
      invalid_user = User.new(@attr.merge(:name => 'a' * 46))
      invalid_user.should_not be_valid
    end

    it "should reject too long surnames" do
      invalid_user = User.new(@attr.merge(:surname => 'a' * 46))
      invalid_user.should_not be_valid
    end

    it "should accept valid emails" do
      emails = %w[user@foo.com THE_USER@foo.bar.org the.user@foo.jp]
      emails.each do |address|
        user = User.new(@attr.merge(:email => address))
        user.should be_valid
      end
    end

    it "should reject invalid emails" do
      emails = %w[user@foo,com THE_USER_at_foo.bar.org the.user@foo. user@foo]
      emails.each do |address|
        invalid_user = User.new(@attr.merge(:email => address))
        invalid_user.should_not be_valid
      end
    end

    it "should reject duplicated email addresses" do
      User.create!(@attr)
      invalid_user = User.new(@attr)
      invalid_user.should_not be_valid
    end

    it "should reject email addresses with same up to case" do
      User.create!(@attr)
      invalid_user = User.new(@attr.merge(:email => @attr[:email].upcase))
      invalid_user.should_not be_valid
    end

    it "should require terms to be validated" do
      invalid_user = User.new(@attr.merge(:terms => "0"))
      invalid_user.should_not be_valid
    end
  end

  describe "password validations" do
    it "should require a password" do
      invalid_user = User.new(@attr.merge(:password => '', :password_confirmation => ''))
      invalid_user.should_not be_valid
    end

    it "should require a matching password confirmation" do
      invalid_user = User.new(@attr.merge(:password_confirmation => 'invalid'))
      invalid_user.should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 7
      invalid_user = User.new(@attr.merge(:password => short, :password_confirmation => short))
      invalid_user.should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 46
      invalid_user = User.new(@attr.merge(:password => long, :password_confirmation => long))
      invalid_user.should_not be_valid
    end

    describe "password encryption" do
      before(:each) do
        @user = User.create!(@attr)
      end

      it "should have an encrypted password attribute" do
        @user.should respond_to(:encrypted_password)
      end

      it "should set the encrypted password attribute" do
        @user.encrypted_password.should_not be_blank
      end

      describe "has_password? method" do
        it "should be true if the passwords match" do
          @user.has_password?(@attr[:password]).should be_true
        end

        it "should be false if the passwords don't match" do
          @user.has_password?("invalid").should_not be_true
        end
      end

      describe "authenticate method" do
        it "should return nil on email/password mismatch" do
          wrong_pass_user = User.authenticate(@attr[:email], "wrongpass")
          wrong_pass_user.should be_nil
        end

        it "should return nil for an email with no user" do
          nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
          nonexistent_user.should be_nil
        end

        it "should return nil for a non validated user" do
          not_validated_user = User.authenticate(@attr[:email], @attr[:password])
          not_validated_user.should be_nil
        end

        it "should return the user on email/password match" do
          @user.validated = true
          @user.save!
          matching_user = User.authenticate(@attr[:email], @attr[:password])
          matching_user.should == @user
        end
      end
    end
  end

  describe "events associations" do
    before(:each) do
      @user = User.create!(@attr)
      @event = Factory(:event, :user => @user)
    end

    it "should have an events attribute" do
      @user.should respond_to(:events)
    end

    it "should not destroy associated events" do
      @user.destroy
      Event.find_by_id(@event.id).should_not be_nil
    end
  end

  describe "bets associations" do
    before(:each) do
      @user = User.create!(@attr)
      event = Factory(:event, :user => @user)
      @bet = Factory(:bet, :user => @user, :event => event)
    end

    it "should have a bets attribute" do
      @user.should respond_to(:bets)
    end

    it "should not destroy associated bets" do
      @user.destroy
      Bet.find(@bet.id).should_not be_nil
    end
  end

  describe "votes associations" do
    before(:each) do
      @user = User.create!(@attr)
      event = Factory(:event, :user => @user)
      bet = Factory(:bet, :user => @user, :event => event)
      @vote = Factory(:vote, :user => @user, :event => event, :bet => bet)
    end

    it "should have a votes attribute" do
      @user.should respond_to(:votes)
    end

    it "should destroy associated bets" do
      @user.destroy
      Vote.find_by_id(@vote.id).should be_nil
    end
  end

  describe "payments associations" do
    before(:each) do
      @user = User.create!(@attr)
      @payment = Factory(:payment, :user => @user)
    end

    it "should have a payments attribute" do
      @user.should respond_to(:payments)
    end

    it "should not destroy associated payments" do
      @user.destroy
      Payment.find(@payment.id).should_not be_nil
    end
  end

  describe "messages associations" do
    before(:each) do
      @user = User.create!(@attr)
      @message = Factory(:message, :user => @user)
    end

    it "should have a messages attribute" do
      @user.should respond_to(:messages)
    end

    it "should destroy associated messages" do
      @user.destroy
      Message.find_by_id(@message.id).should be_nil
    end
  end
end
