'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.row_width = 700
	m.row_height = 75

	m.content_index = 0
	m.content_index_start = 0
	m.content_index_end = 0
	m.loading_content = false

	m.scroll_delta = 0

	m.selected_row_index = 0

	m.visible_rows = 0
	m.max_visible_rows = Int( m.global.screen_height / m.row_height )
	if m.max_visible_rows > 0 and m.max_visible_rows mod 2 = 0
	'{
		m.max_visible_rows--
	'}
	end if

	m.row_color = "0x00000000"
	m.row_selected_color = "0xFFFFFF30"

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
	m.container.height = m.max_visible_rows * m.row_height
	m.container.color = "0x00000000"

	''''''''''''''''''''''''

	for i = 0 to m.max_visible_rows - 1
	'{
		row = CreateObject( "roSGNode", "Rectangle" )
		row.width = m.row_width
		row.height = m.row_height
		row.translation = [ 0, i * m.row_height ]
		row.color = m.row_color

			name_label = CreateObject( "roSGNode", "ScrollingLabel" )
			name_label.maxWidth = m.row_width - ( 20 + 20 + 20 + 150 )
			name_label.height = m.row_height
			name_label.translation = [ 20, 0 ]
			name_label.vertAlign = "center"
			name_label.font = "font:MediumSystemFont"
			name_label.repeatCount = 0
			row.AppendChild( name_label )

			extra_label = CreateObject( "roSGNode", "Label" )
			extra_label.width = 150
			extra_label.height = m.row_height
			extra_label.translation = [ 20 + name_label.maxWidth + 20, 0 ]
			extra_label.horizAlign = "right"
			extra_label.vertAlign = "center"
			extra_label.font = "font:MediumSystemFont"
			row.AppendChild( extra_label )

		m.container.AppendChild( row )
	'}
	end for

	''''''''''''''''''''''''

	m.panel.AppendChild( m.container )
	m.top.AppendChild( m.panel )

	m.top.ObserveField( "visible", "OnVisible" )

	''''''''''''''''''''''''

	m.vod_info = CreateObject( "roSGNode", "VODInfo" )

	m.vod_info.ObserveField( "menu_state", "OnVODInfoStateChanged" )

	m.top.AppendChild( m.vod_info )
'}
end sub

sub OnDetailsContentChange()
'{
	m.vod_info.details_content = m.top.details_content
'}
end sub

sub OnVODInfoStateChanged()
'{
	if m.vod_info.menu_state = 0
	'{
		m.vod_info.visible = false
		m.vod_info.SetFocus( false )

		m.top.menu_state = 1
	'}
	else if m.vod_info.menu_state = 1
	'{
		m.vod_info.visible = true
		m.vod_info.SetFocus( true )
	'}
	end if
'}
end sub

sub OnVisible()
'{
	if m.top.visible = true and (m.top.content = invalid or m.top.content.GetChildCount() = 0)
	'{
		m.content_index = 0

		m.container.translation = [ 0, m.global.overscan_offset_y ]
		m.container.GetChild( m.selected_row_index ).color = m.row_color
		if m.global.loading_content = true
		'{
			m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Loading Content..."
		'}
		else
		'{
			m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "No Content Available"
		'}
		end if

		m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 1 ).text = ""
	'}
	end if
'}
end sub

function GetContentIndex( index as integer )
'{
	content_index = -1

	' We got content from the end of the list and it's looped around.
	if m.content_index_start > m.content_index_end
	'{
		' The index we're looking at is at the end of the list, but before content_index 0
		if index >= m.content_index_start
		'{
			content_index = m.global.content_limit - ( m.top.content.total - index )
		'}
		else if index <= m.content_index_end
		'{
			content_index = index
		'}
		end if
	'}
	else
	'{
		offset = index - m.content_index_start
		if offset >= 0 and offset < m.global.content_limit
		'{
			content_index = offset
		'}
		end if
	'}
	end if

	return content_index
'}
end function

sub SetRowText( content_index as integer, row_index as integer )
'{
	if content_index <> -1
	'{
		content = m.top.content.GetChild( content_index )

		if content.Title <> ""
		'{
			m.container.GetChild( row_index ).GetChild( 0 ).text = content.Title
		'}
		else if m.global.current_content_type = 2
		'{
			m.container.GetChild( row_index ).GetChild( 0 ).text = "Episode"
		'}
		else
		'{
			m.container.GetChild( row_index ).GetChild( 0 ).text = ""
		'}
		end if

		if m.global.current_content_type = 1	' Movies
		'{
			m.container.GetChild( row_index ).GetChild( 1 ).text = content.Year
		'}
		else if m.global.current_content_type = 2
		'{
			if content.Episode <> -1	' TV Shows
			'{
				m.container.GetChild( row_index ).GetChild( 1 ).text = content.Episode.ToStr()
			'}
			else
			'{
				m.container.GetChild( row_index ).GetChild( 1 ).text = content.Year
			'}
			end if
		'}
		else
		'{
			m.container.GetChild( row_index ).GetChild( 1 ).text = ""
		'}
		end if
	'}
	else
	'{
		m.container.GetChild( row_index ).GetChild( 0 ).text = "Loading Content..."
		m.container.GetChild( row_index ).GetChild( 1 ).text = ""
	'}
	end if
'}
end sub

sub OnContentChange()
'{
	' We've loaded a group, but don't know it's length yet. Reset the content_index.
	if m.global.content_offset < 0
	'{
		m.content_index = 0
	'}
	end if

	if m.top.content <> invalid
	'{
		m.visible_rows = m.top.content.GetChildCount()'m.top.content.total

		if m.visible_rows > 0
		'{
			if m.top.content.total > m.global.content_limit
			'{
				if m.global.content_offset < 0
				'{
					m.content_index_start = ( m.top.content.total + m.global.content_offset ) mod m.top.content.total
				'}
				else
				'{
					m.content_index_start = m.global.content_offset
				'}
				end if
				m.content_index_end = ( m.content_index_start + ( m.global.content_limit - 1 ) ) mod m.top.content.total
			'}
			else
			'{
				m.content_index_start = 0
				m.content_index_end = m.top.content.total - 1
			'}
			end if

			first_visible_content_index = 0

			content_index = GetContentIndex( m.content_index )
			if content_index <> -1
			'{
				if m.visible_rows > m.max_visible_rows
				'{
					m.visible_rows = m.max_visible_rows

					m.selected_row_index = INT( m.visible_rows / 2 )

					first_visible_content_index = ( content_index + m.top.content.GetChildCount() - m.selected_row_index ) mod m.top.content.GetChildCount()
				'}
				else
				'{
					m.container.GetChild( m.selected_row_index ).color = m.row_color

					m.selected_row_index = 0
				'}
				end if

				' Center the container vertically.
				m.container.translation = [ 0, ( m.global.screen_height - ( m.visible_rows * m.row_height ) ) / 2 ]

				for i = 0 to m.visible_rows - 1
				'{
					if i = m.selected_row_index
					'{
						m.container.GetChild( i ).GetChild( 0 ).repeatCount = -1
						m.container.GetChild( i ).color = m.row_selected_color
					'}
					else
					'{
						m.container.GetChild( i ).GetChild( 0 ).repeatCount = 0
						m.container.GetChild( i ).color = m.row_color
					'}
					end if

					content_index = ( first_visible_content_index + i ) mod m.top.content.GetChildCount()

					SetRowText( content_index, i )
				'}
				end for
			'}
			else
			'{
				m.visible_rows = 0
				m.content_index_start = 0
				m.content_index_end = 0
			'}
			end if
		'}
		end if
	'}
	else
	'{
		m.visible_rows = 0
	'}
	end if

	for i = m.visible_rows to m.max_visible_rows - 1
	'{
		m.container.GetChild( i ).GetChild( 0 ).text = ""
		m.container.GetChild( i ).GetChild( 1 ).text = ""
	'}
	end for

	if m.visible_rows = 0
	'{
		m.content_index = 0

		m.container.GetChild( m.selected_row_index ).color = m.row_color
		if m.global.loading_content = true
		'{
			m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Loading Content..."
		'}
		else
		'{
			m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "No Content Available"
		'}
		end if

		m.container.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 1 ).text = ""
	'}
	end if

	m.loading_content = false
'}
end sub

sub Scroll( scroll_type as integer )
'{
	' Prevents us from scrolling if there's a slow network connection while we're navigating the menu items.
	if m.global.loading_content = true
	'{
		return
	'}
	end if

	scroll_offset = 1
	if scroll_type >= 10
	'{
		scroll_offset = m.visible_rows
	'}
	end if

	first_visible_content_index = 0

	if scroll_type = 1 or scroll_type = 10	' Move Up
	'{
		if m.visible_rows = m.top.content.GetChildCount()
		'{
			if m.selected_row_index > 0
			'{
				m.container.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = 0
				m.container.GetChild( m.selected_row_index ).color = m.row_color
				
				if scroll_type = 1
				'{
					m.selected_row_index--
				'}
				else' if scroll_type = 10
				'{
					m.selected_row_index = 0
				'}
				end if

				m.container.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = -1
				m.container.GetChild( m.selected_row_index ).color = m.row_selected_color
			'}
			end if

			m.content_index = m.selected_row_index
		'}
		else
		'{
			m.content_index = ( m.content_index + m.top.content.total - scroll_offset ) mod m.top.content.total

			first_visible_content_index = ( m.content_index + m.top.content.total - m.selected_row_index ) mod m.top.content.total

			m.scroll_delta = m.scroll_delta - scroll_offset
		'}
		end if
	'}
	else' if scroll_type = 2 or scroll_type = 20	' Move Down
	'{
		if m.visible_rows = m.top.content.GetChildCount()
		'{
			if m.selected_row_index < m.visible_rows - 1
			'{
				m.container.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = 0
				m.container.GetChild( m.selected_row_index ).color = m.row_color
				
				if scroll_type = 2
				'{
					m.selected_row_index++
				'}
				else' if scroll_type = 20
				'{
					m.selected_row_index = m.visible_rows - 1
				'}
				end if

				m.container.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = -1
				m.container.GetChild( m.selected_row_index ).color = m.row_selected_color
			'}
			end if

			m.content_index = m.selected_row_index
		'}
		else
		'{
			m.content_index = ( m.content_index + scroll_offset ) mod m.top.content.total

			first_visible_content_index = ( m.content_index + m.top.content.total - m.selected_row_index ) mod m.top.content.total

			m.scroll_delta = m.scroll_delta + scroll_offset
		'}
		end if
	'}
	end if

	for i = 0 to m.visible_rows - 1
	'{
		content_index = ( first_visible_content_index + i ) mod m.top.content.total
		content_index = GetContentIndex( content_index )

		SetRowText( content_index, i )
	'}
	end for
'}
end sub

sub HandleScroll()
'{
	if ( m.top.content <> invalid ) and ( m.top.content.GetChildCount() > 0 ) and ( m.scroll_type <> 0 )
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

sub LoadContentChunk()
'{
	if m.top.content <> invalid and m.global.content_limit <= m.top.content.GetChildCount() and m.loading_content = false
	'{
		content_index = GetContentIndex( m.content_index )

		offset = INT( m.global.content_limit / 2 ) - m.visible_rows

		if content_index = -1 or m.scroll_delta <= -( offset ) or m.scroll_delta >= offset
		'{
			m.scroll_delta = 0

			m.top.content_offset = ( m.content_index + m.top.content.total - INT( m.global.content_limit / 2 ) ) mod m.top.content.total

			m.loading_content = true
			m.top.update_content = true
		'}
		end if
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
			if m.top.menu_state = 1
			'{
				if m.top.content <> invalid and m.top.content.GetChildCount() > 0
				'{
					content_index = GetContentIndex( m.content_index )

					if content_index <> -1
					'{
						m.top.content_index = content_index

						m.top.menu_state = 0	' Hide
					'}
					end if
				'}
				end if

				return true
			'}
			end if
		'}
		else if key = "up" or key = "down" or key = "rewind" or key = "fastforward"
		'{
			if m.top.menu_state = 1
			'{
				if key = "up"
				'{
					m.scroll_type = 1
				'}
				else if key = "down"
				'{
					m.scroll_type = 2
				'}
				else if key = "rewind"
				'{
					m.scroll_type = 10
				'}
				else' if key = "fastforward"
				'{
					m.scroll_type = 20
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
			if m.top.menu_state = 1
			'{
				m.top.menu_state = -1	' Close
			'}
			else
			'{
				m.top.menu_state = 1	' Show
			'}
			end if

			return true
		'}
		else if key = "right"
		'{
			if m.top.menu_state = 1		' Only display the VOD Info if the menu is showing.
			'{
				if m.top.content <> invalid and m.top.content.GetChildCount() > 0
				'{
					content_index = GetContentIndex( m.content_index )
					if content_index <> -1
					'{
						content = m.top.content.GetChild( content_index )

						if m.vod_info.content = invalid or m.vod_info.content.isSameNode( content ) = false
						'{
							m.vod_info.content = content

							m.global.loading_details = 1	' Loading VOD Menu details.
							if m.global.current_content_type = 2 and m.vod_info.content.Episode <> -1	' TV Shows
							'{
								m.global.details_name = m.vod_info.content.SeriesTitle
								m.global.details_season = m.vod_info.content.Season.ToStr()
								m.global.details_episode = m.vod_info.content.Episode.ToStr()
							'}
							else' if m.global.current_content_type = 1	' Movies
							'{
								m.global.details_name = m.vod_info.content.Title
							'}
							end if
							m.global.details_year = m.vod_info.content.Year
							m.global.load_details = true
						'}
						end if

						m.vod_info.menu_state = 1	' Show
					'}
					end if
				'}
				end if
			'}
			end if

			return true
		'}
		end if
	'}
	else if not press
	'{
		if key = "up" or key = "down" or key = "rewind" or key = "fastforward"
		'{
			LoadContentChunk()

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
