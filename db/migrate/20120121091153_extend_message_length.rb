class ExtendMessageLength < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE messages
      ALTER COLUMN message TYPE text
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE messages
      ALTER COLUMN message TYPE string
    SQL
  end
end
