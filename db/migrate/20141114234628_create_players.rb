class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :position
      t.float :ppg
      t.integer :dollars
      t.string :match_time
    end
  end
end
