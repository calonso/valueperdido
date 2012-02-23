class RemoveDateFromPayments < ActiveRecord::Migration
  def up
    Payment.all.each do |payment|
      last = payment.created_at
      new_date = payment.date.to_datetime.change :hour => last.hour, :min => last.min, :sec => last.sec
      payment.created_at = new_date
      payment.save!
    end
    remove_column :payments, :date
  end

  def down
    add_column :payments, :date, :date
    Payment.all.each do |payment|
      payment.date = payment.created_at.to_date
      payment.save!
    end
  end
end
