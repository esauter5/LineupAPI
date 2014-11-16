class AddColumnsToPlayers < ActiveRecord::Migration
  def up
    add_column :players, :ceiling, :float
    add_column :players, :floor, :float
  end
end
