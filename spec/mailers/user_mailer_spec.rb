require "spec_helper"

describe UserMailer do
  before(:each) do
    @user = Factory(:user)
  end

  it "should send the mail" do
    UserMailer.validated_account_email(@user).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
end
