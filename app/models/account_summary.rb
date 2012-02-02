class AccountSummary < ActiveRecord::Base

  default_scope :order => 'date ASC'

  def self.summarize(day=Date.today)
    payments = Payment.sum(:amount, :conditions => ["date = ?", day])
    bets = Bet.sum(:money, :conditions => ["selected = true AND date_selected = ?", day])
    earns = Bet.sum("earned + money", :conditions => ["winner = true AND date_earned = ?", day])

    summary = AccountSummary.find_or_create_by_date(day)
    summary.attributes = { :incoming => payments, :bet => bets, :earns => earns }
    if summary.save
      UserMailer.notify_summarized_day_email(day, true).deliver
    else
      UserMailer.notify_summarized_day_email(day, false).deliver
    end
    return summary
  end

  def self.full_summarize
    first_user = User.first
    (first_user.created_at.to_date..Date.yesterday).each do |day|
      AccountSummary.summarize day
    end
  end
end
