class AccountSummary < ActiveRecord::Base

  default_scope :order => 'date ASC'

  def self.full_accounts_info
    data = self.connection.execute(sanitize_sql ["
      (SELECT user_id as id, date, amount, surname||', '||name as name, 'payment' as type FROM payments p
        INNER JOIN users u on p.user_id = u.id)
      UNION ALL
      (SELECT b.event_id, date,
                  CASE WHEN winner=TRUE THEN earned
                  ELSE -money
                  END, name, 'bet' FROM bets b
        INNER JOIN events e on b.event_id = e.id where b.selected = TRUE)
      UNION ALL
      (SELECT 0, date, -value, description, 'expense' FROM expenses)
      "]).to_a
    data.sort! { |a, b| a["date"] <=> b["date"] }
  end

  def self.summarize(day=Date.today)
    payments = Payment.sum(:amount, :conditions => ["date = ?", day])
    bets = Bet.sum(:money, :conditions => ["selected = true AND date_selected = ?", day])
    earns = Bet.sum("earned + money", :conditions => ["winner = true AND date_earned = ?", day])
    expenses = Expense.sum(:value, :conditions => ["date = ?", day])

    summary = AccountSummary.find_or_create_by_date(day)
    summary.attributes = { :incoming => payments, :bet => bets, :earns => earns, :expenses => expenses }
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
