class Player < ActiveRecord::Base
  attr_accessible :dollars, :name, :position, :ppg, :match_time
end
