# insert_stops.coffee


preferred_stops = []

$.getJSON('preferred_stops.json').done((data) ->
      $(document).ready(data.map (stop) -> preferred_stops.push(stop))
  ).done(

    $.getJSON 'bus_info.json', (bus_info) ->

      # two helper functions to sort the bus routes
      replaceroute = (a) ->
          routeorder = ["15", "80", "3", "14", "M"]
          tempval = ["-4","-3","-2","-1", "0"]
          index = routeorder.indexOf(a)
          return tempval[index] if index >= 0
          a

      comparefunc = (a,b) ->
          a = parseInt(replaceroute(a))
          b = parseInt(replaceroute(b))
          a - b

      # sort the bus routes as 15, 80, 3, 14, ...
      buses = (bus for bus of bus_info).sort(comparefunc)

      for bus in buses
        dir = (dir for dir of bus_info[bus].stops)
        for dir,label of bus_info[bus].direction_labels
          route = "#{bus} #{label}"

          text = "<div data-role=\"collapsible\">\n<h3>#{route}</h3>\n"
          text += "<ul data-role=\"listview\" data-theme=\"d\">"

          for stop in preferred_stops
            link = bus_info[bus].stops[dir][stop]
            text += "<li><a href=\"#{link}\" target=\"_blank\">#{stop}</a></li>\n" if link

          text += "<div data-role=\"collapsible\" data-inset=\"true\" data-theme=\"c\">\n"
          text += "<h3>More</h3><ul data-role=\"listview\">"

          for stop,link of bus_info[bus].stops[dir]
            text += "<li><a href=\"#{link}\" target=\"_blank\">#{stop}</a></li>\n"

          text += "</ul></div></ul></div>"
          text += "</ul></div>"

          $('div#insert_here').append(text)

      $('div[data-role=collapsible]').collapsible()
      $('ul[data-role=listview]').listview()
)
