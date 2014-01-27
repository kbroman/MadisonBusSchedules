all: Ruby/bus_info.json Web/insert_stops.js

Ruby/bus_info.json: Ruby/grab_bus_stops.rb
	cd Ruby;grab_bus_stops.rb 15 80

Web/insert_stops.js: Web/insert_stops.coffee
	coffee -bc Web/insert_stops.coffee

toweb: Web/insert_stops.js Ruby/bus_info.json Ruby/preferred_stops.json
	cd Web;scp index.html insert_stops.js *.json broman-2:public_html/bus/
