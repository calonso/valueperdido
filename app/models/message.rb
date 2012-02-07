require_dependency "event"
require_dependency "bet"

class Message < ActiveRecord::Base
  attr_accessible :message
  serialize :message

  belongs_to :user

  validates :user_id, :presence => true
  validates :message, :presence => true

  default_scope :order => "messages.created_at DESC"

  def self.post_summary_message
    events = Event.where("created_at BETWEEN ? AND ?", Date.yesterday, Date.today)
    selected = Bet.find_all_by_date_selected Date.yesterday
    winner = Bet.find_all_by_date_earned Date.yesterday

    message = nil
    unless events.empty? && selected.empty? && winner.empty?
      message = Message.new(:message => { :events => events.to_a, :selected => selected, :winner => winner})
      #Skip validation as no user id is being assigned
      message.save(:validate => false)
    end
    return message
  end
end
