class UserMailer < ActionMailer::Base
  default from: "valueperdido@gmail.com"

  def user_account_created_email(user)
    @user = user
    mail_name = "#ValuePerdido <valueperdido@gmail.com>"
    mail(:to => mail_name, :subject => "A new account has been created")
  end

  def validated_account_email(user)
    @user = user
    mail_name = "#{@user.name} #{@user.surname} <#{@user.email}>"
    mail(:to => mail_name, :subject => "Your ValuePerdido account has been verified")
  end

  def notify_summarized_day_email(day, result)
    @day = "#{ l day, :locale => :en }"
    @result = result
    mail_name = "#ValuePerdido <valueperdido@gmail.com>"
    mail(:to => mail_name, :subject => "#{@day} summarized")
  end
end
