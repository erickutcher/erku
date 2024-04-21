'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.content_index = 1
	m.selected_row_index = 1

	m.row_width = 500
	m.row_height = 75

	m.row_color = "0x00000000"
	m.row_selected_color = "0xFFFFFF30"

	m.drawing_styles = {
		"icon": {
			"fontSize": 48
			"fontUri": "pkg:/components/fonts/Erku.ttf"
			"color": "#FFFFFFFF"
		}
		"default": {
			"fontSize": 48
			"fontUri": "font:LargeBoldSystemFont"
			"color": "#FFFFFFFF"
		}
	}

	''''''''''''''''''''''''

	m.scroll_speed = 0.2

	m.scroll_timer = CreateObject( "roSGNode", "Timer" )
	m.scroll_timer.repeat = true
	m.scroll_timer.duration = 0.5
	m.scroll_timer.ObserveField( "fire", "HandleScroll" )

	m.scroll_type = 0	' 0 = off, 1 = up, 2 = down
	m.long_scroll = 0	' If up or down are held down for 2.0 seconds.

	''''''''''''''''''''''''

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = m.global.panel_color
	m.panel.width = m.row_width
	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]

	''''''''''''''''''''''''

	m.container = CreateObject( "roSGNode", "Rectangle" )
	m.container.width = m.row_width
	m.container.height = m.row_height * 7
	m.container.translation = [ 0, ( m.global.screen_height - m.container.height ) / 2 ]
	m.container.color = "0x00000000"

	''''''''''''''''''''''''

	m.row_search = CreateObject( "roSGNode", "Rectangle" )
	m.row_search.width = m.row_width
	m.row_search.height = m.row_height
	m.row_search.translation = [ 0, 0 ]
	m.row_search.color = m.row_color

		row_line = CreateObject( "roSGNode", "Rectangle" )
		row_line.width = m.row_width
		row_line.height = 3
		row_line.translation = [ 0, 100 ]
		row_line.color = "#FFFFFFFF"
		m.container.AppendChild( row_line )

	m.row_live_tv = CreateObject( "roSGNode", "Rectangle" )
	m.row_live_tv.width = m.row_width
	m.row_live_tv.height = m.row_height
	m.row_live_tv.translation = [ 0, 125 ]
	m.row_live_tv.color = m.row_selected_color

	m.row_movies = CreateObject( "roSGNode", "Rectangle" )
	m.row_movies.width = m.row_width
	m.row_movies.height = m.row_height
	m.row_movies.translation = [ 0, 200 ]
	m.row_movies.color = m.row_color
	
	m.row_tv_shows = CreateObject( "roSGNode", "Rectangle" )
	m.row_tv_shows.width = m.row_width
	m.row_tv_shows.height = m.row_height
	m.row_tv_shows.translation = [ 0, 275 ]
	m.row_tv_shows.color = m.row_color

		row_line = CreateObject( "roSGNode", "Rectangle" )
		row_line.width = m.row_width
		row_line.height = 3
		row_line.translation = [ 0, 375 ]
		row_line.color = "#FFFFFFFF"
		m.container.AppendChild( row_line )

	m.row_options = CreateObject( "roSGNode", "Rectangle" )
	m.row_options.width = m.row_width
	m.row_options.height = m.row_height
	m.row_options.translation = [ 0, 400 ]
	m.row_options.color = m.row_color

	m.row_info = [ { "row": m.row_search, "text" : "Search", "icon_index" : 59648 },
				   { "row": m.row_live_tv, "text" : "Live TV", "icon_index" : 59649 },
				   { "row": m.row_movies, "text" : "Movies", "icon_index" : 59650 },
				   { "row": m.row_tv_shows, "text" : "TV Shows", "icon_index" : 59651 },
				   { "row": m.row_options, "text" : "Options", "icon_index" : 59652 } ]

	for i = 0 to 4
	'{
		label = CreateObject( "roSGNode", "MultiStyleLabel" )
		label.width = 50
		label.height = m.row_height
		label.translation = [ 20, 0 ]
		label.vertAlign = "center"
		label.drawingStyles = m.drawing_styles
		label.text = "<icon>" + chr( m.row_info[ i ].icon_index ) + "</icon>"
		m.row_info[ i ].row.AppendChild( label )

		label = CreateObject( "roSGNode", "MultiStyleLabel" )
		label.width = m.row_width - ( 20 + 50 + 10 + 20 )
		label.height = m.row_height
		label.translation = [ 20 + 50 + 10, 0 ]
		label.horizAlign = "center"
		label.vertAlign = "center"
		label.drawingStyles = m.drawing_styles
		label.text = m.row_info[ i ].text
		m.row_info[ i ].row.AppendChild( label )

		m.container.AppendChild( m.row_info[ i ].row )
	'}
	end for

	m.panel.AppendChild( m.container )
	m.top.AppendChild( m.panel )
'}
end sub

sub Scroll( scroll_type as integer )
'{
	if scroll_type = 1	' Move Up
	'{
		if m.selected_row_index > 0
		'{
			m.row_info[ m.selected_row_index ].row.color = m.row_color
			m.selected_row_index--
			m.row_info[ m.selected_row_index ].row.color = m.row_selected_color

			m.content_index--
		'}
		end if
	'}
	else' if scroll_type = 2	' Move Down
	'{
		if m.selected_row_index < 4
		'{
			m.row_info[ m.selected_row_index ].row.color = m.row_color
			m.selected_row_index++
			m.row_info[ m.selected_row_index ].row.color = m.row_selected_color

			m.content_index++
		'}
		end if
	'}
	end if
'}
end sub

sub HandleScroll()
'{
	if m.scroll_type <> 0
	'{
		' Speed up the timer if the key was held down long enough.
		if m.long_scroll < 80
		'{
			m.long_scroll++

			if m.long_scroll = 5
			'{
				m.scroll_timer.duration = 0.1
			'}
			else if m.long_scroll = 20
			'{
				m.scroll_timer.duration = 0.05
			'}
			else if m.long_scroll = 80
			'{
				m.scroll_timer.duration = 0.01
			'}
			end if
		'}
		end if

		Scroll( m.scroll_type )
	'}
	end if
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "back"
		'{
			if m.top.menu_state = 1
			'{
				m.top.menu_state = 0	' Hide

				return true
			'}
			end if
		'}
		else if key = "OK"
		'{
			m.top.content_index = m.content_index

			return true
		'}
		else if key = "up" or key = "down"
		'{
			if m.top.menu_state = 1
			'{
				if key = "up"
				'{
					m.scroll_type = 1
				'}
				else' if key = "down"
				'{
					m.scroll_type = 2
				'}
				end if

				HandleScroll()

				m.scroll_timer.control = "start"

				return true
			'}
			end if
		'}
		else if key = "left"
		'{
			if m.top.menu_state <> 1
			'{
				m.top.menu_state = 1	' Show
			'}
			end if

			' Don't close the menu if it's already opened.
			return true
		'}
		end if
	'}
	else if not press
	'{
		if key = "up" or key = "down"
		'{
			m.scroll_type = 0

			m.long_scroll = 0
			m.scroll_timer.duration = m.scroll_speed

			m.scroll_timer.control = "stop"

			return true
		'}
		end if
	'}
	end if

	return false
'}
end function
