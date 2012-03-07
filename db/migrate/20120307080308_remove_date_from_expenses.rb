class RemoveDateFromExpenses < ActiveRecord::Migration
  def up
      Expense.all.each do |expense|
        last = expense.created_at
        new_date = expense.date.to_datetime.change :hour => last.hour, :min => last.min, :sec => last.sec
        expense.created_at = new_date
        expense.save!
      end
      remove_column :expenses, :date
    end

    def down
      add_column :expenses, :date, :date
      Expense.all.each do |expense|
        expense.date = expense.created_at.to_date
        expense.save!
      end
    end
end
