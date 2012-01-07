class Bet < ActiveRecord::Base
  attr_accessible :title, :description, :selected, :winner, :money, :rate, :event

  belongs_to :user
  belongs_to :event
  has_many :votes, :dependent => :destroy

  validates :title, :presence => true,
                    :length => { :maximum => 45 }
  validates :description, :presence => true
  validates :event_id, :presence => true
  validates :money, :numericality => true
  validates :rate, :numericality => true
  validate :no_more_than_max_bets_per_user

  scope :selected, where(:selected => true)

  def no_more_than_max_bets_per_user
    bets = Bet.where("user_id = ? AND event_id = ?", user, event)
    if bets.count >= Valueperdido::Application.config.max_bets_per_user
      errors.add(:event, "You already made max bets for this event")
    end
  end
end
