class Bet < ActiveRecord::Base
  STATUS_IDLE      = '0'
  STATUS_PERFORMED = '1'
  STATUS_LOSER     = '2'
  STATUS_WINNER    = '3'
  STATUSES = [
      ["#{ I18n.t :idle }", STATUS_IDLE],
      ["#{ I18n.t :performed }", STATUS_PERFORMED],
      ["#{ I18n.t :loser }", STATUS_LOSER],
      ["#{ I18n.t :winner }", STATUS_WINNER]
  ]
  TRANSITIONS = [
      [STATUS_PERFORMED], #Means that an IDLE Bet can only move to performed
      [STATUS_LOSER, STATUS_WINNER], #Means that a PERFORMED Bet can move to loser or winner
      [],
      []
  ]

  attr_accessible :title, :description, :status, :money, :odds,
                  :event_id, :earned

  belongs_to :user
  belongs_to :event
  has_many :votes, :dependent => :destroy
  has_many :bet_participants
  has_many :participants, :class_name => "User", :source => :user, :through => :bet_participants

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
  validate :transitable, :on => :update

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

  def process_update(new_attributes)
    if new_attributes[:status] == Bet::STATUS_PERFORMED
      self.participants = User.validated
      self.update_attributes!(new_attributes)
    else
      self.update_attributes!(new_attributes)
      if new_attributes[:status] == Bet::STATUS_WINNER && User.any_user_first_payed_between?(self.date_performed, Time.now) then
        total = AccountSummary.total_money
        bet_value = self.money + self.earned
        total -= bet_value
        participants = self.bet_participants
        User.validated.each do |user|
          user_amount = total * user.percentage / 100
          register = participants.find { |p| p.user_id == user.id }
          user_amount += bet_value * (register.percentage / 100) if register
          user.percentage = (user_amount / (total + bet_value)) * 100
          user.save!
        end
      end
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

  def transitable
    if TRANSITIONS[self.status_was.to_i].include? self.status
      if self.status_was == STATUS_PERFORMED
        if self.money_changed?
          errors.add(:money, "#{I18n.t :bet_money_non_editable}")
        end
        if self.odds_changed?
          errors.add(:odds, "#{I18n.t :bet_odds_non_editable}")
        end
      end
    else
      errors.add(:event, "#{I18n.t :bet_status_invalid}")
    end
  end

  def no_more_than_max_bets_per_user
    bets = Bet.where("user_id = ? AND event_id = ?", user, event)
    if bets.count >= Valueperdido::Application.config.max_bets_per_user
      errors.add(:event, "#{I18n.t :max_bets_err}")
    end
  end

  def event_is_active
    unless Event.find(event_id).active?
      errors.add(:event, "#{I18n.t :event_closed_err}")
    end
  end
end
