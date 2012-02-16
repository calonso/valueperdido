require 'spec_helper'

describe Message do
  before(:each) do
    @user = Factory(:user)
    @attr = { :message => "This is the text" }
  end

  it "should create an instance given valid attributes" do
    @user.messages.create!(@attr)
  end

  it "should have the right attributes" do
    msg = @user.messages.create(@attr)
    msg.user.should == @user
    msg.user_id.should == @user.id
    msg.message.should == @attr[:message]
  end

  describe "validations" do
    it "should require a user" do
      Message.new(@attr).should_not be_valid
    end

    it "should require a message" do
      invalid_message = @user.messages.build(@attr.merge(:message => ''))
      invalid_message.should_not be_valid
    end

    it "should accept very long messages" do
      valid_message = @user.messages.build(@attr.merge(:message => 'a' * 500))
      valid_message.should be_valid
    end

    it "should create the instance with the very long message" do
      @user.messages.create!(@attr.merge(:message => 'a' * 500))
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

  describe "post summary message task" do
    describe "with data" do
      before(:each) do
        @event = Factory(:event, :user => @user)
        @event.created_at = Date.yesterday + 2.hours
        @event.save!
        Factory(:bet, :user => @user, :event => @event)
        @selected = Factory(:bet, :user => Factory(:user , :email => Factory.next(:email)), :event => @event,
                           :status => Bet::STATUS_PERFORMED, :date_performed => Date.yesterday, :money => 50, :odds => 2.0)
        @winner = Factory(:bet, :user => Factory(:user , :email => Factory.next(:email)), :event => @event,
                           :status => Bet::STATUS_WINNER, :money => 50, :odds => 2.0, :date_performed => Date.today - 2.days,
                           :date_finished => Date.yesterday, :earned => 10.0)
      end

      it "should respond to method" do
        Message.should respond_to(:post_summary_message)
      end

      it "should create a new message" do
        lambda do
          Message.post_summary_message
        end.should change(Message, :count).by(1)
      end

      it "should have the new event" do
        Message.post_summary_message
        msg = Message.last
        msg.message[:events].count.should == 1
        msg.message[:events][0].should == @event
      end

      it "should have the selected bet" do
        Message.post_summary_message
        msg = Message.last
        msg.message[:selected].count.should == 1
        msg.message[:selected][0].should == @selected
      end

      it "should have the winner bet" do
        Message.post_summary_message
        msg = Message.last
        msg.message[:winner].count.should == 1
        msg.message[:winner][0].should == @winner
      end

      it "should have the closing event" do
        Message.post_summary_message
        msg = Message.last
        msg.message[:closing].count.should == 1
        msg.message[:closing][0].should == @event
      end

      it "should be assigned to nil user" do
        Message.post_summary_message
        msg = Message.last
        msg.user.should be_nil
      end
    end
    describe "without data" do
      it "should not create any message" do
        lambda do
          Message.post_summary_message
        end.should_not change(Message, :count)
      end
    end
  end
end
