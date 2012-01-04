class Event < ActiveRecord::Base
  attr_accessible :name, :date

  belongs_to :user
  has_many :bets, :dependent => :destroy

  validates :name,  :presence => true,
                    :length => { :maximum => 45 },
                    :uniqueness => { :scope => :date }
  validates :date, :date => {:after => Date.civil(1980, 1, 1), :message => "Must be after today!"},
                   :on => :create

  scope :active_events, lambda { where("date > ?", Date.today) }
end
