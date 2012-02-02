class CreateAccountSummaries < ActiveRecord::Migration
  def change
    create_table :account_summaries do |t|
      t.float :incoming
      t.float :bet
      t.float :earns
      t.date  :date

      t.timestamps
    end
  end
end
