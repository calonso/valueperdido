class RenameBetRateToOdds < ActiveRecord::Migration
  def change
    rename_column :bets, :rate, :odds
    add_column :bets, :earned, :float, :default => 0.0
  end
end
