class UserMailer < ActionMailer::Base
  default from: "valueperdido@gmail.com"

  def validated_account_email(user)
    @user = user
    @url = login_path
    mail_name = "#{@user.name} #{@user.surname} <#{@user.email}>"
    mail(:to => mail_name, :subject => "Your ValuePerdido account has been verified")
  end
end
