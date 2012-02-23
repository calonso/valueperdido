class AccountSummary < ActiveRecord::Base

  default_scope :order => 'date ASC'

  def self.full_accounts_info
    data = self.connection.execute(sanitize_sql ["
      (SELECT user_id as id, p.created_at as date, amount, surname||', '||name as name, 'payment' as type, 0 as extra FROM payments p
        INNER JOIN users u on p.user_id = u.id)
      UNION ALL
      (SELECT id, date_performed, -money, title, 'bet', event_id FROM bets
          where status != ? and (date_finished IS NULL OR date_performed != date_finished))
      UNION ALL
      (SELECT id, date_finished, earned + money, title, 'bet', event_id FROM bets
        where status = ? and date_finished != date_performed)
      UNION ALL
      (SELECT id, date_finished, earned, title, 'bet', event_id FROM bets
        where status = ? and date_finished = date_performed)
      UNION ALL
      (SELECT id, date_finished, 0.0, title, 'bet', event_id FROM bets
        where status = ? and date_finished != date_performed)
      UNION ALL
      (SELECT id, date_finished, -money, title, 'bet', event_id FROM bets
        where status = ? and date_finished = date_performed)
      UNION ALL
      (SELECT 0, date, -value, description, 'expense', 0 FROM expenses)
      ", Bet::STATUS_IDLE, Bet::STATUS_WINNER, Bet::STATUS_WINNER, Bet::STATUS_LOSER, Bet::STATUS_LOSER]).to_a
    data.sort! { |a, b| a["date"] <=> b["date"] }
  end

  def self.total_money(day=Date.today)
    data = self.connection.execute(sanitize_sql ["
    SELECT SUM(qty) AS total FROM
      (SELECT SUM(amount) AS qty FROM payments WHERE CAST(created_at AS date) <= ?
      UNION
      SELECT -SUM(money) FROM bets WHERE (status != ? AND date_performed <= ? AND (date_finished IS NULL OR date_finished > ?)) OR (status = ? AND date_finished <= ?)
      UNION
      SELECT SUM(earned) FROM bets WHERE status = ? AND date_finished <= ?
      UNION
      SELECT -SUM(value) FROM expenses WHERE date <= ?) AS gr
    ", day, Bet::STATUS_IDLE, day, day, Bet::STATUS_LOSER, day, Bet::STATUS_WINNER, day, day])
    data[0]["total"].to_f
  end

  def self.summarize(day=Date.today)
    payments = Payment.sum(:amount, :conditions => ["CAST(created_at as DATE) = ?", day])
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
