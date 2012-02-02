class Bet < ActiveRecord::Base
  attr_accessible :title, :description, :selected, :winner, :money, :odds
  attr_accessible :event_id, :earned

  belongs_to :user
  belongs_to :event
  has_many :votes, :dependent => :destroy

  validates :title, :presence => true,
                    :length => { :maximum => 45 }
  validates :description, :presence => true
  validates :event_id, :presence => true
  validates :money, :numericality => true
  validates :money, :numericality => { :greater_than => 0 }, :if => :selected
  validates :odds, :numericality => true
  validates :odds, :numericality => { :greater_than => 0 }, :if => :selected
  validates :earned, :numericality => true
  validates :earned, :numericality => { :greater_than => 0 }, :if => :winner
  validate :no_more_than_max_bets_per_user, :on => :create
  validate :event_is_active, :on => :create, :if => :event_id
  validate :non_editable_when_selected, :on => :update, :if => :date_selected
  validate :non_editable_when_winner, :on => :update, :if => :date_earned

  scope :selected, where(:selected => true)

  default_scope :order => 'bets.id DESC'

  before_update :set_dates
  
  def self.with_votes_for_event(evt, usr)
    self.connection.execute(sanitize_sql ["
      SELECT b.id as id, title, COALESCE(votes, 0) as votes, COALESCE(voted, 0) as voted, selected, user_id, author FROM bets b
      left outer join (SELECT bet_id, count(*) as votes FROM votes group by bet_id) as v on b.id = v.bet_id
      left outer join (SELECT bet_id, 1 as voted from votes where user_id = ? and event_id = ?) as usr on usr.bet_id = b.id
      left outer join (SELECT id, name||' '||surname as author from users) as users on b.user_id = users.id
      where event_id = ? order by votes desc", usr, evt, evt]).to_a
  end

  def no_more_than_max_bets_per_user
    bets = Bet.where("user_id = ? AND event_id = ?", user, event)
    if bets.count >= Valueperdido::Application.config.max_bets_per_user
      errors.add(:event, "#{I18n.t :max_bets_err}")
    end
  end

  def non_editable_when_selected
    if self.selected_changed?
      errors.add(:selected, "#{I18n.t :bet_selected_non_editable}")
    end
    if self.money_changed?
      errors.add(:money, "#{I18n.t :bet_money_non_editable}")
    end
    if self.odds_changed?
      errors.add(:odds, "#{I18n.t :bet_odds_non_editable}")
    end
  end

  def non_editable_when_winner
    if self.winner_changed?
      errors.add(:winner, "#{I18n.t :bet_winner_non_editable}")
    end
    if self.earned_changed?
      errors.add(:earned, "#{I18n.t :bet_earned_non_editable}")
    end
  end

  def event_is_active
    unless Event.find(event_id).active?
      errors.add(:event, "#{I18n.t :event_closed_err}")
    end
  end

  protected
  def set_dates
    if self.selected_changed?
      self.date_selected = selected ? Date.today : nil
      self.date_earned = nil
    end
    
    if self.winner_changed?
      self.date_earned = winner ? Date.today : nil
    end
  end
end
