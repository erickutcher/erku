'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.current_main_menu_content_index = -1	' Used to determine whether we need to load the Live TV, Movies, or TV Shows groups.
	m.current_search_content_type = -1		' The content type of the last search that was performed.

	m.main_menu = m.top.FindNode( "MainMenu" )
	m.search = m.top.FindNode( "Search" )
	m.group_menu = m.top.FindNode( "GroupMenu" )
	m.channel_menu = m.top.FindNode( "ChannelMenu" )
	m.channel_guide = m.top.FindNode( "ChannelGuide" )
	m.vod_menu = m.top.FindNode( "VODMenu" )
	m.options = m.top.FindNode( "Options" )

	m.video_player = m.top.FindNode( "VideoPlayer" )
	m.video_player.width = m.global.preferred_screen_width
	m.video_player.height = m.global.preferred_screen_height

	m.channel_guide.video_player = m.video_player	' We'll adjust the video player's background position in the channel guide.

	m.main_menu.SetFocus( true )

	m.current_menu = m.main_menu

	m.main_menu.ObserveField( "menu_state", "OnMainMenuStateChanged" )
	m.search.ObserveField( "menu_state", "OnSearchStateChanged" )
	m.group_menu.ObserveField( "menu_state", "OnGroupMenuStateChanged" )
	m.channel_menu.ObserveField( "menu_state", "OnChannelMenuStateChanged" )
	m.channel_guide.ObserveField( "menu_state", "OnChannelGuideStateChanged" )
	m.vod_menu.ObserveField( "menu_state", "OnVODMenuStateChanged" )
	m.options.ObserveField( "menu_state", "OnOptionsStateChanged" )

	m.main_menu.ObserveField( "content_index", "OnMainMenuItemSelected" )
	m.group_menu.ObserveField( "content_index", "OnGroupContentChange" )
	m.channel_menu.ObserveField( "content_index", "OnChannelSelected" )
	m.channel_guide.ObserveField( "content_index", "OnGuideChannelSelected" )
	m.vod_menu.ObserveField( "content_index", "OnVODSelected" )

	m.group_menu.ObserveField( "update_content", "OnUpdateGroupContent" )
	m.channel_menu.ObserveField( "update_content", "OnUpdateChannelContent" )
	m.vod_menu.ObserveField( "update_content", "OnUpdateVODContent" )
	m.channel_guide.ObserveField( "update_content", "OnUpdateEPGContent" )

	m.video_player.video.ObserveField( "state", "OnVideoStateChange" )
	m.video_player.video.ObserveField( "globalCaptionMode", "OnGlobalCaptionModeChange" )


	''''''''''''''''''''''''

	m.channel_number_timer = CreateObject( "roSGNode", "Timer" )
	m.channel_number_timer.repeat = false
	m.channel_number_timer.duration = 3
	m.channel_number_timer.ObserveField( "fire", "HandleChannelNumberInput" )

	m.channel_number_background = CreateObject( "roSGNode", "Rectangle" )
	m.channel_number_background.translation = [ m.global.overscan_offset_x + m.global.screen_width - 20, m.global.overscan_offset_y + 20 ]
	m.channel_number_background.color = m.global.panel_color

		m.channel_number = CreateObject( "roSGNode", "Label" )
		m.channel_number.numLines = 1
		m.channel_number.translation = [ 10, 10 ]
		m.channel_number.vertAlign = "center"
		m.channel_number.horizAlign = "right"
		m.channel_number.font = "font:LargeBoldSystemFont"
		m.channel_number.text = ""
		m.channel_number_background.AppendChild( m.channel_number )

	m.top.AppendChild( m.channel_number_background )

	m.channel_number_background.visible = false

	''''''''''''''''''''''''

	m.video_content_type = -1

	''''''''''''''''''''''''

	m.loading_search_content = false

	m.show_channel_menu = true	' We can turn it off when loading an inputted/resuming channel number.

	m.load_channel_type = 0	' 0 = Resuming Channel, 1 = Input Channel
	m.loading_channel = false

	if m.global.resume_channel = true
	'{
		m.load_channel_type = 0	' Resuming Channel
		m.loading_channel = true

		' m.global.channel_group_id and m.global.channel_number will have been set in main.
		m.global.load_channel = true
	'}
	else
	'{
		m.main_menu.menu_state = 1	' Start by opening the main menu.
	'}
	end if
'}
end sub

' ---------------------------------------- '
' Handle the opening/closing of menu items '
' ---------------------------------------- '
sub OnMainMenuStateChanged()
'{
	m.current_menu = m.main_menu

	if m.main_menu.menu_state = 0
	'{
		m.main_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.main_menu.menu_state = 1
	'{
		m.main_menu.visible = true
		m.main_menu.SetFocus( true )
	'}
	end if
'}
end sub

sub OnSearchStateChanged()
'{
	if m.search.menu_state = 0
	'{
		' The Search menu could have been opened from within the Group menu and m.current_main_menu_content_index will have been set to 0.
		' If we close the Search menu without performing a search, then reset m.current_main_menu_content_index.
		if m.global.current_content_type <> -1
		'{
			m.current_main_menu_content_index = m.global.current_content_type + 1
		'}
		else	' No content has been loaded yet.
		'{
			m.current_main_menu_content_index = -1
		'}
		end if

		m.search.visible = false

		' This will either be the Main menu, or the Group menu.
		m.current_menu.menu_state = 1
	'}
	else if m.search.menu_state = 1
	'{
		m.search.visible = true
		m.search.SetFocus( true )
	'}
	end if
'}
end sub

sub OnGroupMenuStateChanged()
'{
	m.current_menu = m.group_menu

	if m.group_menu.menu_state = 0
	'{
		m.group_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.group_menu.menu_state = 1
	'{
		m.group_menu.visible = true
		m.group_menu.SetFocus( true )
	'}
	else if m.group_menu.menu_state = -1
	'{
		m.group_menu.visible = false

		m.main_menu.menu_state = 1
	'}
	end if
'}
end sub

sub OnChannelMenuStateChanged()
'{
	m.current_menu = m.channel_menu

	if m.channel_menu.menu_state = 0
	'{
		m.channel_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.channel_menu.menu_state = 1
	'{
		m.channel_menu.visible = true
		m.channel_menu.SetFocus( true )
	'}
	else if m.channel_menu.menu_state = -1
	'{
		m.channel_menu.visible = false

		m.group_menu.menu_state = 1
	'}
	end if
'}
end sub

sub OnChannelGuideStateChanged()
'{
	if m.channel_guide.menu_state = 0
	'{
		m.channel_guide.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.channel_guide.menu_state = 1
	'{
		m.channel_guide.visible = true
		m.channel_guide.SetFocus( true )
	'}
	end if
'}
end sub

sub OnVODMenuStateChanged()
'{
	m.current_menu = m.vod_menu

	if m.vod_menu.menu_state = 0
	'{
		m.vod_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.vod_menu.menu_state = 1
	'{
		m.vod_menu.visible = true
		m.vod_menu.SetFocus( true )
	'}
	else if m.vod_menu.menu_state = -1
	'{
		m.vod_menu.visible = false

		m.group_menu.menu_state = 1
	'}
	end if
'}
end sub

sub OnOptionsStateChanged()
'{
	if m.options.menu_state = 0
	'{
		m.options.visible = false

		m.main_menu.menu_state = 1
	'}
	else if m.options.menu_state = 1
	'{
		m.options.visible = true
		m.options.SetFocus( true )
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Initiate loading of groups/content.      '
' ---------------------------------------- '
sub OnMainMenuItemSelected()
'{
	m.current_menu = m.main_menu
	m.main_menu.visible = false

	' 1 = Live TV, 2 = Movies, 3 = TV Shows
	if m.main_menu.content_index = 1 or m.main_menu.content_index = 2 or m.main_menu.content_index = 3
	'{
		' If the current menu is different from the last one that we were in, then we need to request the new menu's group content.
		if m.current_main_menu_content_index <> m.main_menu.content_index
		'{
			if ( m.main_menu.content_index = 2 or m.main_menu.content_index = 3 ) and m.vod_menu.content <> invalid
			'{
				' Reset so the content isn't cached.
				m.vod_menu.content = invalid
			'}
			end if

			m.global.current_content_type = m.main_menu.content_index - 1

			m.top.content = invalid
			m.top.group_content = invalid

			m.global.loading_content = true
			m.global.group_id = 0
			m.global.group_content_offset = 0
			m.global.load_group_chunk = true
		'}
		end if

		m.current_main_menu_content_index = m.main_menu.content_index

		m.group_menu.menu_state = 1	' Show
	'}
	else if m.main_menu.content_index = 0	' Search
	'{
		m.current_main_menu_content_index = m.main_menu.content_index

		m.search.menu_state = 1	' Show
	'}
	else if m.main_menu.content_index = 4	' Options
	'{
		m.options.menu_state = 1	' Show
	'}
	end if
'}
end sub

sub OnGroupContentChange()
'{
	if m.group_menu.content_index >= 0
	'{
		' We don't know if this ID is for group or channel/VOD content, but it'll be determined when the request is fulfilled.
		m.global.request_id = m.group_menu.content.GetChild( m.group_menu.content_index ).group_id

		' If the Search group was selected and a search hadn't been performed for the current content type (Live TV, Movies, TV Shows), then open the Search menu.
		if m.global.request_id = 5 and m.current_search_content_type <> m.global.current_content_type
		'{
			m.group_menu.menu_state = 0	' Hide

			m.current_main_menu_content_index = 0

			m.search.search_type = m.global.current_content_type
			m.search.menu_state = 1	' Show
		'}
		else if m.current_main_menu_content_index = 1 and ( m.channel_menu.content = invalid or m.channel_menu.content <> invalid and m.channel_menu.content.group_id <> m.global.request_id )
		'{
			m.global.loading_content = true
			m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
			m.global.load_request = true
		'}
		else if ( m.current_main_menu_content_index = 2 or m.current_main_menu_content_index = 3 ) and ( m.vod_menu.content = invalid or m.vod_menu.content <> invalid and m.vod_menu.content.group_id <> m.global.request_id )
		'{
			m.global.loading_content = true
			m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
			m.global.load_request = true
		'}
		else
		'{
			m.current_menu = m.group_menu
			m.group_menu.visible = false

			if m.current_main_menu_content_index = 1
			'{
				m.channel_menu.menu_state = 1	' Show
			'}
			else if m.current_main_menu_content_index = 2 or m.current_main_menu_content_index = 3
			'{
				m.vod_menu.menu_state = 1		' Show
			'}
			end if
		'}
		end if
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Request the next group/content/epg chunk '
' ---------------------------------------- '
sub OnUpdateGroupContent()
'{
	if m.group_menu.update_content = true
	'{
		m.group_menu.update_content = false

		m.global.loading_content = true
		m.global.group_content_offset = m.group_menu.content_offset
		m.global.load_group_chunk = true
	'}
	end if
'}
end sub

sub OnUpdateChannelContent()
'{
	if m.channel_menu.update_content = true
	'{
		m.channel_menu.update_content = false

		m.global.loading_content = true
		m.global.content_offset = m.channel_menu.content_offset
		m.global.load_content_chunk = true
	'}
	end if
'}
end sub

sub OnUpdateVODContent()
'{
	if m.vod_menu.update_content = true
	'{
		m.vod_menu.update_content = false

		m.global.loading_content = true
		m.global.content_offset = m.vod_menu.content_offset
		m.global.load_content_chunk = true
	'}
	end if
'}
end sub

sub OnUpdateEPGContent()
'{
	if m.channel_guide.update_content = true
	'{
		m.channel_guide.update_content = false

		m.global.loading_epg = true
		m.global.epg_content_offset = m.channel_guide.content_offset
		m.global.load_epg_chunk = true
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Set the menu/guide's loaded content      '
' ---------------------------------------- '
sub OnLoadGroupContent()
'{
	m.global.loading_content = false

	if m.loading_channel = true
	'{
		m.loading_channel = false

		m.group_menu.content = m.top.group_content

		m.show_channel_menu = false

		' Load the TV Channel list.
		m.global.request_id = m.global.channel_group_id
		m.global.loading_content = true
		m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
		m.global.load_request = true
	'}
	else if m.loading_search_content = true	' Group content has been returned from a search request.
	'{
		m.loading_search_content = false

		m.group_menu.content = m.top.group_content

		m.current_main_menu_content_index = m.global.current_content_type + 1

		m.search.visible = false

		m.group_menu.menu_state = 1		' Show
	'}
	else if m.current_main_menu_content_index = 0	' We're starting a search and need the parent group (Live TV, Movies, or TV Shows) first.
	'{
		' Allows us to open the Search menu if we've navigated to a Search group, but haven't initiated a search yet.
		m.current_search_content_type = m.global.current_content_type

		m.loading_search_content = true

		m.group_menu.content = m.top.group_content

		' Now that we have the parent group set, perform the search request.
		m.global.request_id = 5	' The Search group.
		m.global.loading_content = true
		m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
		m.global.load_request = true
	'}
	else	' For every other request, set the group menu's group content.
	'{
		m.group_menu.content = m.top.group_content
	'}
	end if
'}
end sub

sub OnLoadContent()
'{
	m.global.loading_content = false

	m.loading_channel = false
	m.loading_search_content = false

	if m.top.content <> invalid
	'{
		if m.show_channel_menu = true
		'{
			m.current_menu = m.group_menu
			m.group_menu.visible = false
		'}
		end if

		if m.current_main_menu_content_index = 1
		'{
			m.channel_menu.content = m.top.content
			m.channel_guide.content = invalid

			if m.show_channel_menu = true
			'{
				m.channel_menu.menu_state = 1	' Show
			'}
			else
			'{
				if m.load_channel_type = 0	' Resuming Channel
				'{
					m.current_menu = m.channel_menu
					m.video_player.SetFocus( true )
				'}
				end if
			'}
			end if
		'}
		else if m.current_main_menu_content_index = 2 or m.current_main_menu_content_index = 3
		'{
			m.vod_menu.content = m.top.content

			m.vod_menu.menu_state = 1	' Show
		'}
		else if m.current_main_menu_content_index = 0	' Search results.
		'{
			' The menu associated with the search type.
			' Don't set m.main_menu.content_index as that will load the group menu and we may not want that openend.
			m.current_main_menu_content_index = m.global.current_content_type + 1

			m.search.visible = false

			if m.global.current_content_type = 0		' Live TV
			'{
				m.channel_menu.content = m.top.content
				m.channel_guide.content = invalid

				m.channel_menu.menu_state = 1	' Show
			'}
			else if m.global.current_content_type = 1 or m.global.current_content_type = 2	' Movies/TV Shows
			'{
				m.vod_menu.content = m.top.content

				m.vod_menu.menu_state = 1		' Show
			'}
			end if
		'}
		end if
	'}
	end if

	m.show_channel_menu = true	' Default to true
'}
end sub

sub OnLoadEPGContent()
'{
	m.global.loading_epg = false

	m.channel_guide.content = m.top.epg_content
'}
end sub

sub OnLoadDetailsContent()
'{
	loading_details = m.global.loading_details

	m.global.loading_details = 0

	if loading_details = 1			' Loading details for VOD menu.
	'{
		m.vod_menu.details_content = m.top.details_content
	'}
	else if loading_details = 2		' Loading details for video player info.
	'{
		m.video_player.details_content = m.top.details_content
	'}
	else if loading_details = 3		' Loading details for Group menu.
	'{
		m.group_menu.details_content = m.top.details_content
	'}
	end if
'}
end sub

sub OnLoadChannelContent()
'{
	channel_content = m.top.channel_content

	if channel_content <> invalid and channel_content.GetChildCount() = 2
	'{
		m.global.current_content_type = 0	' Live TV

		m.current_main_menu_content_index = 1	' Live TV

		''''''''''''''''''''''''

		' Play the TV channel that was last played.
		content = channel_content.GetChild( 0 )

		m.video_player.content = content

		m.video_player.video.content.Title = content.Title
		m.video_player.video.content.Url = content.Url
		m.video_player.video.content.StreamFormat = content.StreamFormat
		m.video_player.video.content.HttpHeaders = content.HttpHeaders

		if m.video_content_type = 0	' Live TV
		'{
			m.video_player.video.content.SubtitleConfig = { TrackName: "eia608/1" }	' Closed captioning.
		'}
		else
		'{
			m.video_player.video.content.SubtitleConfig = content.SubtitleConfig
		'}
		end if

		m.video_player.video.control = "play"

		''''''''''''''''''''''''

		' The group tree that would need to be entered in order to reach the channel.
		group_content = channel_content.GetChild( 1 )
		if group_content.GetChildCount() > 0
		'{
			' The group that the TV Channel is in.
			if m.global.channel_group_id <> m.global.request_id	' Load new group.
			'{
				' Recreates the Group Menu's group tree so we can navigate back.
				m.group_menu.enter_group_content = channel_content.GetChild( 1 )
			'}
			else	' Group already loaded.
			'{
				if m.channel_menu.content = invalid or m.channel_menu.content <> invalid and m.channel_menu.content.group_id <> m.global.request_id	' Load channel list.
				'{
					m.show_channel_menu = false

					' Load the TV Channel list.
					m.global.loading_content = true
					m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
					m.global.load_request = true
				'}
				else	' Channel list already loaded.
				'{
					m.loading_channel = false
				'}
				end if
			'}
			end if
		'}
		else	' This shouldn't happen.
		'{
			m.loading_channel = false

			if m.load_channel_type = 0	' Resuming Channel
			'{
				m.main_menu.menu_state = 1	' Start by opening the main menu.
			'}
			end if
		'}
		end if
	'}
	else	' Failed to retreive the channel content.
	'{
		m.loading_channel = false

		if m.load_channel_type = 0	' Resuming Channel
		'{
			m.main_menu.menu_state = 1	' Start by opening the main menu.
		'}
		end if
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

sub OnVideoStateChange()
'{
	if m.video_player.video.state = "stopped" or m.video_player.video.state = "finished" or m.video_player.video.state = "error"
	'{
		' If the channel guide is opened and we play a video that stops/fails, then we want to keep the guide open and not display the previously opened menu.
		if m.channel_guide.menu_state <> 1
		'{
			m.current_menu.menu_state = 1	' Show
		'}
		else
		'{
			' The video player will hide the video options and video info menus whether they're open or not and set the focus back to itself.
			' This will ensure that the channel guide retains its focus while it's opened.
			m.channel_guide.SetFocus( true )
		'}
		end if
	'}
	end if
'}
end sub		

sub OnGlobalCaptionModeChange()
'{
	' The channel guide will adjust the video player dimensions so don't override it here.
	if m.channel_guide.visible = false
	'{
		if m.video_player.video.globalCaptionMode = "Off"
		'{
			m.video_player.video.width = m.global.screen_width
			m.video_player.video.height = m.global.screen_height
			m.video_player.video.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
		'}
		else
		'{
			m.video_player.video.width = 0
			m.video_player.video.height = 0
			m.video_player.video.translation = [ 0, 0 ]
		'}
		end if
	'}
	end if
'}
end sub

sub PlayVideoContent( content as object, content_index as integer )
'{
	if content <> invalid and content_index >= 0 and content.GetChildCount() > content_index
	'{
		content = content.GetChild( content_index )

		' Resume VOD Movies and TV Shows if they errored.
		if ( m.video_content_type = 1 or m.video_content_type = 2 ) and ( m.video_player.content <> invalid and m.video_player.content.isSameNode( content ) and m.video_player.video.state = "error" )
		'{
			m.video_player.resume = true
		'}
		else
		'{
			m.video_content_type = m.global.current_content_type

			m.video_player.content = content

			m.video_player.video.content.Title = content.Title
			m.video_player.video.content.Url = content.Url
			m.video_player.video.content.StreamFormat = content.StreamFormat
			m.video_player.video.content.HttpHeaders = content.HttpHeaders

			if m.video_content_type = 0	' Live TV
			'{
				m.video_player.video.content.SubtitleConfig = { TrackName: "eia608/1" }	' Closed captioning.
			'}
			else
			'{
				m.video_player.video.content.SubtitleConfig = content.SubtitleConfig
			'}
			end if

			m.video_player.video.control = "play"
		'}
		end if
	'}
	end if
'}
end sub

sub OnChannelSelected()
'{
	PlayVideoContent( m.channel_menu.content, m.channel_menu.content_index )
'}
end sub

sub OnGuideChannelSelected()
'{
	PlayVideoContent( m.channel_guide.content, m.channel_guide.content_index )
'}
end sub

sub OnVODSelected()
'{
	PlayVideoContent( m.vod_menu.content, m.vod_menu.content_index )
'}
end sub

sub OnTVIsOff()
'{
	' Triggered from the main thread when the TV is turned off. HDMI is detected as being unplugged.
	if m.top.tv_is_off = true
	'{
		m.top.tv_is_off = false

		if m.video_content_type = 0	' Live TV
		'{
			m.video_player.video.control = "stop"
		'}
		else if m.video_content_type = 1 or m.video_content_type = 2	' Movies/TV Shows
		'{
			m.video_player.video.control = "pause"
		'}
		end if
	'}
	end if
'}
end sub

sub HandleChannelNumberInput()
'{
	channel_number = m.channel_number.text.ToInt()

	' Only switch if the channel number is different.
	if channel_number <> m.global.channel_number
	'{
		channel_group_id = 1	' All group

		m.load_channel_type = 1	' Input Channel
		m.loading_channel = true

		' Save the last channel info so we can a/b.
		m.global.last_channel_group_id = m.global.channel_group_id
		m.global.last_channel_number = m.global.channel_number

		m.global.channel_group_id = channel_group_id
		m.global.channel_number = channel_number
		m.global.load_channel = true
	'}
	end if

	m.channel_number_background.visible = false
	m.channel_number.text = ""
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "back"
		'{
			if m.video_player.video.state = "playing"
			'{
				m.video_player.video.control = "pause"
			'}
			else if m.video_player.video.state = "paused" or m.video_player.video.state = "buffering"
			'{
				m.video_player.video.control = "stop"
			'}
			end if
		'}
		else if key = "play"
		'{
			if m.video_player.video <> invalid
			'{
				if m.video_player.video.state = "playing"
				'{
					m.video_player.video.control = "pause"
				'}
				else if m.video_player.video.state = "paused"
				'{
					m.video_player.video.control = "resume"
				'}
				end if
			'}
			end if
		'}
		else if key = "left"
		'{
			m.current_menu.menu_state = 1	' Show
		'}
		else if key = "right"
		'{
			if m.current_main_menu_content_index = 1 ' Only show the guide if it's for Live TV.
			'{
				m.current_menu.visible = false

				if m.global.loading_epg = false and m.channel_guide.content = invalid
				'{
					m.global.loading_epg = true
					m.global.epg_content_offset = -( Int( m.global.epg_content_limit / 2 ) )
					m.global.load_epg_chunk = true
				'}
				end if

				m.channel_guide.menu_state = 1	' Show
			'}
			end if
		'}
		else if key = "replay"
		'{
			if m.current_main_menu_content_index = 1 ' Only switch channel numbers if it's for Live TV.
			'{
				channel_number_group_id = m.global.last_channel_group_id
				channel_number = m.global.last_channel_number

				' Make sure the channel info is different.
				if channel_number_group_id <> -1 and channel_number <> -1 and channel_number <> m.global.channel_number
				'{
					m.load_channel_type = 1	' Input Channel
					m.loading_channel = true

					' Save the last channel info so we can a/b.
					m.global.last_channel_group_id = m.global.channel_group_id
					m.global.last_channel_number = m.global.channel_number

					m.global.channel_group_id = channel_number_group_id
					m.global.channel_number = channel_number
					m.global.load_channel = true
				'}
				end if
			'}
			end if
		'}
		else if key = "Lit_1" or key = "Lit_2" or key = "Lit_3" or key = "Lit_4" or key = "Lit_5" or key = "Lit_6" or key = "Lit_7" or key = "Lit_8" or key = "Lit_9" or key = "Lit_0"
		'{
			if m.current_main_menu_content_index = 1 ' Only show channel numbers if it's for Live TV.
			'{
				m.channel_number.text = m.channel_number.text + Right( key, 1 )
				m.channel_number_background.width = m.channel_number.boundingRect()[ "width" ] + 20
				m.channel_number_background.height = m.channel_number.boundingRect()[ "height" ] + 15	' It's not exactly centered.
				m.channel_number_background.translation = [ m.global.overscan_offset_x + m.global.screen_width - ( m.channel_number_background.width + 20 ), m.global.overscan_offset_y + 20 ]

				m.channel_number_background.visible = true

				m.channel_number_timer.control = "start"
			'}
			end if
		'}
		end if
	'}
	end if

	return true
'}
end function
