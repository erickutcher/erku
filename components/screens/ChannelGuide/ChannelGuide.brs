'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.row_width = 500
	m.row_height = 75

	m.column_time_interval = 1800
	m.column_count = 4

	m.first_visible_content_index = 0

	m.content_index = 0
	m.content_index_start = 0
	m.content_index_end = 0
	m.loading_content = false

	m.reloading_content = false
	m.last_content_total = 0

	m.scroll_delta = 0

	m.selected_row_index = 0
	m.channel_list_selected = true

	' Select items that fall within the first column instead of adjusting columns.
	m.selected_program_index = 0
	m.first_column_items = []

	m.visible_rows = 0
	m.max_visible_rows = 9
	if m.max_visible_rows > 0 and m.max_visible_rows mod 2 = 0
	'{
		m.max_visible_rows--
	'}
	end if

	m.row_color = "0x00000000"
	m.row_selected_color = "0xFFFFFF30"

	m.progress_bar_color = "0x0060C0E0"

	m.program_index_offset = 0

	''''''''''''''''''''''''

	m.scroll_speed = 0.2

	m.scroll_timer = CreateObject( "roSGNode", "Timer" )
	m.scroll_timer.repeat = true
	m.scroll_timer.duration = 0.5
	m.scroll_timer.ObserveField( "fire", "HandleScroll" )

	m.scroll_type = 0	' 0 = off, 1 = up, 2 = down
	m.long_scroll = 0	' If up or down are held down for 2.0 seconds.

	''''''''''''''''''''''''

	' Enable when visible, disable when hidden
	m.update_timer = CreateObject( "roSGNode", "Timer" )
	m.update_timer.repeat = true
	m.update_timer.duration = 10
	m.update_timer.ObserveField( "fire", "UpdateTimeBar" )

	m.date_time = CreateObject( "roDateTime" )

	m.time_bar_time_offset = 0

	m.first_time_column_time = GetOffsetTime( m.time_bar_time_offset )
	m.last_first_time_column_time = m.first_time_column_time
	m.last_time = m.first_time_column_time

	m.top.ObserveField( "visible", "OnVisible" )

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = "#00000000"
	m.panel.width = m.global.screen_width
	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]

	bottom_pane = CreateObject( "roSGNode", "Rectangle" )
	bottom_pane.color = m.global.panel_color
	bottom_pane.width = m.panel.width
	bottom_pane.height = ( m.max_visible_rows + 1 ) * m.row_height
	bottom_pane.translation = [ 0, m.panel.height - bottom_pane.height ]

	top_pane = CreateObject( "roSGNode", "Rectangle" )
	top_pane.color = "0x00000000"
	top_pane.width = m.panel.width
	top_pane.height = m.panel.height - bottom_pane.height

	''''''''''''''''''''''''

	m.time_bar_column_width = ( m.panel.width - ( m.panel.boundingRect()[ "x" ] + m.row_width ) ) / m.column_count

	''''''''''''''''''''''''

	m.video_width = 512
	m.video_height = 288
	m.video_player_width = m.video_width + 20

	program_info_width = m.panel.width - ( m.video_player_width - 1 )

	channel_logo_width = 180
	channel_logo_height = 180

	program_name_width = program_info_width - 20 - ( channel_logo_width + 20 ) - 20

	channel_name_width = program_name_width

	program_description_width = program_name_width

	m.program_info = CreateObject( "roSGNode", "Rectangle" )
	m.program_info.color = m.global.panel_color
	m.program_info.width = program_info_width
	m.program_info.height = top_pane.height

		' Channel Logo
		m.channel_logo = CreateObject( "roSGNode", "Poster" )
		m.channel_logo.loadDisplayMode = "scaleToFit"
		m.channel_logo.width = channel_logo_width
		m.channel_logo.height = channel_logo_height
		m.channel_logo.loadWidth = channel_logo_width
		m.channel_logo.loadHeight = channel_logo_height
		m.channel_logo.translation = [ 20, 20 ]
		m.channel_logo.failedBitmapUri = "pkg:/images/no-channel.png"
		m.channel_logo.uri = "pkg:/images/no-channel.png"
		m.program_info.AppendChild( m.channel_logo )

		' Channel Number
		m.channel_number = CreateObject( "roSGNode", "Label" )
		m.channel_number.width = channel_logo_width
		m.channel_number.numLines = 1
		m.channel_number.translation = [ 20, 20 + channel_logo_height + 20 ]
		m.channel_number.horizAlign = "center"
		m.program_info.AppendChild( m.channel_number )

		' Program Name
		m.program_name = CreateObject( "roSGNode", "ScrollingLabel" )
		m.program_name.maxWidth = program_name_width
		m.program_name.translation = [ 20 + channel_logo_width + 20, 20 ]
		m.program_name.font = "font:LargeSystemFont"
		m.program_info.AppendChild( m.program_name )
		program_name_height = m.program_name.boundingRect()[ "height" ]

		' Program Time / Channel Name
		m.channel_name = CreateObject( "roSGNode", "Label" )
		m.channel_name.width = channel_name_width
		m.channel_name.numLines = 1
		m.channel_name.translation = [ 20 + channel_logo_width + 20, 20 + program_name_height + 20 ]
		m.channel_name.font = "font:SmallSystemFont"
		m.program_info.AppendChild( m.channel_name )
		channel_name_height = m.channel_name.boundingRect()[ "height" ]

		' Program Description
		m.program_description = CreateObject( "roSGNode", "Label" )
		m.program_description.width = program_description_width
		m.program_description.numLines = 5
		m.program_description.translation = [ 20 + channel_logo_width + 20, 20 + program_name_height + 20 + channel_name_height + 20 ]
		m.program_description.wrap = true
		m.program_description.font = "font:SmallestSystemFont"
		m.program_info.AppendChild( m.program_description )

	''''''''''''''''''''''''

	m.time_bar = CreateObject( "roSGNode", "Rectangle" )
	m.time_bar.color = "0x000000FF"
	m.time_bar.width = m.panel.width
	m.time_bar.height = m.row_height

		time_bar_row = CreateObject( "roSGNode", "Rectangle" )
		time_bar_row.width = m.panel.width - 2
		time_bar_row.height = m.row_height - 1
		time_bar_row.translation = [ 1, 1 ]
		time_bar_row.color = m.global.panel_color

			time_bar_date = CreateObject( "roSGNode", "Label" )
			time_bar_date.width = m.row_width
			time_bar_date.height = m.row_height
			time_bar_date.translation = [ 20, 0 ]
			time_bar_date.vertAlign = "center"
			time_bar_date.font = "font:MediumSystemFont"

			time_bar_row.AppendChild( time_bar_date )

			for i = 0 to m.column_count - 1
			'{
				time_bar_date = CreateObject( "roSGNode", "Label" )
				time_bar_date.width = m.time_bar_column_width
				time_bar_date.height = m.row_height
				time_bar_date.translation = [ m.row_width + ( i * m.time_bar_column_width ), 0 ]
				time_bar_date.horizAlign = "left"
				time_bar_date.vertAlign = "center"
				time_bar_date.font = "font:MediumSystemFont"

				time_bar_row.AppendChild( time_bar_date )
			'}
			end for

	m.time_bar.AppendChild( time_bar_row )

	''''''''''''''''''''''''

	channels = CreateObject( "roSGNode", "Rectangle" )
	channels.width = m.row_width
	channels.height = m.max_visible_rows * m.row_height
	channels.translation = [ 0, m.time_bar.height ]
	channels.color = "0x000000FF"

		m.channels = CreateObject( "roSGNode", "Rectangle" )
		m.channels.width = m.row_width - 2
		m.channels.height = m.max_visible_rows * m.row_height - 2
		m.channels.translation = [ 1, 2 ]
		m.channels.color = m.global.panel_color

	channels.AppendChild( m.channels )

	''''''''''''''''''''''''

	programs = CreateObject( "roSGNode", "Rectangle" )
	programs.color = "0x000000FF"
	programs.width = m.time_bar_column_width * ( m.column_count + 1 )	' Fill the screen.
	programs.height = m.max_visible_rows * m.row_height
	programs.translation = [ channels.width, m.time_bar.height ]

		m.time_progress_bar = CreateObject( "roSGNode", "Rectangle" )
		m.time_progress_bar.color = m.progress_bar_color
		m.time_progress_bar.width = 0
		m.time_progress_bar.height = ( m.max_visible_rows + 1 ) * m.row_height

	programs.AppendChild( m.time_progress_bar )

		m.programs = CreateObject( "roSGNode", "Rectangle" )
		m.programs.color = "0x00000000"
		m.programs.width = m.time_bar_column_width * ( m.column_count + 1 )	' Fill the screen.
		m.programs.height = m.max_visible_rows * m.row_height

	programs.AppendChild( m.programs )

	''''''''''''''''''''''''

	for i = 0 to m.max_visible_rows - 1
	'{
		row = CreateObject( "roSGNode", "Rectangle" )
		row.width = m.row_width - 2
		row.height = m.row_height
		row.translation = [ 1, i * m.row_height - 1 ]
		row.color = m.row_color

			name_label = CreateObject( "roSGNode", "ScrollingLabel" )
			name_label.maxWidth = m.row_width - ( 20 + 20 + 20 + 120 )
			name_label.height = m.row_height
			name_label.translation = [ 20, 0 ]
			name_label.vertAlign = "center"
			name_label.font = "font:MediumSystemFont"
			name_label.repeatCount = 0
			row.AppendChild( name_label )

			number_label = CreateObject( "roSGNode", "Label" )
			number_label.width = 120
			number_label.height = m.row_height
			number_label.translation = [ 20 + name_label.maxWidth + 20, 0 ]
			number_label.horizAlign = "right"
			number_label.vertAlign = "center"
			number_label.font = "font:MediumSystemFont"
			row.AppendChild( number_label )

		m.channels.AppendChild( row )

		''''''''''''''''''''''''

		program_row = CreateObject( "roSGNode", "Rectangle" )
		program_row.width = m.time_bar_column_width * ( m.column_count + 1 )	' Fill the screen.
		program_row.height = m.row_height
		program_row.translation = [ 1, m.row_height * i + 1 ]
		program_row.color = "0x00000000"

			grid_rect_background = CreateObject( "roSGNode", "Rectangle" )
			grid_rect_background.width = program_row.width - 2
			grid_rect_background.height = m.row_height - 2
			grid_rect_background.translation = [ 1, 1 ]
			grid_rect_background.color = m.global.panel_color

				grid_rect = CreateObject( "roSGNode", "Rectangle" )
				grid_rect.width = program_row.width - 2
				grid_rect.height = m.row_height - 2
				grid_rect.color = m.row_color

					program = CreateObject( "roSGNode", "Label" )
					program.width = program_row.width - 20
					program.height = m.row_height
					program.vertAlign = "center"
					program.translation = [ 10, 0 ]
					program.font = "font:SmallestSystemFont"

					grid_rect.AppendChild( program )

				grid_rect_background.AppendChild( grid_rect )

		program_row.AppendChild( grid_rect_background )

		m.programs.AppendChild( program_row )
	'}
	end for

	''''''''''''''''''''''''

	top_pane.AppendChild( m.program_info )

	bottom_pane.AppendChild( m.time_bar )
	bottom_pane.AppendChild( channels )
	bottom_pane.AppendChild( programs )

	m.panel.AppendChild( top_pane )
	m.panel.AppendChild( bottom_pane )

	m.top.AppendChild( m.panel )

	' Add this last so that it can overlap the channel guide window.
	m.channel_options = CreateObject( "roSGNode", "ChannelOptions" )
	m.channel_options.ObserveField( "menu_state", "OnChannelOptionsStateChanged" )
	m.channel_options.ObserveField( "add_remove_favorite_state", "OnAddRemoveFavoriteStateChanged" )
	m.top.AppendChild( m.channel_options )
'}
end sub

sub OnReloadConent()
'{
	if m.top.reload_content = true
	'{
		m.top.reload_content = false

		if m.top.content <> invalid
		'{
			m.reloading_content = true

			m.last_content_total = m.top.content.total

			m.top.content_offset = ( m.content_index + m.top.content.total - INT( m.global.epg_content_limit / 2 ) ) mod m.top.content.total

			m.loading_content = true
			m.top.update_content = true
		'}
		end if
	'}
	end if
'}
end sub

sub OnAddRemoveFavoriteStateChanged()
'{
	if m.channel_options.content <> invalid
	'{
		if m.channel_options.add_remove_favorite_state = 0	' Remove Favorite
		'{
			m.channel_options.content.Favorite = false
		'}
		else if m.channel_options.add_remove_favorite_state = 1	' Add Favorite
		'{
			m.channel_options.content.Favorite = true
		'}
		end if

		m.channel_options.content = invalid

		if m.top.content <> invalid
		'{
			m.reloading_content = true

			m.last_content_total = m.top.content.total

			m.top.refresh = true

			m.top.content_offset = ( m.content_index + m.top.content.total - INT( m.global.epg_content_limit / 2 ) ) mod m.top.content.total

			m.loading_content = true
			m.top.update_content = true
		'}
		end if
	'}
	end if
'}
end sub

sub OnChannelOptionsStateChanged()
'{
	if m.channel_options.menu_state = 0
	'{
		m.channel_options.visible = false
		m.channel_options.SetFocus( false )

		m.top.menu_state = 1
	'}
	else if m.channel_options.menu_state = 1
	'{
		m.channel_options.visible = true
		m.channel_options.SetFocus( true )
	'}
	end if
'}
end sub

sub OnVisible()
'{
	UpdateTimeBar()
	if m.top.visible = true
	'{
		m.update_timer.control = "start"
	'}
	else
	'{
		m.update_timer.control = "top"
	'}
	end if

	if m.top.video_player <> invalid and m.top.video_player.video <> invalid
	'{
		if m.top.visible = true
		'{
			m.top.video_player.color = m.global.panel_color
			m.top.video_player.width = m.video_player_width
			m.top.video_player.height = m.global.screen_height - ( ( m.max_visible_rows + 1 ) * m.row_height )
			m.top.video_player.translation = [ m.global.overscan_offset_x + ( m.global.screen_width - m.video_player_width ), m.global.overscan_offset_y ]

			m.top.video_player.video.width = m.video_width
			m.top.video_player.video.height = m.video_height
			m.top.video_player.video.translation = [ ( m.top.video_player.width - m.top.video_player.video.width ) / 2, ( m.top.video_player.height - m.top.video_player.video.height ) / 2 ]
		'}
		else
		'{
			m.top.video_player.color = "#00000000"
			m.top.video_player.width = m.global.preferred_screen_width
			m.top.video_player.height = m.global.preferred_screen_height
			m.top.video_player.translation = [ 0, 0 ]

			if m.top.video_player.video.globalCaptionMode = "Off"
			'{
				m.top.video_player.video.width = m.global.screen_width
				m.top.video_player.video.height = m.global.screen_height
				m.top.video_player.video.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
			'}
			else
			'{
				m.top.video_player.video.width = m.global.preferred_screen_width
				m.top.video_player.video.height = m.global.preferred_screen_height
				m.top.video_player.video.translation = [ 0, 0 ]
			'}
			end if
		'}
		end if
	'}
	end if

	if m.top.visible = true and (m.top.content = invalid or m.top.content.GetChildCount() = 0)
	'{
		m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).repeatCount = -1
		if m.global.loading_epg = true
		'{
			m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Loading Guide..."
		'}
		else
		'{
			m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Guide Not Available"
		'}
		end if

		m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 1 ).text = ""
	'}
	end if
'}
end sub

' time_val is in seconds.
function FormatRuntime( time_val as integer ) as string
'{
	hours = int( time_val / 3600 )
	minutes = int( time_val / 60 ) MOD 60

	if hours > 0
	'{
		if minutes > 0
		'{
			return hours.ToStr() + "h " + minutes.ToStr() + "m"
		'}
		else
		'{
			return hours.ToStr() + "h"
		'}
		end if
	'}
	else if minutes > 0
	'{
		return minutes.ToStr() + "m"
	'}
	end if

	return ""
'}
end function

function GetOffsetTime( offset as integer )
'{
	m.date_time.Mark()
	m.date_time.ToLocalTime()
	time = m.date_time.FromSeconds( m.date_time.AsSeconds() + offset )
	time = m.date_time.AsSeconds()
	return time - ( time mod m.column_time_interval )   ' Get the current time in 30 minute intervals ( 4:00, 4:30, 5:00, etc.)
'}
end function

sub UpdateTimeBar()
'{
	m.date_time.Mark()
	m.date_time.ToLocalTime()

	current_time = m.date_time.AsSeconds()

	m.first_time_column_time = current_time - ( current_time mod m.column_time_interval )

	' The column time interval has elapsed. Adjust the time bar time offset.
	if m.first_time_column_time <> m.last_first_time_column_time
	'{
		' If we selected a program in the last time column and it's no longer being displayed, then set the selected program to the first item in the new column.
		if m.time_bar_time_offset = 0 and m.selected_program_index > 0 and m.programs.GetChild( m.selected_row_index ).GetChildCount() > 0
		'{
			m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
			m.selected_program_index = 0
			m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
		'}
		end if

		' Adjust the time bar time offset back however many columns have elapsed since we last updated.
		' m.first_time_column_time and m.last_first_time_column_time will be in intervals of m.column_time_interval
		m.time_bar_time_offset = m.time_bar_time_offset - ( m.first_time_column_time - m.last_first_time_column_time )
		if m.time_bar_time_offset < 0
		'{
			m.time_bar_time_offset = 0
		'}
		end if

		m.last_first_time_column_time = m.first_time_column_time
	'}
	end if

	time = current_time + m.time_bar_time_offset
	time = time - ( time mod m.column_time_interval )   ' Get the current time in 30 minute intervals ( 4:00, 4:30, 5:00, etc.)

	if time <> m.last_time
	'{
		m.last_time = time

		program_index_offset = -1

		for i = 0 to m.visible_rows - 1
		'{
			content_index = ( m.first_visible_content_index + i ) mod m.top.content.total
			content_index = GetContentIndex( content_index )

			program_info_state = UpdatePrograms( i, content_index )

			if i = m.selected_row_index
			'{
				UpdateProgramInfo( content_index, program_info_state.index_offset, program_info_state.start_time, program_info_state.end_time )
			'}
			end if

			' Save the highest index.
			if program_info_state.index > program_index_offset
			'{
				program_index_offset = program_info_state.index
			'}
			end if
		'}
		end for

		if program_index_offset <> -1
		'{
			m.program_index_offset = program_index_offset
		'}
		end if
	'}
	end if

	if m.time_bar_time_offset = 0
	'{
		m.time_progress_bar.width = Int( ( m.time_bar_column_width * ( current_time - time ) ) / m.column_time_interval )
		m.time_progress_bar.visible = true
	'}
	else
	'{
		m.time_progress_bar.visible = false
	'}
	end if

	m.date_time.FromSeconds( current_time + m.time_bar_time_offset )
	m.time_bar.GetChild( 0 ).GetChild( 0 ).text = m.date_time.asDateStringLoc( "EEE, MMM d" )

	for i = 1 to m.column_count
	'{
		if i > 1 or m.time_bar_time_offset > 0
		'{
			m.date_time.FromSeconds( time )
		'}
		end if

		m.time_bar.GetChild( 0 ).GetChild( i ).text = m.date_time.asTimeStringLoc( "short" )

		time = time + m.column_time_interval  ' Next half hour.
	'}
	end for
'}
end sub

function GetClosestProgramInfo( content_index as integer )
'{
	program_info_state = { "index_offset": -1, "index": -1, "start_time": -1, "end_time": -1 }

	if content_index >= 0
	'{
		program_index_offset = m.program_index_offset

		last_program_index = -1
		if m.top.content <> invalid and content_index >= 0 and content_index < m.top.content.GetChildCount()
		'{
			last_program_index = m.top.content.GetChild( content_index ).GetChildCount() - 1
		'}
		end if

		if last_program_index >= 0
		'{
			remove_num_children = 0

			for i = 0 to last_program_index
			'{
				' Remove programs that have ended.
				if m.first_time_column_time >= m.top.content.GetChild( content_index ).GetChild( i ).end_time
				'{
					remove_num_children++
				'}
				end if
			'}
			end for

			if remove_num_children > 0
			'{
				m.top.content.GetChild( content_index ).RemoveChildrenIndex( remove_num_children, 0 )

				' Adjust the last program index now that we've removed previous children.
				last_program_index = last_program_index - remove_num_children
			'}
			end if

			if last_program_index >= 0
			'{
				if program_index_offset > last_program_index
				'{
					program_index_offset = last_program_index
				'}
				end if

				column_start_time = GetOffsetTime( m.time_bar_time_offset )

				' Does the program end before the column start time?
				if m.top.content.GetChild( content_index ).GetChild( program_index_offset ).end_time <= column_start_time
				'{
					program_index_offset++

					' Iterate forward until we get to a program that falls within the column start time.
					while program_index_offset <= last_program_index
					'{
						if m.top.content.GetChild( content_index ).GetChild( program_index_offset ).end_time > column_start_time
						'{
							exit while
						'}
						end if

						program_index_offset++
					'}
					end while

					' There's no program that ends after the column start time.
					' Essentially, there's no program to display.
					if program_index_offset > last_program_index
					'{
						program_index_offset = -1
					'}
					end if
				'}
				else
				'{
					' Iterate backwards until we get to a program that falls within the column start time.
					while program_index_offset > 0
					'{
						' The (current program's start time starts) or the (previous program's end time ends) on or before the column start time.
						if m.top.content.GetChild( content_index ).GetChild( program_index_offset ).start_time <= column_start_time or m.top.content.GetChild( content_index ).GetChild( program_index_offset - 1 ).end_time <= column_start_time
						'{
							exit while
						'}
						end if

						program_index_offset--
					'}
					end while
				'}
				end if

				if program_index_offset >= 0
				'{
					end_time = m.top.content.GetChild( content_index ).GetChild( program_index_offset ).end_time
					start_time = m.top.content.GetChild( content_index ).GetChild( program_index_offset ).start_time

					' The program starts after the current time column.
					' We need to fill it in using the previous program if it exists.
					if start_time > column_start_time
					'{
						if program_index_offset > 0
						'{
							program_info_state.start_time = m.top.content.GetChild( content_index ).GetChild( program_index_offset - 1 ).end_time
						'}
						else
						'{
							program_info_state.start_time = GetOffsetTime( 0 )
						'}
						end if

						program_info_state.end_time = start_time
						program_info_state.index_offset = -1	' This program doesn't exist, but has a start and end to it.
					'}
					else
					'{
						program_info_state.start_time = start_time
						program_info_state.end_time = end_time

						program_info_state.index_offset = program_index_offset
					'}
					end if

					program_info_state.index = program_index_offset ' The actual index without any adjustments for time.
				'}
				end if
			'}
			end if
		'}
		end if
	'}
	end if

	return program_info_state
'}
end function

sub UpdateProgramValues( row_index as integer, program_index as integer, text as string, x as integer, width as integer )
'{
	if program_index < m.programs.GetChild( row_index ).GetChildCount()
	'{
		' grid_rect_background
		m.programs.GetChild( row_index ).GetChild( program_index ).width = width - 2
		m.programs.GetChild( row_index ).GetChild( program_index ).translation = [ x + 1, 1 ]
		' grid_rect
		m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).width = width - 2
		' program
		m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).GetChild( 0 ).width = width - 20
		m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).GetChild( 0 ).text = text
	'}
	else
	'{
		grid_rect_background = CreateObject( "roSGNode", "Rectangle" )
		grid_rect_background.width = width - 2
		grid_rect_background.height = m.row_height - 2
		grid_rect_background.translation = [ x + 1, 1 ]
		grid_rect_background.color = m.global.panel_color

			grid_rect = CreateObject( "roSGNode", "Rectangle" )
			grid_rect.width = width - 2
			grid_rect.height = m.row_height - 2
			grid_rect.color = m.row_color

				program = CreateObject( "roSGNode", "Label" )
				program.width = width - 20
				program.height = m.row_height
				program.vertAlign = "center"
				program.translation = [ 10, 0 ]
				program.text = text
				program.font = "font:SmallestSystemFont"

				grid_rect.AppendChild( program )

			grid_rect_background.AppendChild( grid_rect )

		m.programs.GetChild( row_index ).AppendChild( grid_rect_background )
	'}
	end if
'}
end sub

function UpdatePrograms( row_index as integer, content_index as integer )
'{
	program_info_state = GetClosestProgramInfo( content_index )

	width = 0
	last_x = 0
	time_bar_width = m.time_bar_column_width * m.column_count
	program_index = 0

	if row_index = m.selected_row_index
	'{
		m.first_column_items.Clear()
	'}
	end if

	if program_info_state.start_time <> -1 and ( m.top.content <> invalid and content_index >= 0 and content_index < m.top.content.GetChildCount() )
	'{
		column_start_time = GetOffsetTime( m.time_bar_time_offset )

		start_time = program_info_state.start_time
		end_time = program_info_state.end_time
		last_end_time = start_time

		index = program_info_state.index
		program_index_offset = program_info_state.index_offset

		text = "No information"

		last_program_index = m.top.content.GetChild( content_index ).GetChildCount() - 1

		while last_x < time_bar_width
		'{
			unadjusted_program_index = program_index_offset

			if program_index_offset = -1
			'{
				program_index_offset = index
			'}
			else if program_index_offset <= last_program_index
			'{
				text = m.top.content.GetChild( content_index ).GetChild( program_index_offset ).Title

				start_time = m.top.content.GetChild( content_index ).GetChild( program_index_offset ).start_time
				end_time = m.top.content.GetChild( content_index ).GetChild( program_index_offset ).end_time

				program_index_offset++

				' We don't want to display old programs.
				if end_time <= column_start_time
				'{
					exit while
				'}
				end if
			'}
			end if

			if start_time > last_end_time   ' Handles empty space between programs when the times don't align.
			'{
				end_time = start_time
				start_time = last_end_time

				text = "No information"

				program_index_offset--

				unadjusted_program_index = -1
			'}
			else if start_time < column_start_time   ' The program starts before the column start time and ends after it.
			'{
				start_time = column_start_time
			'}
			end if

			if ( row_index = m.selected_row_index ) and ( end_time < ( column_start_time + m.column_time_interval ) )
			'{
				' start_time is always going to equal last_end_time
				m.first_column_items.Push( { "index": unadjusted_program_index, "start_time": last_end_time, "end_time": end_time } )
			'}
			end if

			last_end_time = end_time

			width = Int( ( m.time_bar_column_width * ( end_time - start_time ) ) / m.column_time_interval )

			UpdateProgramValues( row_index, program_index, text, last_x, width )

			program_index++

			last_x = last_x + width

			if program_index_offset > last_program_index
			'{
				exit while
			'}
			end if
		'}
		end while
	'}
	end if

	' Fill in any remaining programs in the row.
	width = m.time_bar_column_width * ( m.column_count + 1 )	' Fill the screen.

	if last_x < width
	'{
		UpdateProgramValues( row_index, program_index, "No information", last_x, width )

		program_index++

		last_x = last_x + width
	'}
	end if

	program_count = m.programs.GetChild( row_index ).GetChildCount()
	while program_index < program_count
	'{
		UpdateProgramValues( row_index, program_index, "No information", last_x, width )

		program_index++

		last_x = last_x + width
	'}
	end while

	return program_info_state
'}
end function

sub UpdateProgramInfo( content_index as integer, program_index as integer, start_time as integer, end_time as integer )
'{
	if m.top.content <> invalid and content_index >= 0
	'{
		poster_url = m.top.content.GetChild( content_index ).HDPosterUrl
		if m.channel_logo.uri <> poster_url
		'{
			m.channel_logo.loadingBitmapUri = m.channel_logo.uri
			if poster_url = ""
			'{
				poster_url = "pkg:/images/no-channel.png"
			'}
			end if
			m.channel_logo.uri = poster_url
		'}
		end if
		if m.top.content.GetChild( content_index ).Favorite = true
		'{
			m.channel_number.text = "[" + m.top.content.GetChild( content_index ).Number.ToStr() + "]"
		'}
		else
		'{
			m.channel_number.text = m.top.content.GetChild( content_index ).Number.ToStr()
		'}
		end if

		if m.channel_list_selected = true
		'{
			m.program_name.text = m.top.content.GetChild( content_index ).Title
			m.channel_name.text = ""
			m.program_description.text = ""
		'}
		else
		'{
			if program_index <> -1 and content_index >= 0 and content_index < m.top.content.GetChildCount()
			'{
				start_time = m.top.content.GetChild( content_index ).GetChild( program_index ).start_time
				end_time = m.top.content.GetChild( content_index ).GetChild( program_index ).end_time

				m.program_name.text = m.top.content.GetChild( content_index ).GetChild( program_index ).Title
				m.program_description.text = m.top.content.GetChild( content_index ).GetChild( program_index ).Description
			'}
			else
			'{
				m.program_name.text = "No information"
				m.program_description.text = ""
			'}
			end if

			time_string = ""
			if start_time > 0 and end_time > start_time
			'{
				date = CreateObject( "roDateTime" )
				date.FromSeconds( start_time )
				time_string = date.asTimeStringLoc( "hh:mm a" ) + " - "
				date.FromSeconds( end_time )
				time_string = time_string + date.asTimeStringLoc( "hh:mm a" ) + " • " + FormatRuntime( end_time - start_time ) + " • "
			'}
			end if
			m.channel_name.text = time_string + m.top.content.GetChild( content_index ).Title
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
			content_index = m.global.epg_content_limit - ( m.top.content.total - index )
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
		if offset >= 0 and offset < m.global.epg_content_limit
		'{
			content_index = offset
		'}
		end if
	'}
	end if

	return content_index
'}
end function

sub OnContentChange()
'{
	' We've loaded a group, but don't know it's length yet. Reset the values below.
	if m.global.epg_content_offset < 0 or m.top.content = invalid or ( m.top.content <> invalid and m.top.content.total <= 0 )
	'{
		if m.reloading_content = false
		'{
			m.content_index = 0

			m.selected_row_index = 0
			m.channel_list_selected = true
			m.program_index_offset = 0
			m.selected_program_index = 0
			m.time_bar_time_offset = 0
		'}
		end if

		m.channel_logo.uri = ""
		m.channel_number.text = ""
		m.program_name.text = ""
		m.channel_name.text = ""
		m.program_description.text = ""
	'}
	end if

	if m.top.content <> invalid
	'{
		if m.top.content.total < m.last_content_total
		'{
			if m.content_index > 0
			'{
				m.content_index--
			'}
			end if

			if m.channel_list_selected = false
			'{
				m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
			'}
			end if

			if m.selected_row_index > 0
			'{
				m.selected_row_index--
			'}
			end if

			if m.channel_list_selected = false
			'{
				m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
			'}
			end if
		'}
		end if

		m.visible_rows = m.top.content.GetChildCount()

		if ( m.visible_rows > 0 )
		'{
			if m.top.content.total > m.global.epg_content_limit
			'{
				if m.global.epg_content_offset < 0
				'{
					m.content_index_start = ( m.top.content.total + m.global.epg_content_offset ) mod m.top.content.total
				'}
				else
				'{
					m.content_index_start = m.global.epg_content_offset
				'}
				end if
				m.content_index_end = ( m.content_index_start + ( m.global.epg_content_limit - 1 ) ) mod m.top.content.total
			'}
			else
			'{
				m.content_index_start = 0
				m.content_index_end = m.top.content.total - 1
			'}
			end if

			m.first_visible_content_index = 0

			if m.visible_rows > m.max_visible_rows
			'{
				m.visible_rows = m.max_visible_rows

				m.selected_row_index = INT( m.visible_rows / 2 )

				m.first_visible_content_index = ( m.content_index + m.top.content.total - m.selected_row_index ) mod m.top.content.total
			'}
			end if

			program_index_offset = -1

			for i = 0 to m.visible_rows - 1
			'{
				content_index = ( m.first_visible_content_index + i ) mod m.top.content.total
				content_index = GetContentIndex( content_index )
				if content_index <> -1
				'{
					m.channels.GetChild( i ).GetChild( 0 ).text = m.top.content.GetChild( content_index ).Title
					if m.top.content.GetChild( content_index ).Favorite = true
					'{
						m.channels.GetChild( i ).GetChild( 1 ).text = "[" + m.top.content.GetChild( content_index ).Number.ToStr() + "]"
					'}
					else
					'{
						m.channels.GetChild( i ).GetChild( 1 ).text = m.top.content.GetChild( content_index ).Number.ToStr()
					'}
					end if
				'}
				else
				'{
					m.channels.GetChild( i ).GetChild( 0 ).text = ""
					m.channels.GetChild( i ).GetChild( 1 ).text = ""
				'}
				end if

				program_info_state = UpdatePrograms( i, content_index )

				if i = m.selected_row_index
				'{
					m.channels.GetChild( i ).GetChild( 0 ).repeatCount = -1

					if m.channel_list_selected = true
					'{
						m.channels.GetChild( i ).color = m.row_selected_color
					'}
					end if

					UpdateProgramInfo( content_index, program_info_state.index_offset, program_info_state.start_time, program_info_state.end_time )
				'}
				else
				'{
					m.channels.GetChild( i ).GetChild( 0 ).repeatCount = 0
					m.channels.GetChild( i ).color = m.row_color
				'}
				end if

				' Save the highest index.
				if program_info_state.index > program_index_offset
				'{
					program_index_offset = program_info_state.index
				'}
				end if
			'}
			end for

			if program_index_offset <> -1
			'{
				m.program_index_offset = program_index_offset
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

	' Reset any rows that aren't being used.
	width = m.time_bar_column_width * ( m.column_count + 1 )	' Fill the screen.

	for row_index = m.visible_rows to m.max_visible_rows - 1
	'{
		m.channels.GetChild( row_index ).GetChild( 0 ).text = ""
		m.channels.GetChild( row_index ).GetChild( 1 ).text = ""
		m.channels.GetChild( row_index ).color = m.row_color

		last_x = 0
		program_count = m.programs.GetChild( row_index ).GetChildCount() - 1
		for program_index = 0 to program_count
		'{
			' grid_rect_background
			m.programs.GetChild( row_index ).GetChild( program_index ).width = width - 2
			m.programs.GetChild( row_index ).GetChild( program_index ).translation = [ last_x + 1, 1 ]
			' grid_rect
			m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).width = width - 2
			m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).color = m.row_color
			' program
			m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).GetChild( 0 ).width = width - 20
			m.programs.GetChild( row_index ).GetChild( program_index ).GetChild( 0 ).GetChild( 0 ).text = ""

			last_x = last_x + width
		'}
		end for
	'}
	end for

	if m.visible_rows = 0
	'{
		m.content_index = 0

		m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).repeatCount = -1
		if m.global.loading_epg = true
		'{
			m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Loading Guide..."
		'}
		else
		'{
			m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 0 ).text = "Guide Not Available"
		'}
		end if

		m.channels.GetChild( INT( m.max_visible_rows / 2 ) ).GetChild( 1 ).text = ""
	'}
	end if

	UpdateTimeBar()

	m.last_content_total = 0

	m.reloading_content = false

	m.loading_content = false
'}
end sub

sub ScrollX( scroll_type as integer )
'{
	' Prevents us from scrolling if there's a slow network connection while we're navigating the menu items.
	if m.global.loading_epg = true
	'{
		return
	'}
	end if

	time_bar_time_offset = m.time_bar_time_offset

	skip_time_bar_update = false

	if scroll_type = 101 or scroll_type = 110  ' Move Left
	'{
		if m.time_bar_time_offset = 0
		'{
			if scroll_type = 101 and m.selected_program_index > 0
			'{
				skip_time_bar_update = true

				m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
				m.selected_program_index--
				m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color

				content_index = GetContentIndex( m.content_index )

				UpdateProgramInfo( content_index, m.first_column_items[ m.selected_program_index ].index, m.first_column_items[ m.selected_program_index ].start_time, m.first_column_items[ m.selected_program_index ].end_time )
			'}
			else
			'{
				m.channels.GetChild( m.selected_row_index ).color = m.row_selected_color
				m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color

				m.selected_program_index = 0

				m.channel_list_selected = true
			'}
			end if
		'}
		else
		'{
			if scroll_type = 101
			'{
				if m.selected_program_index > 0
				'{
					skip_time_bar_update = true

					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
					m.selected_program_index--
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color

					content_index = GetContentIndex( m.content_index )

					UpdateProgramInfo( content_index, m.first_column_items[ m.selected_program_index ].index, m.first_column_items[ m.selected_program_index ].start_time, m.first_column_items[ m.selected_program_index ].end_time )
				'}
				end if
			'}
			end if

			if skip_time_bar_update = false
			'{
				if m.selected_program_index > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
					m.selected_program_index = 0
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
				'}
				end if

				if scroll_type = 110
				'{
					m.time_bar_time_offset = m.time_bar_time_offset - ( m.column_time_interval * m.column_count )
					if m.time_bar_time_offset < 0
					'{
						m.time_bar_time_offset = 0
					'}
					end if
				'}
				else
				'{
					m.time_bar_time_offset = m.time_bar_time_offset - m.column_time_interval
				'}
				end if
			'}
			end if
		'}
		end if
	'}
	else' if scroll_type = 102 or scroll_type = 120	' Move Right
	'{
		if m.channel_list_selected = true
		'{
			m.channels.GetChild( m.selected_row_index ).color = m.row_color
			m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color

			m.selected_program_index = 0

			m.channel_list_selected = false
		'}
		else
		'{
			if scroll_type = 102
			'{
				if m.selected_program_index < m.first_column_items.Count() - 1
				'{
					skip_time_bar_update = true

					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
					m.selected_program_index++
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color

					content_index = GetContentIndex( m.content_index )

					UpdateProgramInfo( content_index, m.first_column_items[ m.selected_program_index ].index, m.first_column_items[ m.selected_program_index ].start_time, m.first_column_items[ m.selected_program_index ].end_time )
				'}
				end if
			'}
			end if

			if skip_time_bar_update = false
			'{
				if m.selected_program_index > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
					m.selected_program_index = 0
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
				'}
				end if

				if scroll_type = 120
				'{
					m.time_bar_time_offset = m.time_bar_time_offset + ( m.column_time_interval * m.column_count )
				'}
				else
				'{
					m.time_bar_time_offset = m.time_bar_time_offset + m.column_time_interval
				'}
				end if
			'}
			end if
		'}
		end if
	'}
	end if

	if m.channel_list_selected = true
	'{
		content_index = ( m.first_visible_content_index + m.selected_row_index ) mod m.top.content.total
		content_index = GetContentIndex( content_index )
		if content_index <> -1
		'{
			poster_url = m.top.content.GetChild( content_index ).HDPosterUrl
			if m.channel_logo.uri <> poster_url
			'{
				m.channel_logo.loadingBitmapUri = m.channel_logo.uri
				if poster_url = ""
				'{
					poster_url = "pkg:/images/no-channel.png"
				'}
				end if
				m.channel_logo.uri = poster_url
			'}
			end if
			if m.top.content.GetChild( content_index ).Favorite = true
			'{
				m.channel_number.text = "[" + m.top.content.GetChild( content_index ).Number.ToStr() + "]"
			'}
			else
			'{
				m.channel_number.text = m.top.content.GetChild( content_index ).Number.ToStr()
			'}
			end if
			m.program_name.text = m.top.content.GetChild( content_index ).Title
		'}
		else
		'{
			m.channel_logo.uri = ""
			m.channel_number.text = ""
			m.program_name.text = ""
		'}
		end if
		m.channel_name.text = ""
		m.program_description.text = ""
	'}
	else if m.time_bar_time_offset <> time_bar_time_offset
	'{
		UpdateTimeBar()

		program_index_offset = -1

		for i = 0 to m.visible_rows - 1
		'{
			content_index = ( m.first_visible_content_index + i ) mod m.top.content.total
			content_index = GetContentIndex( content_index )

			program_info_state = UpdatePrograms( i, content_index )

			if i = m.selected_row_index
			'{
				program_index = program_info_state.index_offset
				start_time = program_info_state.start_time
				end_time = program_info_state.end_time

				if scroll_type = 101	' Move Left
				'{
					if m.first_column_items.Count() > 1
					'{
						m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
						m.selected_program_index = m.first_column_items.Count() - 1
						m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
					
						program_index = m.first_column_items[ m.selected_program_index ].index
						start_time = m.first_column_items[ m.selected_program_index ].start_time
						end_time = m.first_column_items[ m.selected_program_index ].end_time
					'}
					end if
				'}
				end if

				UpdateProgramInfo( content_index, program_index, start_time, end_time )
			'}
			end if

			' Save the highest index.
			if program_info_state.index > program_index_offset
			'{
				program_index_offset = program_info_state.index
			'}
			end if
		'}
		end for

		if program_index_offset <> -1
		'{
			m.program_index_offset = program_index_offset
		'}
		end if
	'}
	else
	'{
		if skip_time_bar_update = false
		'{
			content_index = GetContentIndex( m.content_index )

			program_info_state = GetClosestProgramInfo( content_index )

			UpdateProgramInfo( content_index, program_info_state.index_offset, program_info_state.start_time, program_info_state.end_time )
		'}
		end if
	'}
	end if
'}
end sub

sub ScrollY( scroll_type as integer )
'{
	' Prevents us from scrolling if there's a slow network connection while we're navigating the menu items.
	if m.global.loading_epg = true
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

	if m.selected_program_index > 0
	'{
		m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
		m.selected_program_index = 0
		m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
	'}
	end if

	selected_row_index = m.selected_row_index

	m.first_visible_content_index = 0

	if scroll_type = 1 or scroll_type = 10	' Move Up
	'{
		if m.visible_rows = m.top.content.GetChildCount()
		'{
			if m.selected_row_index > 0
			'{
				if m.channel_list_selected = true
				'{
					m.channels.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = 0
					m.channels.GetChild( m.selected_row_index ).color = m.row_color
				'}
				else if m.programs.GetChild( m.selected_row_index ).GetChildCount() > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
				'}
				end if

				if scroll_type = 1
				'{
					m.selected_row_index--
				'}
				else' if scroll_type = 10
				'{
					m.selected_row_index = 0
				'}
				end if

				if m.channel_list_selected = true
				'{
					m.channels.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = -1
					m.channels.GetChild( m.selected_row_index ).color = m.row_selected_color
				'}
				else if m.programs.GetChild( m.selected_row_index ).GetChildCount() > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
				'}
				end if
			'}
			end if

			m.content_index = m.selected_row_index
		'}
		else
		'{
			m.content_index = ( m.content_index + m.top.content.total - scroll_offset ) mod m.top.content.total

			m.first_visible_content_index = ( m.content_index + m.top.content.total - m.selected_row_index ) mod m.top.content.total

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
				if m.channel_list_selected = true
				'{
					m.channels.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = 0
					m.channels.GetChild( m.selected_row_index ).color = m.row_color
				'}
				else if m.programs.GetChild( m.selected_row_index ).GetChildCount() > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_color
				'}
				end if

				if scroll_type = 2
				'{
					m.selected_row_index++
				'}
				else' if scroll_type = 20
				'{
					m.selected_row_index = m.visible_rows - 1
				'}
				end if

				if m.channel_list_selected = true
				'{
					m.channels.GetChild( m.selected_row_index ).GetChild( 0 ).repeatCount = -1
					m.channels.GetChild( m.selected_row_index ).color = m.row_selected_color
				'}
				else if m.programs.GetChild( m.selected_row_index ).GetChildCount() > 0
				'{
					m.programs.GetChild( m.selected_row_index ).GetChild( m.selected_program_index ).GetChild( 0 ).color = m.row_selected_color
				'}
				end if
			'}
			end if

			m.content_index = m.selected_row_index
		'}
		else
		'{
			m.content_index = ( m.content_index + scroll_offset ) mod m.top.content.total

			m.first_visible_content_index = ( m.content_index + m.top.content.total - m.selected_row_index ) mod m.top.content.total

			m.scroll_delta = m.scroll_delta + scroll_offset
		'}
		end if
	'}
	end if

	' Update the program rows if we need to scroll.
	if m.visible_rows <> m.top.content.GetChildCount()
	'{
		program_index_offset = -1

		for i = 0 to m.visible_rows - 1
		'{
			content_index = ( m.first_visible_content_index + i ) mod m.top.content.total
			content_index = GetContentIndex( content_index )
			if content_index <> -1
			'{
				m.channels.GetChild( i ).GetChild( 0 ).text = m.top.content.GetChild( content_index ).Title
				if m.top.content.GetChild( content_index ).Favorite = true
				'{
					m.channels.GetChild( i ).GetChild( 1 ).text = "[" + m.top.content.GetChild( content_index ).Number.ToStr() + "]"
				'}
				else
				'{
					m.channels.GetChild( i ).GetChild( 1 ).text = m.top.content.GetChild( content_index ).Number.ToStr()
				'}
				end if
			'}
			else
			'{
				m.channels.GetChild( i ).GetChild( 0 ).text = "Loading Channel..."
				m.channels.GetChild( i ).GetChild( 1 ).text = ""
			'}
			end if

			program_info_state = UpdatePrograms( i, content_index )

			if i = m.selected_row_index
			'{
				UpdateProgramInfo( content_index, program_info_state.index_offset, program_info_state.start_time, program_info_state.end_time )
			'}
			end if

			' Save the highest index.
			if program_info_state.index > program_index_offset
			'{
				program_index_offset = program_info_state.index
			'}
			end if
		'}
		end for

		if program_index_offset <> -1
		'{
			m.program_index_offset = program_index_offset
		'}
		end if
	'}
	else if m.selected_row_index <> selected_row_index
	'{
		content_index = GetContentIndex( m.content_index )

		program_info_state = GetClosestProgramInfo( content_index )

		UpdateProgramInfo( content_index, program_info_state.index_offset, program_info_state.start_time, program_info_state.end_time )
	'}
	end if
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

		if m.scroll_type > 100
		'{
			ScrollX( m.scroll_type )
		'}
		else
		'{
			ScrollY( m.scroll_type )
		'}
		end if
	'}
	end if
'}
end sub

sub LoadContentChunk()
'{
	if m.top.content <> invalid and m.global.epg_content_limit <= m.top.content.GetChildCount() and m.loading_content = false
	'{
		content_index = GetContentIndex( m.content_index )

		offset = INT( m.global.epg_content_limit / 2 ) - m.visible_rows

		if content_index = -1 or m.scroll_delta <= -( offset ) or m.scroll_delta >= offset
		'{
			m.scroll_delta = 0

			m.top.content_offset = ( m.content_index + m.top.content.total - INT( m.global.epg_content_limit / 2 ) ) mod m.top.content.total

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
	handled = false

	if press
	'{
		if key = "back"
		'{
			if m.top.menu_state = 1
			'{
				m.top.menu_state = 0	' Hide

				handled = true
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
					'}
					end if
				'}
				end if

				handled = true
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
					if m.channel_list_selected = false
					'{
						m.scroll_type = 110
					'}
					else
					'{
						m.scroll_type = 10
					'}
					end if
				'}
				else' if key = "fastforward"
				'{
					if m.channel_list_selected = false
					'{
						m.scroll_type = 120
					'}
					else
					'{
						m.scroll_type = 20
					'}
					end if
				'}
				end if

				HandleScroll()

				m.scroll_timer.control = "start"

				handled = true
			'}
			end if
		'}
		else if key = "left" or key = "right"
		'{
			if key = "left"
			'{
				m.scroll_type = 101
			'}
			else' if key = "right"
			'{
				m.scroll_type = 102
			'}
			end if

			HandleScroll()

			m.scroll_timer.control = "start"

			handled = true
		'}
		else if key = "options"
		'{
			if m.top.menu_state = 1
			'{
				if m.top.content <> invalid and m.top.content.GetChildCount() > 0
				'{
					content_index = GetContentIndex( m.content_index )
					if content_index <> -1
					'{
						m.channel_options.content = m.top.content.GetChild( content_index )

						m.channel_options.menu_state = 1	' Show
					'}
					end if
				'}
				end if
			'}
			end if

			handled = true
		'}
		end if
	'}
	else if not press
	'{
		if key = "up" or key = "down" or key = "rewind" or key = "fastforward" or key = "left" or key = "right"
		'{
			if key <> "left" and key <> "right"
			'{
				if m.scroll_type <= 100
				'{
					LoadContentChunk()
				'}
				end if
			'}
			end if

			m.scroll_type = 0

			m.long_scroll = 0
			m.scroll_timer.duration = m.scroll_speed

			m.scroll_timer.control = "stop"

			handled = true
		'}
		end if
	'}
	end if

	return handled
'}
end function
