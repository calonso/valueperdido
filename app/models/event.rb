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

  default_scope :order => "events.created_at DESC"
  scope :active_events, lambda { where("date > ?", Date.today) }
  scope :past_events, lambda { where("date <= ?", Date.today) }

  def active?
    self.date > Date.today
  end
end
