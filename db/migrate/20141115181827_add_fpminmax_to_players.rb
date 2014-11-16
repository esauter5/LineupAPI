class AddFpminmaxToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :fp_min, :float
    add_column :players, :fp_max, :float
  end
end
