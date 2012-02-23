class Payment < ActiveRecord::Base
  attr_accessible :amount

  belongs_to :user

  validates :user_id, :presence => true
  validates :amount, :presence => true,
                     :numericality => true

  default_scope :order => 'payments.created_at DESC'

  before_create :recalculate_percentages

  def recalculate_percentages
    total = AccountSummary.total_money
    User.all.each do |user|
      user_amount = total * user.percentage / 100
      user_amount += self.amount if user == self.user
      user.percentage = (user_amount / (total + self.amount)) * 100
      user.save!
    end
  end
end
