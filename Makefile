all: Ruby/bus_info.json Web/bus_info.js

Ruby/bus_info.json: Ruby/grab_bus_stops.rb
	cd Ruby;grab_bus_stops.rb 15 80

Web/bus_info.js: Web/bus_info.coffee
	coffee -bc Web/bus_info.coffee

web: Web/bus_info.js Ruby/bus_info.json
	cd Web;scp index.html bus_info.js *.json broman-2:public_html/bus/
