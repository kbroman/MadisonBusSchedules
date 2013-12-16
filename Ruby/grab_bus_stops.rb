#!/usr/bin/env ruby

routes = ARGV.length > 0 ? ARGV : ["80"]
puts "Seeking info for routes #{routes.join(' ')}"

require "open-uri"
require 'Nokogiri'

SERVER = "http://webwatch.cityofmadison.com/webwatch"

def grab_directions(route)
  routedoc = Nokogiri::HTML(open("#{SERVER}/MobileAda.aspx?r=#{route}"))

  Hash[routedoc.xpath('//a[@href]').
       select {|link| link["href"] =~ /MobileAda/}.
       map {|link| [link.text.strip, "#{SERVER}/#{link['href']}"]}]
end

def grab_stops(route, directions)
  stops = {}
  direction_labels = {}
  directions.each do |direction,href|
    stopdoc = Nokogiri::HTML(open(href))
    stops[direction] = Hash[stopdoc.xpath('//a[@href]').
                            select {|link| link["href"] =~ /MobileAda/}.
                            map {|link| [link.text.strip, "#{SERVER}/#{link['href']}"]}]

    direction_labels[direction] = get_direction_label(stops[direction].keys)
    stops[direction] = clean_stop_names(stops[direction])
  end

  {'stops' => stops, 'direction_labels' => direction_labels}
end

def get_stop_directions (stopnames)
  stopnames.map do |stop|
    $1 if stop =~ /\[(\w+)#\d+\]/
  end
end

def count_values (array)
  Hash[array.uniq.map { |val| [val, array.count(val)] }]
end

def get_direction_label (stopnames)
  return nil if stopnames.length < 1
  directions = get_stop_directions(stopnames)
  counts = count_values(directions)
  max = counts.max_by {|key, value| value}
  clean_direction_label(max[0])
end

def clean_direction_label (direction)
  directions = ["North", "South", "East", "West"]
  preferred = Hash[directions.map { |dir| [dir[0] + "B", dir] }]
  preferred[direction].nil? ? direction : preferred[direction]
end

def clean_stop_names (stops)
  result = {}
  stops.each do |stop,link|
    stop = stop.gsub '&', '&amp;'
    stop = $1 if stop =~ /(.*)\s+\[/
    stop = stop.split(/\s+/).map {|w| w.capitalize}.join(' ')
    stop = stop.sub "D`onofrio", "D'Onofrio"
    result[stop] = link
  end
  result
end

def all_stops (bus_info)
  stops = []
  bus_info.each do |route,info|
    info["stops"].each do |dir,info|
       stops += (info.map { |stop,link| stop })
    end
  end
  stops.uniq
end

bus_info = {}
routes.each { |route| bus_info[route] = grab_stops(route, grab_directions(route)) }

stops = all_stops(bus_info)

require 'json'
File.open("bus_info.json", "w") { |f| f.write(bus_info.to_json) }
file = "preferred_stops.json"
unless File.exists?(file)
  print "Writing list of stops"
  f = File.open(file, "w")
  f.write("[\n")
  f.write(stops.map { |z| "\"#{z}\""}.join(",\n"))
  f.write("\n]\n")
end
