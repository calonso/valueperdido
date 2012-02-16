class AccountSummary < ActiveRecord::Base

  default_scope :order => 'date ASC'

  def self.full_accounts_info
    data = self.connection.execute(sanitize_sql ["
      (SELECT user_id as id, date, amount, surname||', '||name as name, 'payment' as type FROM payments p
        INNER JOIN users u on p.user_id = u.id)
      UNION ALL
      (SELECT b.event_id, date_performed, -money, name, 'bet' FROM bets b
        inner join events e on b.event_id = e.id where status != ?)
      UNION ALL
      (SELECT b.event_id, date_finished, earned + money, name, 'bet' FROM bets b
        inner join events e on b.event_id = e.id where status = ?)
      UNION ALL
      (SELECT b.event_id, date_finished, 0.0, name, 'bet' FROM bets b
        inner join events e on b.event_id = e.id where status = ?)
      UNION ALL
      (SELECT 0, date, -value, description, 'expense' FROM expenses)
      ", Bet::STATUS_IDLE, Bet::STATUS_WINNER, Bet::STATUS_LOSER]).to_a
    data.sort! { |a, b| a["date"] <=> b["date"] }
  end

  def self.summarize(day=Date.today)
    payments = Payment.sum(:amount, :conditions => ["date = ?", day])
    bets = Bet.sum(:money, :conditions => ["status != ? AND date_performed = ?", Bet::STATUS_IDLE, day])
    earns = Bet.sum("earned + money", :conditions => ["status = ? AND date_finished = ?", Bet::STATUS_WINNER, day])
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
