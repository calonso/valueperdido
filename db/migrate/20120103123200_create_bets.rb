class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.string :title
      t.text :description
      t.boolean :selected, :default => false
      t.boolean :winner, :default => false
      t.float :money, :default => 0.0
      t.float :rate, :default => 0.0
      t.integer :event_id
      t.integer :user_id

      t.timestamps
    end
  end
end
