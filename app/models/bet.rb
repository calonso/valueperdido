class Bet < ActiveRecord::Base
  attr_accessible :description, :selected, :winner, :money, :rate, :event

  belongs_to :user
  belongs_to :event

  validates :description, :presence => true
  validates :event_id, :presence => true
  validates :money, :numericality => true
  validates :rate, :numericality => true

  scope :selected, where(:selected => true)
end
