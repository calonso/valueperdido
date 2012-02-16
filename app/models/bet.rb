class Bet < ActiveRecord::Base
  STATUS_IDLE      = '0'
  STATUS_PERFORMED = '1'
  STATUS_LOSER     = '2'
  STATUS_WINNER    = '3'
  STATUSES = [ ["#{ I18n.t :idle }", STATUS_IDLE],
               ["#{ I18n.t :performed }", STATUS_PERFORMED],
               ["#{ I18n.t :loser }", STATUS_LOSER],
               ["#{ I18n.t :winner }", STATUS_WINNER]]

  attr_accessible :title, :description, :status, :money, :odds,
                  :event_id, :earned

  belongs_to :user
  belongs_to :event
  has_many :votes, :dependent => :destroy

  validates :title, :presence => true,
                    :length => { :maximum => 45 }
  validates :description, :presence => true
  validates :event_id, :presence => true
  validates :status, :inclusion => { :in => [STATUS_IDLE, STATUS_PERFORMED, STATUS_LOSER, STATUS_WINNER] }
  validates :money, :numericality => true
  validates :money, :numericality => { :greater_than => 0 }, :if => :performed?
  validates :odds, :numericality => true
  validates :odds, :numericality => { :greater_than => 0 }, :if => :performed?
  validates :earned, :numericality => true
  validates :earned, :numericality => { :greater_than => 0 }, :if => Proc.new { |b| b.status == STATUS_WINNER }
  validate :no_more_than_max_bets_per_user, :on => :create
  validate :event_is_active, :on => :create, :if => :event_id
  validate :non_editable_when_performed, :on => :update, :if => :date_performed
  validate :non_editable_when_finished, :on => :update, :if => :date_finished

  scope :performed, lambda { where("status != ?", STATUS_IDLE) }

  default_scope :order => 'bets.id DESC'

  before_update :set_dates
  
  def self.with_votes_for_event(evt, usr)
    self.connection.execute(sanitize_sql ["
      SELECT b.id as id, title, COALESCE(votes, 0) as votes, COALESCE(voted, 0) as voted, status, user_id, author FROM bets b
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

  def non_editable_when_performed
    if self.status_changed? && self.status == STATUS_IDLE
      errors.add(:status, "#{I18n.t :bet_performed_non_editable}")
    end
    if self.money_changed?
      errors.add(:money, "#{I18n.t :bet_money_non_editable}")
    end
    if self.odds_changed?
      errors.add(:odds, "#{I18n.t :bet_odds_non_editable}")
    end
  end

  def non_editable_when_finished
    if self.status_changed?
      errors.add(:status, "#{I18n.t :bet_winner_non_editable}")
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

  def performed?
    status != STATUS_IDLE
  end

  def finished?
    status == STATUS_WINNER || status == STATUS_LOSER
  end

  protected
  def set_dates
    if self.status_changed?
      case status
        when STATUS_IDLE
          self.date_performed = self.date_finished = nil
        when STATUS_PERFORMED
          self.date_performed = Date.today
          self.date_finished = nil
        when STATUS_LOSER, STATUS_WINNER
          self.date_performed = Date.today unless self.date_performed
          self.date_finished = Date.today
      end
    end
  end
end
