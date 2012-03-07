class Expense < ActiveRecord::Base
  attr_accessible :value, :description

  validates :value, :presence => true,
                    :numericality => true
  validates :description, :presence => true, :length => { :maximum => 255 }

end
