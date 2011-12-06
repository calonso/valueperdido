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
              :password_confirmation => "thepassword"}
  end

  it "should create a new instance given valid attributes" do
    User.create! @attr
  end

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

  it "should not be an admin by default" do
    user = User.new(@attr)
    user.should_not be_admin
  end

  it "should not be validated by default" do
    user = User.new(@attr)
    user.should_not be_validated
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

        it "should return the user on email/password match" do
          matching_user = User.authenticate(@attr[:email], @attr[:password])
          matching_user.should == @user
        end
      end
    end

  end
end
