class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.date :date
      t.float :value
      t.string :description

      t.timestamps
    end
  end
end
