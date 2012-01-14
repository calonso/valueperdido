class Message < ActiveRecord::Base
  attr_accessible :message

  belongs_to :user

  validates :user_id, :presence => true
  validates :message, :presence => true

  default_scope :order => "messages.created_at DESC"
end
