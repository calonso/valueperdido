class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float :amount
      t.date :date
      t.integer :user_id

      t.timestamps
    end
  end
end
