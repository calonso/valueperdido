require "spec_helper"

describe UserMailer do
  before(:each) do
    @user = Factory(:user)
  end

  it "should send email when new account is created" do
    UserMailer.user_account_created_email(@user).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should send email when account is validated" do
    UserMailer.validated_account_email(@user).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should send email when day is summarized" do
    UserMailer.notify_summarized_day_email(Date.today, true).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

end
