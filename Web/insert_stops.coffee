# insert_stops.coffee


preferred_stops = []

$.getJSON('preferred_stops.json').done((data) ->
      console.log("read preferred_stops.json")
      $(document).ready(data.map (stop) -> preferred_stops.push(stop))
  ).done(

    $.getJSON 'bus_info.json', (bus_info) ->
      console.log("read bus_info.json")
      console.log("preferred stops: #{preferred_stops}")

      buses = (bus for bus of bus_info).sort().reverse()
      for bus in buses
        dir = (dir for dir of bus_info[bus].stops)
        for dir,label of bus_info[bus].direction_labels
          route = "#{bus} #{label}"

          text = "<li>#{route}\n    <ul data-role=\"listview\" data-inset=\"true\" data-theme=\"c\">"
          for stop,link of bus_info[bus].stops[dir]
            text += "        <li><a href=\"#{link}\" target=\"_blank\">#{stop}</a></li>\n"
          text += "</ul></li>"

          $(text).insertAfter("li#buses")
        
      $('ul#buses').listview("refresh")
)
