class AddResultToBets < ActiveRecord::Migration
  def up
    add_column :bets, :status, :char, :default => Bet::STATUS_IDLE
    Bet.all.each do |bet|
      if bet.selected?
        if bet.winner?
          bet.status = Bet::STATUS_WINNER
        else
          bet.status = Bet::STATUS_LOSER
        end
      end
    end
    remove_column :bets, :winner
    remove_column :bets, :selected
    rename_column :bets, :date_selected, :date_performed
    rename_column :bets, :date_earned, :date_finished
  end

  def down
    add_column :bets, :selected, :boolean, :default => false
    add_column :bets, :winner, :boolean, :default => false
    Bet.all.each do |bet|
      case bet.status
        when Bet::STATUS_PERFORMED
        when Bet::STATUS_LOSER
          bet.selected = true
        when Bet::STATUS_WINNER
          bet.winner = true
          bet.selected = true
      end
    end
    remove_column :bets, :status
    rename_column :bets, :date_performed, :date_selected
    rename_column :bets, :date_finished, :date_earned
  end
end
