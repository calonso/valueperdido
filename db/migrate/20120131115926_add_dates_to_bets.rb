class AddDatesToBets < ActiveRecord::Migration
  def change
    add_column :bets, :date_selected, :date
    add_column :bets, :date_earned, :date
  end
end
