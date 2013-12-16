# bus_info.coffee

$.getJSON 'bus_info.json', (bus_info) ->
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
