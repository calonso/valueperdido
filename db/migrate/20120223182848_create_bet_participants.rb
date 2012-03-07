class CreateBetParticipants < ActiveRecord::Migration
  def change
    create_table :bet_participants do |t|
      t.integer :user_id
      t.integer :bet_id
      t.float :percentage

      t.timestamps
    end
    users = User.find_all_by_validated(true)
    Bet.all.each do |bet|
      bet.participants = users
    end
  end
end
