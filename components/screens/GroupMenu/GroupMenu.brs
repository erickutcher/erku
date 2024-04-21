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
	m.row_title_offset = 125

	m.content_index = 0
	m.first_visible_content_index = 0

	m.content_index_start = 0
	m.content_index_end = 0
	m.loading_content = false

	m.current_content_total = 0
	m.current_group_id = 0
	m.current_group_title = ""

	m.selected_row_index = -1
	m.content_row_offset = 2	' The first content row after our group title.

	m.visible_rows = 0
	m.max_visible_rows = Int( ( m.global.screen_height - m.row_title_offset ) / m.row_height ) - 1

	m.row_color = "0x00000000"
	m.row_selected_color = "0xFFFFFF30"

	m.parent_stack = CreateObject( "roArray", 0, true )

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
	m.container.height = m.row_title_offset + ( m.max_visible_rows * m.row_height )
	m.container.translation = [ 0, m.row_height ]
	m.container.color = "0x00000000"

	''''''''''''''''''''''''

	m.row_title = CreateObject( "roSGNode", "Rectangle" )
	m.row_title.width = m.row_width
	m.row_title.height = m.row_height
	m.row_title.translation = [ 0, 0 ]
	m.row_title.color = m.row_selected_color

		label = CreateObject( "roSGNode", "MultiStyleLabel" )
		label.width = 50
		label.height = m.row_height
		label.translation = [ 20, 0 ]
		label.vertAlign = "center"
		label.drawingStyles = m.drawing_styles
		label.text = "<icon>" + chr( 59653 ) + "</icon>"	' Left Arrow
		m.row_title.AppendChild( label )

		label = CreateObject( "roSGNode", "ScrollingLabel" )
		label.maxWidth = m.row_width - ( 20 + 50 + 10 + 20 )
		label.height = m.row_height
		label.translation = [ 10 + 50 + 10, 0 ]
		label.vertAlign = "center"
		label.font = "font:LargeBoldSystemFont"
		m.row_title.AppendChild( label )

	m.container.AppendChild( m.row_title )

	row_line = CreateObject( "roSGNode", "Rectangle" )
	row_line.width = m.row_width
	row_line.height = 3
	row_line.translation = [ 0, m.row_height + 25 ]
	row_line.color = "#FFFFFFFF"
	m.container.AppendChild( row_line )

	''''''''''''''''''''''''

	for i = 0 to m.max_visible_rows - 1
	'{
		row = CreateObject( "roSGNode", "Rectangle" )
		row.width = m.row_width
		row.height = m.row_height
		row.translation = [ 0, m.row_title_offset + ( i * m.row_height ) ]
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

	''''''''''''''''''''''''

	m.current_content_type = -1
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
		if m.global.loading_content = true
		'{
			m.row_title.GetChild( 1 ).text = "Loading Groups..."
		'}
		else if m.current_group_title <> ""
		'{
			m.row_title.GetChild( 1 ).text = m.current_group_title
		'}
		else
		'{
			m.row_title.GetChild( 1 ).text = "No Groups Available"
		'}
		end if
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
			content_index = m.global.group_content_limit - ( m.top.content.total - index )
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
		if offset >= 0 and offset < m.global.group_content_limit
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
			m.container.GetChild( m.content_row_offset + row_index ).GetChild( 0 ).text = content.Title
		'}
		else if m.global.current_content_type = 2 and content.Type = 2	' TV Shows and Season
		'{
			m.container.GetChild( m.content_row_offset + row_index ).GetChild( 0 ).text = "Season"
		'}
		else
		'{
			m.container.GetChild( m.content_row_offset + row_index ).GetChild( 0 ).text = ""
		'}
		end if

		extra_label_text = ""
		if m.global.current_content_type = 1	' Movies
		'{
			extra_label_text = content.Year
		'}
		else if m.global.current_content_type = 2 	' TV Shows
		'{
			' Season group.
			if content.Type = 2 and content.Season <> -1
			'{
				extra_label_text = content.Season.ToStr()
			'}
			else
			'{
				extra_label_text = content.Year
			'}
			end if
		'}
		end if
		m.container.GetChild( m.content_row_offset + row_index ).GetChild( 1 ).text = extra_label_text
	'}
	else
	'{
		m.container.GetChild( m.content_row_offset + row_index ).GetChild( 0 ).text = "Loading Group..."
		m.container.GetChild( m.content_row_offset + row_index ).GetChild( 1 ).text = ""
	'}
	end if
'}
end sub

sub OnEnterGroupContentChange()
'{
	if m.top.enter_group_content <> invalid
	'{
		group_count = m.top.enter_group_content.GetChildCount()
		if group_count > 0
		'{
			m.parent_stack.Clear()	' Remove any previous entries and start fresh.

			' Save all the previous groups before the TV Channel's group's parent.
			for i = 0 to group_count - 2
			'{
				group = m.top.enter_group_content.GetChild( i )

				m.parent_stack.Push( { "group_id": group.group_id,
									   "group_title": group.Title,
									   "content_total": 0,
									   "content_index": 0,
									   "first_visible_content_index": 0,
									   "selected_row_index": -1 } )
			'}
			end for

			m.current_group_title = m.top.enter_group_content.GetChild( group_count - 1 ).Title
			m.current_group_id = m.top.enter_group_content.GetChild( group_count - 1 ).group_id

			m.first_visible_content_index = 0

			' Select the group title
			if m.selected_row_index <> -1
			'{
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
			'}
			end if
			m.selected_row_index = -1
			m.container.GetChild( 0 ).color = m.row_selected_color

			m.content_index = 0

			' Load the TV Channel's group's parent.
			m.global.loading_content = true
			m.global.group_id = m.current_group_id
			m.global.group_content_offset = 0
			m.global.load_group_chunk = true
		'}
		end if
	'}
	end if
'}
end sub

sub OpenParentGroup()
'{
	' Deselect the group title.
	m.container.GetChild( 0 ).color = m.row_color

	parent_info = m.parent_stack.Pop()

	m.current_group_title = parent_info.group_title

	m.current_group_id = parent_info.group_id
	m.content_index = parent_info.content_index
	m.first_visible_content_index = parent_info.first_visible_content_index
	m.selected_row_index = parent_info.selected_row_index

	content_offset = m.content_index - INT( m.global.group_content_limit / 2 )
	if content_offset < 0
	'{
		content_offset = 0
	'}
	else if content_offset > ( parent_info.content_total - m.global.group_content_limit )
	'{
		content_offset = parent_info.content_total - m.global.group_content_limit
	'}
	end if

	m.top.content_offset = content_offset

	m.global.group_id = parent_info.group_id

	m.loading_content = true
	m.top.update_content = true
'}
end sub

sub OpenChildGroup()
'{
	' Save the current state.
	m.parent_stack.Push( { "group_id": m.current_group_id,
						   "group_title": m.current_group_title,
						   "content_total": m.current_content_total,
						   "content_index": m.content_index,
						   "first_visible_content_index": m.first_visible_content_index,
						   "selected_row_index": m.selected_row_index } )

	m.current_group_title = ""

	m.first_visible_content_index = 0

	' Select the group title
	if m.selected_row_index <> -1
	'{
		m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
		m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
	'}
	end if
	m.selected_row_index = -1
	m.container.GetChild( 0 ).color = m.row_selected_color

	m.content_index = 0
'}
end sub

sub OnContentChange()
'{
	' Reset the first_visible_content_index if we came from the main menu.
	if m.current_content_type <> m.global.current_content_type
	'{
		m.first_visible_content_index = 0
	'}
	end if

	m.current_content_type = m.global.current_content_type

	if m.top.content <> invalid
	'{
		m.visible_rows = m.top.content.GetChildCount()

		if m.top.group_content_type = 1	' Search group content.
		'{
			if m.current_content_type = 0	' Live TV
			'{
				m.selected_row_index = 2
				m.content_index = 2
			'}
			else if m.current_content_type = 1 or m.current_content_type = 2	' Movies/TV Shows
			'{
				m.selected_row_index = 3
				m.content_index = 3
			'}
			end if
		'}
		end if

		' The item we selected was a group.
		if m.top.content.group_id <> m.current_group_id
		'{
			OpenChildGroup()
	
			m.current_group_id = m.top.content.group_id
		'}
		end if

		if m.selected_row_index <> -1
		'{
			m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
			m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color

			' Select the group title if we don't have enough rows.
			if m.selected_row_index >= m.visible_rows
			'{
				m.selected_row_index = -1
				m.content_index = 0

				m.container.GetChild( 0 ).color = m.row_selected_color
			'}
			else
			'{
				m.container.GetChild( 0 ).color = m.row_color
			'}
			end if
		'}
		else
		'{
			m.container.GetChild( 0 ).color = m.row_selected_color
		'}
		end if

		m.row_title.GetChild( 1 ).text = m.top.content.Title

		m.current_content_total = m.top.content.total
		m.current_group_title = m.top.content.Title

		if m.visible_rows > 0
		'{
			if m.top.content.total > m.global.group_content_limit
			'{
				if m.global.group_content_offset < 0
				'{
					m.content_index_start = ( m.top.content.total + m.global.group_content_offset ) mod m.top.content.total
				'}
				else
				'{
					m.content_index_start = m.global.group_content_offset
				'}
				end if
				m.content_index_end = ( m.content_index_start + ( m.global.group_content_limit - 1 ) ) mod m.top.content.total
			'}
			else
			'{
				m.content_index_start = 0
				m.content_index_end = m.top.content.total - 1
			'}
			end if

			if m.visible_rows > m.max_visible_rows
			'{
				m.visible_rows = m.max_visible_rows
			'}
			end if

			for i = 0 to m.visible_rows - 1
			'{
				if i = m.selected_row_index
				'{
					m.container.GetChild( m.content_row_offset + i ).GetChild( 0 ).repeatCount = -1
					m.container.GetChild( m.content_row_offset + i ).color = m.row_selected_color
				'}
				else
				'{
					m.container.GetChild( m.content_row_offset + i ).GetChild( 0 ).repeatCount = 0
					m.container.GetChild( m.content_row_offset + i ).color = m.row_color
				'}
				end if

				content_index = GetContentIndex( m.first_visible_content_index + i )

				SetRowText( content_index, i )
			'}
			end for
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
		m.container.GetChild( m.content_row_offset + i ).GetChild( 0 ).text = ""
		m.container.GetChild( m.content_row_offset + i ).GetChild( 1 ).text = ""
	'}
	end for

	if m.visible_rows = 0
	'{
		m.content_index = 0

		if m.global.loading_content = true
		'{
			m.row_title.GetChild( 1 ).text = "Loading Groups..."
		'}
		else if m.current_group_title <> ""
		'{
			m.row_title.GetChild( 1 ).text = m.current_group_title
		'}
		else
		'{
			m.row_title.GetChild( 1 ).text = "No Groups Available"
		'}
		end if

		' Select the group title
		if m.selected_row_index <> -1
		'{
			m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
			m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
		'}
		end if
		m.selected_row_index = -1
		m.container.GetChild( 0 ).color = m.row_selected_color
	'}
	end if

	' We've loaded a group, but don't know it's length yet. Reset the content_index.
	if m.global.group_content_offset < 0
	'{
		m.content_index = 0
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

	if scroll_type = 1 or scroll_type = 10	' Move Up
	'{
		if m.content_index > 0
		'{
			if m.selected_row_index > 0
			'{
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
				
				if scroll_type = 1
				'{
					m.selected_row_index--
				'}
				else' if scroll_type = 10
				'{
					m.selected_row_index = 0
				'}
				end if

				m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = -1
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_selected_color
			'}
			else
			'{
				m.first_visible_content_index = m.first_visible_content_index - scroll_offset
			'}
			end if
		'}
		else
		'{
			' The first content row is selected.
			' Move it to the group title row.
			if m.selected_row_index <> -1
			'{
				m.container.GetChild( m.content_row_offset ).color = m.row_color
				m.selected_row_index = -1
				m.container.GetChild( 0 ).color = m.row_selected_color
			'}
			end if
		'}
		end if
	'}
	else' if scroll_type = 2 or scroll_type = 20	' Move Down
	'{
		' The group title is currently selected.
		' Move it to the first content row.
		if m.selected_row_index = -1
		'{
			m.container.GetChild( 0 ).color = m.row_color
			m.selected_row_index = 0
			m.container.GetChild( m.content_row_offset ).color = m.row_selected_color
		'}
		else
		'{
			if m.selected_row_index < m.visible_rows - 1
			'{
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
				
				if scroll_type = 2
				'{
					m.selected_row_index++
				'}
				else' if scroll_type = 20
				'{
					m.selected_row_index = m.visible_rows - 1
				'}
				end if

				m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = -1
				m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_selected_color
			'}
			else
			'{
				m.first_visible_content_index = m.first_visible_content_index + scroll_offset
			'}
			end if
		'}
		end if
	'}
	end if

	if m.first_visible_content_index < 0
	'{
		m.first_visible_content_index = 0
	'}
	else if m.first_visible_content_index > ( m.top.content.total - m.visible_rows )
	'{
		m.first_visible_content_index = m.top.content.total - m.visible_rows
	'}
	end if

	m.content_index = m.first_visible_content_index + m.selected_row_index

	for i = 0 to m.visible_rows - 1
	'{
		content_index = m.first_visible_content_index + i
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
	if m.top.content <> invalid and m.global.group_content_limit <= m.top.content.GetChildCount() and m.loading_content = false
	'{
		' Update if it's not on the group name row, or if it is and the scroll button is held down.
		if m.selected_row_index <> -1 or ( m.selected_row_index = -1 and m.content_index_start > 0 )
		'{
			if ( m.content_index_start > 0 and ( m.content_index - m.content_index_start ) <= m.visible_rows ) or ( m.content_index_end < ( m.top.content.total - 1 ) and m.content_index >= ( m.content_index_end - m.visible_rows ) )
			'{
				content_offset = m.content_index - INT( m.global.group_content_limit / 2 )
				if content_offset < 0
				'{
					content_offset = 0
				'}
				else if content_offset > ( m.top.content.total - m.global.group_content_limit )
				'{
					content_offset = m.top.content.total - m.global.group_content_limit
				'}
				end if

				m.top.content_offset = content_offset

				m.loading_content = true
				m.top.update_content = true
			'}
			end if
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
			if m.selected_row_index = -1	' Our group title is selected.
			'{
				if m.parent_stack.Count() > 0
				'{
					OpenParentGroup()
				'}
				else
				'{
					' Reset values.
					m.current_group_title = ""
					m.current_content_total = 0

					m.top.menu_state = -1	' Close
				'}
				end if
			'}
			else
			'{
				if m.top.content <> invalid and m.top.content.GetChildCount() > 0
				'{
					content_index = GetContentIndex( m.content_index )
					if content_index <> -1
					'{
						m.top.content_index = content_index
					'}
					end if
				'}
				end if
			'}
			end if

			return true
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
				if m.selected_row_index = -1	' Our group title is selected.
				'{
					if m.parent_stack.Count() > 0
					'{
						OpenParentGroup()
					'}
					else
					'{
						' Reset values.
						m.current_group_title = ""
						m.current_content_total = 0

						m.top.menu_state = -1	' Close
					'}
					end if
				'}
				else	' Move to the group title row.
				'{
					m.container.GetChild( m.content_row_offset + m.selected_row_index ).GetChild( 0 ).repeatCount = 0
					m.container.GetChild( m.content_row_offset + m.selected_row_index ).color = m.row_color
					m.selected_row_index = -1
					m.container.GetChild( 0 ).color = m.row_selected_color

					m.content_index = m.first_visible_content_index
				'}
				end if
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
				' Load information for TV Shows only.
				if m.global.current_content_type = 2	' TV Shows
				'{
					if m.top.content <> invalid and m.top.content.GetChildCount() > 0
					'{
						content_index = GetContentIndex( m.content_index )
						if content_index <> -1
						'{
							content = m.top.content.GetChild( content_index )

							' Make sure we're loading information for a Series or Season group.
							if content.type <> 0
							'{
								if m.vod_info.content = invalid or m.vod_info.content.isSameNode( content ) = false
								'{
										m.vod_info.content = content

										m.global.loading_details = 3	' Loading Group Menu details.
										if m.vod_info.content.type = 2	' Season
										'{
											' The season needs to supply its series name.
											m.global.details_name = m.vod_info.content.SeriesTitle
											m.global.details_season = m.vod_info.content.Season.ToStr()
											m.global.details_episode = ""
										'}
										else' if m.vod_info.content.type = 1	' Series
										'{
											m.global.details_name = m.vod_info.content.Title
											m.global.details_season = ""
											m.global.details_episode = ""
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
