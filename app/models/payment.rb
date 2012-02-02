class Payment < ActiveRecord::Base
  attr_accessible :amount, :date

  belongs_to :user

  validates :user_id, :presence => true
  validates :amount, :presence => true,
                     :numericality => true
  validates :date, :presence => true,
                   :date => {:after => Date.civil(1980, 1, 1), :message => "Invalid date"}

  default_scope :order => 'payments.date DESC'

  after_save :summarize_if_before_today

  def summarize_if_before_today
    AccountSummary.summarize date if date < Date.today
  end

end
