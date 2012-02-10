class AddPassiveAttributeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :passive, :boolean, :default => false
  end
end
