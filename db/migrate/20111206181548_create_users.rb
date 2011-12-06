class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :surname
      t.string :email, :unique => true
      t.boolean :admin, :default => false
      t.boolean :validated, :default => false
      t.string :encrypted_password
      t.string :salt

      t.timestamps
    end
  end
end
