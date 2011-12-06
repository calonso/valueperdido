# == Schema Information
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  surname    :string(255)
#  email      :string(255)
#  admin      :boolean(1)
#  validated   :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Example user",
              :surname => "Example surname",
              :email => "user@example.com"}
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
end
