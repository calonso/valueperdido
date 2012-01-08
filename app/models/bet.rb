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
  validate :no_more_than_max_bets_per_user, :on => :create

  scope :selected, where(:selected => true)
  
  def self.with_votes_for_event(evt, usr)
    self.connection.execute(sanitize_sql ["
      SELECT id, title, IFNULL(votes, 0) as votes, user FROM bets b
      left outer join (SELECT bet_id, count(*) as votes FROM votes group by bet_id) as v on b.id = v.bet_id
      left outer join (SELECT bet_id, 1 as user from votes where user_id = ? and event_id = ?) as usr on usr.bet_id = b.id
      where event_id = ? order by votes desc", usr, evt, evt]).to_a
  end

  def no_more_than_max_bets_per_user
    bets = Bet.where("user_id = ? AND event_id = ?", user, event)
    if bets.count >= Valueperdido::Application.config.max_bets_per_user
      errors.add(:event, "You already made max bets for this event")
    end
  end
end
