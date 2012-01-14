require 'spec_helper'

describe Message do
  before(:each) do
    @user = Factory(:user)
    @attr = { :message => "This is the text" }
  end

  it "should create an instance given valid attributes" do
    @user.messages.create!(@attr)
  end

  describe "validations" do
    it "should require a user" do
      Message.new(@attr).should_not be_valid
    end

    it "should require a message" do
      invalid_message = @user.messages.build(@attr.merge(:message => ''))
      invalid_message.should_not be_valid
    end
  end

  describe "associations" do
    before(:each) do
      @message = Factory(:message, :user => @user)
    end

    it "should have an user attribute" do
      @message.should respond_to(:user)
    end

    it "should have the right associated user" do
      @message.user_id.should == @user.id
      @message.user.should == @user
    end
  end
end
