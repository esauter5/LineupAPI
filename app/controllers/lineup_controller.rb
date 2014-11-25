class LineupController < ApplicationController
  def players
    render json: Player.where(match_time: "2014-11-#{Time.new.day}T07:00:00Z").sort { |a,b| b.ppg <=> a.ppg }.to_json
  end

  def optimal
    risk = params[:risk]
    excluded_players = params[:exclude] || []
    players = Player.where(match_time: "2014-11-#{Time.new.day}T07:00:00Z")
    players = players.select { |p| !excluded_players.include? p.name } #exclude
    xes = players.map.with_index { |x,i| "x#{i}"}
    points_xes = players.map.with_index { |x,i| "#{x[risk]}x#{i}"}
    cost_xes = players.map.with_index { |x,i| "#{x["dollars"]}x#{i}"}
    maximize_statement = xes.join(" + ")
    pg_xes = (0..players.length-1).select { |i| players[i]["position"] == "PG" }.map { |i| "x#{i}" }
    sg_xes = (0..players.length-1).select { |i| players[i]["position"] == "SG" }.map { |i| "x#{i}" }
    sf_xes = (0..players.length-1).select { |i| players[i]["position"] == "SF" }.map { |i| "x#{i}" }
    pf_xes = (0..players.length-1).select { |i| players[i]["position"] == "PF" }.map { |i| "x#{i}" }
    c_xes = (0..players.length-1).select { |i| players[i]["position"] == "C" }.map { |i| "x#{i}" }
    i_indexes = []

    params[:include].each { |inc| i_indexes << players.index { |p| p.name == inc } } if params[:include]



    maximize_statement += " = 9;"
    costs = cost_xes.join(" + ") + " <= 60000;"
    pgs = pg_xes.join(" + ") + " = 2;"
    sgs = sg_xes.join(" + ") + " = 2;"
    sfs = sf_xes.join(" + ") + " = 2;"
    pfs = pf_xes.join(" + ") + " = 2;"
    cs = c_xes.join(" + ") + " = 1;"
    max_points = "max: " + points_xes.join(" + ") + ";"

    i_indexes.each do |i_index|
      max_points.gsub!("x#{i_index} ", " ")
      maximize_statement.gsub!("x#{i_index} ", "1 ")
      costs.gsub!("x#{i_index} ", " ")
      [pgs, sgs, sfs, pfs, cs].each { |str| str.gsub!("x#{i_index} ", "1 ") }
    end


    File.open("test_solve", "w") do |file|
      file.puts max_points
      file.puts maximize_statement
      file.puts costs
      file.puts pgs
      file.puts sgs
      file.puts sfs
      file.puts pfs
      file.puts cs
      file.puts "\nbin " + xes.join(", ") + ";"
    end

    output = `~/Downloads/lp_solve_5.5.2.0_exe_osx32/lp_solve ~/Code/LineupApi/test_solve`

    puts output

    output = output.split("\n").map { |x| x.split(" ") }
    output = output[4..output.length - 1]

    lineup = output.select { |x| x[1].to_i == 1 }.map { |y| players[y[0].gsub("x", "").to_i] }

    render json: lineup.to_json and return
  end
end
