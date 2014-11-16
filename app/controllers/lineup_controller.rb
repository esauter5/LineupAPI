class LineupController < ApplicationController
  def players
    render json: Player.where(match_time: "2014-11-16T07:00:00Z").to_json
  end
  
  def optimal
    risk = params[:risk]
    players = Player.where(match_time: "2014-11-16T07:00:00Z")
    xes = players.map.with_index { |x,i| "x#{i}"}
    points_xes = players.map.with_index { |x,i| "#{x[risk]}x#{i}"}
    cost_xes = players.map.with_index { |x,i| "#{x["dollars"]}x#{i}"}
    maximize_statement = xes.join(" + ")
    pg_xes = (0..players.length-1).select { |i| players[i]["position"] == "PG" }.map { |i| "x#{i}" }
    sg_xes = (0..players.length-1).select { |i| players[i]["position"] == "SG" }.map { |i| "x#{i}" }
    sf_xes = (0..players.length-1).select { |i| players[i]["position"] == "SF" }.map { |i| "x#{i}" }
    pf_xes = (0..players.length-1).select { |i| players[i]["position"] == "PF" }.map { |i| "x#{i}" }
    c_xes = (0..players.length-1).select { |i| players[i]["position"] == "C" }.map { |i| "x#{i}" }
    #params[:include] = ["Sebastian Telfair"]

    File.open("test_solve", "w") do |file|
      file.puts "max: " + points_xes.join(" + ") + ";"
    #  params[:include].each do |player|
     #  index = players.index { |p| p.name == player }
      # file.puts "x#{index} = 1;"
     # end
      file.puts maximize_statement + " = 9;"
      file.puts cost_xes.join(" + ") + " <= 60000;"
      file.puts pg_xes.join(" + ") + " = 2;"
      file.puts sg_xes.join(" + ") + " = 2;"
      file.puts sf_xes.join(" + ") + " = 2;"
      file.puts pf_xes.join(" + ") + " = 2;"
      file.puts c_xes.join(" + ") + " = 1;"
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
