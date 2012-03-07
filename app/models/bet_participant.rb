class BetParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :bet

  before_create :set_percentage

  def set_percentage
    self.percentage = self.user.percentage
  end

end
