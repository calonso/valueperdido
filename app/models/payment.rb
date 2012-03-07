class Payment < ActiveRecord::Base
  attr_accessible :amount

  belongs_to :user

  validates :user_id, :presence => true
  validates :amount, :presence => true,
                     :numericality => true
  validate  :user_validated

  default_scope :order => 'payments.created_at DESC, payments.id DESC'

  def recalculate_percentages
    total = AccountSummary.total_money
    total -= self.amount
    User.validated.each do |user|
      user_amount = total * user.percentage / 100
      user_amount += self.amount if user == self.user
      user.percentage = (user_amount / (total + self.amount)) * 100
      user.save!
    end
  end

  protected
  def user_validated
    unless self.user && self.user.validated?
      errors.add(:user, "The user is not validated")
    end
  end
end
