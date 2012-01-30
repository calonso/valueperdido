class Vote < ActiveRecord::Base

  belongs_to :user
  belongs_to :event
  belongs_to :bet

  validates :event_id,  :presence => true
  validates :user_id,   :presence => true
  validates :bet_id,    :presence => true,
                        :uniqueness => { :scope => :user_id}
  validate :max_votes_per_user, :on => :create

  def max_votes_per_user
    votes = Vote.where("user_id = ? AND event_id = ?", user, event)
    if votes.count >= Valueperdido::Application.config.max_votes_per_user
      errors.add(:event, "#{I18n.t :max_votes_err}")
    end
  end
end
