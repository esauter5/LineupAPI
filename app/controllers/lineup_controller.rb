class LineupController < ApplicationController
  def players
    render json: Player.all.to_json
  end
  
  def optimal
    players = Player.all
    xes = players.map.with_index { |x,i| "x#{i}"}
    points_xes = players.map.with_index { |x,i| "#{x["ppg"]}x#{i}"}
    cost_xes = players.map.with_index { |x,i| "#{x["dollars"]}x#{i}"}
    maximize_statement = xes.join(" + ")
    pg_xes = (0..players.length-1).select { |i| players[i]["position"] == "PG" }.map { |i| "x#{i}" }
    sg_xes = (0..players.length-1).select { |i| players[i]["position"] == "SG" }.map { |i| "x#{i}" }
    sf_xes = (0..players.length-1).select { |i| players[i]["position"] == "SF" }.map { |i| "x#{i}" }
    pf_xes = (0..players.length-1).select { |i| players[i]["position"] == "PF" }.map { |i| "x#{i}" }
    c_xes = (0..players.length-1).select { |i| players[i]["position"] == "C" }.map { |i| "x#{i}" }


    File.open("test_solve", "w") do |file|
      file.puts "max: " + points_xes.join(" + ") + ";"
      file.puts maximize_statement + " = 9;"
      file.puts cost_xes.join(" + ") + " <= 60000;"
      file.puts pg_xes.join(" + ") + " = 2;"
      file.puts sg_xes.join(" + ") + " = 2;"
      file.puts sf_xes.join(" + ") + " = 2;"
      file.puts pf_xes.join(" + ") + " = 2;"
      file.puts c_xes.join(" + ") + " = 1;"
      #file.puts rb_xes.join(" + ") + " + " + wr_xes.join(" + ") + " + " + te_xes.join(" + ") + " = 7;"
      file.puts "\nbin " + xes.join(", ") + ";"
    end

    output = `~/Downloads/lp_solve_5.5.2.0_exe_osx32/lp_solve ~/Code/LineupApi/test_solve`


    output = output.split("\n").map { |x| x.split(" ") }
    output = output[4..output.length - 1]

    lineup = output.select { |x| x[1].to_i == 1 }.map { |y| players[y[0].gsub("x", "").to_i] } 

    render json: lineup.to_json and return
  end
end
