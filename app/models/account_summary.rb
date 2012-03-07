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
      (SELECT 0, created_at, -value, description, 'expense', 0 FROM expenses)
      ", Bet::STATUS_IDLE, Bet::STATUS_WINNER, Bet::STATUS_WINNER, Bet::STATUS_LOSER, Bet::STATUS_LOSER]).to_a
    data.sort! { |a, b| a["date"] <=> b["date"] }
  end

  def self.total_money
    data = self.connection.execute(sanitize_sql ["
    SELECT SUM(qty) AS total FROM
      (SELECT SUM(amount) AS qty FROM payments AS p INNER JOIN users AS u on p.user_id = u.id WHERE validated = true
      UNION
      SELECT -SUM(money) FROM bets WHERE status IN (?, ?)
      UNION
      SELECT SUM(earned) FROM bets WHERE status = ?
      UNION
      SELECT -SUM(value) FROM expenses) AS gr
    ", Bet::STATUS_PERFORMED, Bet::STATUS_LOSER, Bet::STATUS_WINNER])
    data[0]["total"].to_f
  end

#  def self.total_money(day=Date.today)
#      data = self.connection.execute(sanitize_sql ["
#      SELECT SUM(qty) AS total FROM
#      (SELECT SUM(amount) AS qty FROM payments AS p INNER JOIN users AS u on p.user_id = u.id WHERE validated = true AND CAST(created_at AS date) <= ?
#      UNION
#      SELECT -SUM(money) FROM bets WHERE (status != ? AND date_performed <= ? AND (date_finished IS NU
#      UNION
#      SELECT SUM(earned) FROM bets WHERE status = ? AND date_finished <= ?
#      UNION
#      SELECT -SUM(value) FROM expenses WHERE date <= ?) AS gr
#      ", day, Bet::STATUS_IDLE, day, day, Bet::STATUS_LOSER, day, Bet::STATUS_WINNER, day, day])
#       data[0]["total"].to_f
#  end

  def self.summarize(day=Date.today, email=true)
    last_sum = AccountSummary.find_by_date(day - 1.day)
    payments = Payment.sum(:amount, :conditions => ["CAST(created_at as DATE) = ?", day])
    bets = Bet.sum(:money, :conditions => ["status != ? AND date_performed = ?", Bet::STATUS_IDLE, day])
    earns = Bet.sum("earned + money", :conditions => ["status = ? AND date_finished = ?", Bet::STATUS_WINNER, day]).to_f
    expenses = Expense.sum(:value, :conditions => ["CAST(created_at as DATE) = ?", day])
    total = payments - bets + earns - expenses + (last_sum ? last_sum.total : 0)

    summary = AccountSummary.find_or_create_by_date(day)
    summary.attributes = { :incoming => payments, :bet => bets, :earns => earns, :expenses => expenses, :total => total }
    if summary.save
      UserMailer.notify_summarized_day_email(day, true).deliver if email
      return summary
    else
      UserMailer.notify_summarized_day_email(day, false).deliver if email
      return nil
    end
  end

  def self.full_summarize
    first_user = User.first
    AccountSummary.transaction do
      (first_user.created_at.to_date..Date.yesterday).each do |day|
        unless AccountSummary.summarize day, false
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
