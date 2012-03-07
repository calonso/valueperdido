class AddTotalToAccountSummary < ActiveRecord::Migration
  def change
    add_column :account_summaries, :total, :float, :default => 0.0
    AccountSummary.full_summarize if User.any?
  end
end
