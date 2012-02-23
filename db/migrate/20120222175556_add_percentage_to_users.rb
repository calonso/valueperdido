class AddPercentageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :percentage, :float, :default => 0.0
    users = User.find_all_by_validated(true)
    users.each do |user|
      user.percentage = 100.0/users.count
      user.save!
    end
  end
end
