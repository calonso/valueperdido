class Event < ActiveRecord::Base
  attr_accessible :name, :date

  belongs_to :user
  has_many :bets, :dependent => :destroy
  has_many :votes

  validates :name,  :presence => true,
                    :length => { :maximum => 45 },
                    :uniqueness => { :scope => :date }
  validates :date, :date => {:after => Date.civil(1980, 1, 1), :message => "Must be a valid date!"},
                   :on => :create

  default_scope :order => "events.date ASC"

  scope :closing_events, lambda { where("date = ?", Date.tomorrow)}
  scope :active_events, lambda { where("date > ?", Date.tomorrow) }
  scope :running_events, lambda { Event.includes(:bets).where("bets.status = ?", Bet::STATUS_PERFORMED).uniq }

  def self.past_events
    Event.unscoped.includes(:bets).where("date = ? or (date < ? and bets.status IN (?, ?))", Date.today, Date.today, Bet::STATUS_WINNER, Bet::STATUS_LOSER).order("date DESC").uniq
  end

  def active?
    self.date > Date.today
  end
end
