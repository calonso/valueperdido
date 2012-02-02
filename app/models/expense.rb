class Expense < ActiveRecord::Base
  attr_accessible :date, :value, :description

  validates :date, :presence => true,
                   :date => {:after => Date.civil(1980, 1, 1), :message => "Invalid date"}
  validates :value, :presence => true,
                    :numericality => true
  validates :description, :presence => true, :length => { :maximum => 255 }

  after_save :summarize_if_before_today

  def summarize_if_before_today
    AccountSummary.summarize date if date < Date.today
  end

end
