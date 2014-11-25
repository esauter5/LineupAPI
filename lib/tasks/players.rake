namespace :players do
  desc "Insert players into db"
  task :insert_players => :environment do
    players = []

    day = Time.new.day

    lines = File.readlines("public/player_files/nba_lineup_11_#{day}_14.txt")

    i = 0

    while i < lines.count do
      player = {}
      player["position"] = lines[i].lstrip.rstrip
      player["name"] = lines[i+1].lstrip.rstrip.gsub("GTD", "")
      player["name"] = "Bradley Beal" if player["name"] == "Brad Beal"
      stats = lines[i+2].split("\t")
      player["ppg"] = stats[0].to_f
      player["dollars"] = stats[3].gsub("$","").gsub(",","").to_i
      player["value"] = player["dollars"]/player["ppg"]
      players << player
      i += 3
    end

    players.select! { |p| p["name"][p["name"].length - 1] != "O" }

    players.each do |p|
      Player.create(name: p["name"], position: p["position"], ppg: p["ppg"], dollars: p["dollars"], match_time: "2014-11-#{day}T07:00:00Z")
    end
  end

  desc "Scrape ceiling and floors"
  task :ceiling_floor => :environment do
    day = Time.new.day
    lines = File.readlines("public/player_files/nba_ceiling_11_#{day}_14.txt")
    players = []

    lines.each do |l|
      players << l.split("\t").map { |col| col.strip }
    end

    players.each do |p|
      db_player = Player.where(name: p[0], match_time: "2014-11-#{day}T07:00:00Z")

      unless db_player.empty?
        db_player[0].fp_min = p[5]
        db_player[0].fp_max = p[4]
        db_player[0].floor = p[6]
        db_player[0].ceiling = p[7]
        db_player[0].save
      end
    end
  end

  desc "Scrape ceiling and floors for last week"
  task :last_week => :environment do
    day = Time.new.day
    lines = File.readlines("public/player_files/nba_ceiling_11_#{day}_14_week.txt")
    players = []

    lines.each do |l|
      players << l.split("\t").map { |col| col.strip }
    end

    players.each do |p|
      db_player = Player.where(name: p[0], match_time: "2014-11-#{day}T07:00:00Z")

      unless db_player.empty?
        db_player[0].fp_min = p[5]
        db_player[0].ppg = p[3]
        db_player[0].fp_max = p[4]
        db_player[0].floor = p[6]
        db_player[0].ceiling = p[7]
        db_player[0].save
      end
    end
  end

  desc "Reset today's players"
  task :reset_today => :environment do
   day = Time.new.day
   Player.destroy_all(match_time: "2014-11-#{day}T07:00:00Z")
  end

end
