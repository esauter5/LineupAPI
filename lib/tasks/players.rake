namespace :players do
  desc "TODO"
  task :insert_players => :environment do
    players = []


    lines = File.readlines("public/player_files/nba_lineup_11_14_14.txt")

    i = 0

    while i < lines.count do
      player = {}
      player["position"] = lines[i].lstrip.rstrip
      player["name"] = lines[i+1].lstrip.rstrip
      stats = lines[i+2].split("\t")
      player["ppg"] = stats[0].to_f
      player["dollars"] = stats[3].gsub("$","").gsub(",","").to_i
      player["value"] = player["dollars"]/player["ppg"]
      players << player
      i += 3
    end

    players.select! { |p| p["name"][p["name"].length - 1] != "O" }

    binding.pry
    players.each do |p|
      Player.create(name: p["name"], position: p["position"], ppg: p["ppg"], dollars: p["dollars"], match_time: "2014-11-14T07:00:00Z")
    end

    binding.pry
  end

end
