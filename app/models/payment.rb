class Payment < ActiveRecord::Base
  attr_accessible :amount, :date

  belongs_to :user

  validates :user_id, :presence => true
  validates :amount, :presence => true,
                     :numericality => true
  validates :date, :presence => true,
                   :date => {:after => Date.civil(1980, 1, 1), :message => "Invalid date"}

  default_scope :order => 'payments.date DESC'

  def self.full_accounts_info
    data = self.connection.execute(sanitize_sql ["
      (SELECT user_id as id, date, amount, surname||', '||name as name, 'payment' as type FROM payments p
        INNER JOIN users u on p.user_id = u.id)
      UNION ALL
      (SELECT b.id, date,
                  CASE WHEN winner=TRUE THEN money * rate
                  ELSE -money
                  END, name, 'bet' FROM bets b
        INNER JOIN events e on b.event_id = e.id where b.selected = TRUE)
      "]).to_a
    data.sort! { |a, b| a["date"] <=> b["date"] }
  end
end
