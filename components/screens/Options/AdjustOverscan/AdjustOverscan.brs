'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.button_background_color = "0x002040E0"
	m.button_color = "0x00000000"
	m.button_selected_color = "0xFFFFFF30"

	m.item_selected = 0

	m.adjust_corner = false

	m.pos_top = m.global.overscan_offset_y
	m.pos_left = m.global.overscan_offset_x
	m.pos_right = m.global.screen_width
	m.pos_bottom = m.global.screen_height

	m.background = CreateObject( "roSGNode", "Rectangle" )
	m.background.color = "0xFF0000FF"
	m.background.width = m.global.preferred_screen_width
	m.background.height = m.global.preferred_screen_height

	m.view_window = CreateObject( "roSGNode", "Rectangle" )
	m.view_window.color = "#000000FF"
	m.view_window.width = m.pos_right
	m.view_window.height = m.pos_bottom
	m.view_window.translation = [ m.pos_left, m.pos_top ]

	m.background.AppendChild( m.view_window )
	m.top.AppendChild( m.background )

	m.info = CreateObject( "roSGNode", "MultiStyleLabel" )
	m.info.width = 1600
	m.info.height = 150
	m.info.translation = [ m.global.overscan_offset_x + ( m.global.screen_width - 1600 ) / 2, m.global.overscan_offset_y + ( m.global.screen_height - 150 ) / 2 ]
	m.info.horizAlign = "center"
	m.info.text = "Use the directional arrows to adjust the viewing window until the red background disappears." + chr( 10 ) + "Restart the channel for changes to take effect."
	m.top.AppendChild( m.info )

	m.drawing_styles = {
		"red": {
			"color": "#FF0000FF"
			"fontUri": "font:SmallSystemFont"
		}
		"default": {
			"fontUri": "font:SmallSystemFont"
			"color": "#FFFFFFFF"
		}
	}

	label_width = 300
	label_height = 75

	''''''''''''''''''''''''

	m.options_columns = CreateObject( "roSGNode", "Rectangle" )
	m.options_columns.color = "0x00000000"
	m.options_columns.width = 1260
	m.options_columns.height = label_height
	m.options_columns.translation = [ m.global.overscan_offset_x + ( m.global.screen_width - 1260 ) / 2, m.global.overscan_offset_y + ( m.global.screen_height - label_height ) / 2 + 250 ]

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ 0, 0 ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		column = CreateObject( "roSGNode", "Rectangle" )
		column.width = label_width
		column.height = label_height
		column.translation = [ 0, 0 ]
		column.color = m.button_selected_color

			overscan = CreateObject( "roSGNode", "Label" )
			overscan.width = label_width - 10
			overscan.height = label_height
			overscan.translation = [ 5, 0 ]
			overscan.horizAlign = "center"
			overscan.vertAlign = "center"
			overscan.font = "font:SmallSystemFont"
			overscan.text = "Top-Left"

		column.AppendChild( overscan )

		m.top_left_info = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.top_left_info.width = label_width
		m.top_left_info.height = label_height
		m.top_left_info.translation = [ m.options_columns.boundingRect()[ "x" ], m.options_columns.boundingRect()[ "y" ] - label_height ]
		m.top_left_info.horizAlign = "center"
		m.top_left_info.drawingStyles = m.drawing_styles
		m.top_left_info.text = "[" + m.pos_left.ToStr() + ", " + m.pos_top.ToStr() + "]"
		m.top.AppendChild( m.top_left_info )

	m.options_columns.AppendChild( column )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ label_width + 20, 0 ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		column = CreateObject( "roSGNode", "Rectangle" )
		column.width = label_width
		column.height = label_height
		column.translation = [ label_width + 20, 0 ]
		column.color = m.button_color

			overscan = CreateObject( "roSGNode", "Label" )
			overscan.width = label_width - 10
			overscan.height = label_height
			overscan.translation = [ 5, 0 ]
			overscan.horizAlign = "center"
			overscan.vertAlign = "center"
			overscan.font = "font:SmallSystemFont"
			overscan.text = "Bottom-Right"

		column.AppendChild( overscan )

		m.bottom_right_info = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.bottom_right_info.width = label_width
		m.bottom_right_info.height = label_height
		m.bottom_right_info.translation = [ m.options_columns.boundingRect()[ "x" ] + label_width, m.options_columns.boundingRect()[ "y" ] - label_height ]
		m.bottom_right_info.horizAlign = "center"
		m.bottom_right_info.drawingStyles = m.drawing_styles
		m.bottom_right_info.text = "[" + m.pos_right.ToStr() + ", " + m.pos_bottom.ToStr() + "]"
		m.top.AppendChild( m.bottom_right_info )

	m.options_columns.AppendChild( column )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ ( label_width + 20 ) * 2, 0 ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		column = CreateObject( "roSGNode", "Rectangle" )
		column.width = label_width
		column.height = label_height
		column.translation = [ ( label_width + 20 ) * 2, 0 ]
		column.color = m.button_color

			overscan = CreateObject( "roSGNode", "Label" )
			overscan.width = label_width - 10
			overscan.height = label_height
			overscan.translation = [ 5, 0 ]
			overscan.horizAlign = "center"
			overscan.vertAlign = "center"
			overscan.font = "font:SmallSystemFont"
			overscan.text = "Reset"

		column.AppendChild( overscan )

	m.options_columns.AppendChild( column )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ ( label_width + 20 ) * 3, 0 ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		column = CreateObject( "roSGNode", "Rectangle" )
		column.width = label_width
		column.height = label_height
		column.translation = [ ( label_width + 20 ) * 3, 0 ]
		column.color = m.button_color

			overscan = CreateObject( "roSGNode", "Label" )
			overscan.width = label_width - 10
			overscan.height = label_height
			overscan.translation = [ 5, 0 ]
			overscan.horizAlign = "center"
			overscan.vertAlign = "center"
			overscan.font = "font:SmallSystemFont"
			overscan.text = "Apply"

		column.AppendChild( overscan )

	m.options_columns.AppendChild( column )

	''''''''''''''''''''''''

	m.top.AppendChild( m.options_columns )

	''''''''''''''''''''''''

	m.scroll_speed = 0.2

	m.scroll_timer = CreateObject( "roSGNode", "Timer" )
	m.scroll_timer.repeat = true
	m.scroll_timer.duration = 0.5
	m.scroll_timer.ObserveField( "fire", "HandleScroll" )

	m.scroll_type = 0	' 0 = off, 1 = up, 2 = down, 3 = left, 4 = right
	m.long_scroll = 0	' If up or down are held down for 2.0 seconds.
'}
end sub

sub UpdateOverscanInfoText()
'{
	if m.adjust_corner = true and m.item_selected = 0
	'{
		m.top_left_info.text = "[<red>" + m.pos_left.ToStr() + ", " + m.pos_top.ToStr() + "</red>]"
		m.bottom_right_info.text = "[" + m.pos_right.ToStr() + ", " + m.pos_bottom.ToStr() + "]"	' The width and height will also change if the top-left coordinates change.
	'}
	else if m.adjust_corner = true and m.item_selected = 1
	'{
		m.bottom_right_info.text = "[<red>" + m.pos_right.ToStr() + ", " + m.pos_bottom.ToStr() + "</red>]"
	'}
	else
	'{
		m.top_left_info.text = "[" + m.pos_left.ToStr() + ", " + m.pos_top.ToStr() + "]"
		m.bottom_right_info.text = "[" + m.pos_right.ToStr() + ", " + m.pos_bottom.ToStr() + "]"
	'}
	end if
'}
end sub

sub Scroll( scroll_type as integer )
'{
	if m.item_selected = 0
	'{
		if scroll_type = 1		' Up
		'{
			m.pos_top--

			m.pos_bottom++
		'}
		else if scroll_type = 2	' Down
		'{
			m.pos_top++

			m.pos_bottom--
		'}
		else if scroll_type = 3 ' Left
		'{
			m.pos_left--

			m.pos_right++
		'}
		else if scroll_type = 4 ' Right
		'{
			m.pos_left++

			m.pos_right--
		'}
		end if

		m.view_window.translation = [ m.pos_left, m.pos_top ]

	'}
	else if m.item_selected = 1
	'{
		if scroll_type = 1		' Up
		'{
			m.pos_bottom--
		'}
		else if scroll_type = 2	' Down
		'{
			m.pos_bottom++
		'}
		else if scroll_type = 3 ' Left
		'{
			m.pos_right--
		'}
		else if scroll_type = 4 ' Right
		'{
			m.pos_right++
		'}
		end if
	'}
	end if

	m.view_window.height = m.pos_bottom
	m.view_window.width = m.pos_right

	UpdateOverscanInfoText()
'}
end sub

sub HandleScroll()
'{
	if m.scroll_type <> 0
	'{
		' Speed up the timer if the key was held down long enough.
		if m.long_scroll < 20
		'{
			m.long_scroll++

			if m.long_scroll = 5
			'{
				m.scroll_timer.duration = 0.1
			'}
			else if m.long_scroll = 20
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
			m.top.menu_state = 0	' Hide
		'}
		else if key = "OK"
		'{
			if m.item_selected = 0 or m.item_selected = 1
			'{
				if m.adjust_corner = false
				'{
					m.adjust_corner = true
				'}
				else
				'{
					m.adjust_corner = false
				'}
				end if

				UpdateOverscanInfoText()
			'}
			else if m.item_selected = 2	' Reset
			'{
				m.pos_top = 0
				m.pos_left = 0
				m.pos_right = m.global.preferred_screen_width
				m.pos_bottom = m.global.preferred_screen_height

				m.view_window.width = m.pos_right
				m.view_window.height = m.pos_bottom
				m.view_window.translation = [ m.pos_left, m.pos_top ]

				UpdateOverscanInfoText()
			'}
			else if m.item_selected = 3	' Apply
			'{
				m.global.overscan_offset_x = m.pos_left
				m.global.overscan_offset_y = m.pos_top
				m.global.screen_width = m.pos_right
				m.global.screen_height = m.pos_bottom

				m.global.save_window_dimensions = true
			'}
			end if
		'}
		else if key = "up" or key = "down" or key = "left" or key = "right"
		'{
			if m.adjust_corner = true
			'{
				if key = "up"
				'{
					m.scroll_type = 1
				'}
				else if key = "down"
				'{
					m.scroll_type = 2
				'}
				else if key = "left"
				'{
					m.scroll_type = 3
				'}
				else' if key = "right"
				'{
					m.scroll_type = 4
				'}
				end if

				HandleScroll()
				m.scroll_timer.control = "start"
			'}
			else
			'{
				if key = "left"
				'{
					if m.item_selected > 0
					'{
						m.options_columns.GetChild( m.item_selected * 2 + 1 ).color = m.button_color
						m.item_selected--
						m.options_columns.GetChild( m.item_selected * 2 + 1 ).color = m.button_selected_color
					'}
					end if
				'}
				else if key = "right"
				'{
					if m.item_selected < 3
					'{
						m.options_columns.GetChild( m.item_selected * 2 + 1 ).color = m.button_color
						m.item_selected++
						m.options_columns.GetChild( m.item_selected * 2 + 1 ).color = m.button_selected_color
					'}
					end if
				'}
				end if
			'}
			end if
		'}
		end if
	'}
	else if not press
	'{
		if key = "up" or key = "down" or key = "left" or key = "right"
		'{
			if m.adjust_corner = true
			'{
				m.scroll_type = 0

				m.long_scroll = 0
				m.scroll_timer.duration = m.scroll_speed

				m.scroll_timer.control = "stop"
			'}
			end if
		'}
		end if
	'}
	end if

	return true
'}
end function
	