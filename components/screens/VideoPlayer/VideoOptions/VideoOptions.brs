'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.button_background_color = "0x002040E0"
	m.button_color = "0x80808020"
	m.button_selected_color = "0xFFFFFF30"

	m.current_audio_track = 0
	m.current_caption_mode = 0
	m.current_subtitle_track = 0

	m.item_selected = 0

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = m.global.panel_color
	m.panel.width = m.global.screen_width
	m.panel.height = 190
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y + ( m.global.screen_height - m.panel.height ) ]

	''''''''''''''''''''''''

	caption_label_width = 400
	label_width = 600
	label_height = 75

	label = CreateObject( "roSGNode", "Label" )
	label.width = caption_label_width
	label.translation = [ 20, 20 ]
	label.horizAlign = "center"
	label.font = "font:LargeSystemFont"
	label.text = "Caption Modes"
	m.panel.AppendChild( label )

	label = CreateObject( "roSGNode", "Label" )
	label.width = label_width
	label.translation = [ 20 + caption_label_width + 20, 20 ]
	label.horizAlign = "center"
	label.font = "font:LargeSystemFont"
	label.text = "Subtitle Tracks"
	m.panel.AppendChild( label )

	label = CreateObject( "roSGNode", "Label" )
	label.width = label_width
	label.translation = [ 20 + caption_label_width + 20 + label_width + 20, 20 ]
	label.horizAlign = "center"
	label.font = "font:LargeSystemFont"
	label.text = "Audio Tracks"
	m.panel.AppendChild( label )

	''''''''''''''''''''''''

	m.options_columns = CreateObject( "roSGNode", "Rectangle" )
	m.options_columns.width = m.global.screen_width
	m.options_columns.height = m.panel.height
	m.options_columns.color = "0x00000000"

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = caption_label_width
		column_background.height = label_height
		column_background.translation = [ 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_1 = CreateObject( "roSGNode", "Rectangle" )
		option_1.width = caption_label_width
		option_1.height = label_height
		option_1.translation = [ 20, 20 + label_height ]
		option_1.color = m.button_selected_color

			m.caption_modes = CreateObject( "roSGNode", "ScrollingLabel" )
			m.caption_modes.maxWidth = label_width - 40
			m.caption_modes.height = label_height
			m.caption_modes.translation = [ 20, 0 ]
			m.caption_modes.vertAlign = "center"
			m.caption_modes.font = "font:SmallSystemFont"

		option_1.AppendChild( m.caption_modes )

	m.options_columns.AppendChild( option_1 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ 20 + caption_label_width + 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_2 = CreateObject( "roSGNode", "Rectangle" )
		option_2.width = label_width
		option_2.height = label_height
		option_2.translation = [ 20 + caption_label_width + 20, 20 + label_height ]
		option_2.color = m.button_color

			m.subtitle_tracks = CreateObject( "roSGNode", "ScrollingLabel" )
			m.subtitle_tracks.maxWidth = label_width - 40
			m.subtitle_tracks.height = label_height
			m.subtitle_tracks.translation = [ 20, 0 ]
			m.subtitle_tracks.vertAlign = "center"
			m.subtitle_tracks.font = "font:SmallSystemFont"

		option_2.AppendChild( m.subtitle_tracks )

	m.options_columns.AppendChild( option_2 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.width = label_width
		column_background.height = label_height
		column_background.translation = [ 20 + caption_label_width + 20 + label_width + 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_3 = CreateObject( "roSGNode", "Rectangle" )
		option_3.width = label_width
		option_3.height = label_height
		option_3.translation = [ 20 + caption_label_width + 20 + label_width + 20, 20 + label_height ]
		option_3.color = m.button_color

			m.audio_tracks = CreateObject( "roSGNode", "ScrollingLabel" )
			m.audio_tracks.maxWidth = label_width - 40
			m.audio_tracks.height = label_height
			m.audio_tracks.translation = [ 20, 0 ]
			m.audio_tracks.vertAlign = "center"
			m.audio_tracks.font = "font:SmallSystemFont"

		option_3.AppendChild( m.audio_tracks )

	m.options_columns.AppendChild( option_3 )

	''''''''''''''''''''''''

	m.panel.AppendChild( m.options_columns )
	m.top.AppendChild( m.panel )

	m.top.ObserveField( "visible", "OnVisible" )

	m.options = [ option_1, option_2, option_3 ]
'}
end sub

function GetCaptionModeIndexFromString( caption_mode_string as string )
'{
	caption_mode_index = 0

	if caption_mode_string = "On"
	'{
		caption_mode_index = 1
	'}
	else if caption_mode_string = "Instant replay"
	'{
		caption_mode_index = 2
	'}
	else if caption_mode_string = "When mute"
	'{
		caption_mode_index = 3
	'}
	' else if caption_mode_string = "Off"
	' '{
	' 	caption_mode_index = 0
	' '}
	end if

	return caption_mode_index
'}
end function

function GetCaptionModeStringFromIndex( caption_mode_index as integer )
'{
	caption_mode_string = "Off"

	if caption_mode_index = 1
	'{
		caption_mode_string = "On"
	'}
	else if caption_mode_index = 2
	'{
		caption_mode_string = "Instant replay"
	'}
	else if caption_mode_index = 3
	'{
		caption_mode_string = "When mute"
	'}
	' else if caption_mode_index = 0
	' '{
	' 	caption_mode_string = "Off"
	' '}
	end if

	return caption_mode_string
'}
end function

sub OnVisible()
'{
	if m.top.visible = true
	'{
		if m.top.video <> invalid
		'{
			m.current_caption_mode = GetCaptionModeIndexFromString( m.top.video.globalCaptionMode )

			m.caption_modes.text = "[" + m.top.video.globalCaptionMode + "]"

			current_subtitle_track = -1

			if m.top.video.availableSubtitleTracks.Count() > 0
			'{
				for i = 0 to m.top.video.availableSubtitleTracks.Count() - 1
				'{
					if m.top.video.availableSubtitleTracks[ i ].TrackName = m.top.video.currentSubtitleTrack
					'{
						current_subtitle_track = i

						exit for
					'}
					end if
				'}
				end for

				' No match above. We're probably using a subtitle file.
				if current_subtitle_track = -1
				'{
					current_subtitle_track = 0
				'}
				end if
			'}
			end if

			if current_subtitle_track <> -1
			'{
				m.current_subtitle_track = current_subtitle_track
				m.subtitle_tracks.text = GetSubtitleTrackString( m.current_subtitle_track )
			'}
			else
			'{
				m.current_subtitle_track = 0
				m.subtitle_tracks.text = "[Not Available]"
			'}
			end if

			current_audio_track = -1

			if m.top.video.availableAudioTracks.Count() > 0
			'{
				for i = 0 to m.top.video.availableAudioTracks.Count() - 1
				'{
					if m.top.video.availableAudioTracks[ i ].Track = m.top.video.currentAudioTrack
					'{
						current_audio_track = i

						exit for
					'}
					end if
				'}
				end for
			'}
			end if

			if current_audio_track <> -1
			'{
				m.current_audio_track = current_audio_track
				m.audio_tracks.text = GetAudioTrackString( m.current_audio_track )
			'}
			else
			'{
				current_audio_track = 0
				m.audio_tracks.text = "[Not Available]"
			'}
			end if
		'}
		end if
	'}
	end if
'}
end sub

function GetSubtitleTrackString( index as integer )
'{
	description = ""
	if m.top.video.availableSubtitleTracks[ index ].Description <> ""
	'{
		description = " | " + m.top.video.availableSubtitleTracks[ index ].Description
	'}
	end if

	open_bracket = ""
	close_bracket = ""
	if m.top.video.availableSubtitleTracks[ index ].TrackName = m.top.video.currentSubtitleTrack
	'{
		open_bracket = "["
		close_bracket = "]"
	'}
	end if

	track_name = m.top.video.availableSubtitleTracks[ index ].TrackName

	if m.top.video.content <> invalid and m.top.video.content.SubtitleConfig.TrackName <> ""
	'{
		track_a = m.top.video.content.SubtitleConfig.TrackName.Split( "/" )
		if track_a.Count() > 0
		'{
			track_a = track_a[ track_a.Count() - 1 ].Split( "?" )
			track_a = track_a[ 0 ].Split( "#" )
			track_a = track_a[ 0 ].DecodeUri()

			track_b = m.top.video.availableSubtitleTracks[ index ].TrackName.Split( "/" )
			if track_b.Count() > 0
			'{
				track_b = track_b[ track_b.Count() - 1 ].Split( "?" )
				track_b = track_b[ 0 ].Split( "#" )
				track_b = track_b[ 0 ].DecodeUri()

				if track_a = track_b
				'{
					track_name = track_a
				'}
				end if
			'}
			end if
		'}
		end if
	'}
	end if

	return open_bracket + ( index + 1 ).ToStr() + "/" + m.top.video.availableSubtitleTracks.Count().ToStr() + " - " + m.top.video.availableSubtitleTracks[ index ].Language + " - " + track_name + description + close_bracket
'}
end function

function GetAudioTrackString( index as integer )
'{
	name = ""
	if m.top.video.availableAudioTracks[ index ].Name <> ""
	'{
		name = " | " + m.top.video.availableAudioTracks[ index ].Name
	'}
	end if

	open_bracket = ""
	close_bracket = ""
	if m.top.video.availableAudioTracks[ index ].Track = m.top.video.currentAudioTrack
	'{
		open_bracket = "["
		close_bracket = "]"
	'}
	end if

	return open_bracket + ( index + 1 ).ToStr() + "/" + m.top.video.availableAudioTracks.Count().ToStr() + " - " + m.top.video.availableAudioTracks[ index ].Language + " - " + m.top.video.availableAudioTracks[ index ].Track + name + close_bracket
'}
end function

sub HandleOptionSelection( selection_type as integer )
'{
	if m.top.video <> invalid
	'{
		if m.item_selected = 0
		'{
			if selection_type = 1
			'{
				m.current_caption_mode = ( m.current_caption_mode + 4 - 1 ) mod 4
			'}
			else if selection_type = 2
			'{
				m.current_caption_mode = ( m.current_caption_mode + 1 ) mod 4
			'}
			end if

			caption_mode = GetCaptionModeStringFromIndex( m.current_caption_mode )
			if caption_mode = m.top.video.globalCaptionMode
			'{
				m.caption_modes.text = "[" + caption_mode + "]"
			'}
			else
			'{
				m.caption_modes.text = caption_mode
			'}
			end if
		'}
		else if m.item_selected = 1
		'{
			if m.top.video.availableSubtitleTracks.Count() > 0
			'{
				if selection_type = 1
				'{
					m.current_subtitle_track = ( m.current_subtitle_track + m.top.video.availableSubtitleTracks.Count() - 1 ) mod m.top.video.availableSubtitleTracks.Count()
				'}
				else if selection_type = 2
				'{
					m.current_subtitle_track = ( m.current_subtitle_track + 1 ) mod m.top.video.availableSubtitleTracks.Count()
				'}
				end if

				m.subtitle_tracks.text = GetSubtitleTrackString( m.current_subtitle_track )
			'}
			end if
		'}
		else if m.item_selected = 2
		'{
			if m.top.video.availableAudioTracks.Count() > 0
			'{
				if selection_type = 1
				'{
					m.current_audio_track = ( m.current_audio_track + m.top.video.availableAudioTracks.Count() - 1 ) mod m.top.video.availableAudioTracks.Count()
				'}
				else if selection_type = 2
				'{
					m.current_audio_track = ( m.current_audio_track + 1 ) mod m.top.video.availableAudioTracks.Count()
				'}
				end if

				m.audio_tracks.text = GetAudioTrackString( m.current_audio_track )
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
			m.top.menu_state = 0	' Hide
		'}
		else if key = "OK"
		'{
			if m.top.video <> invalid
			'{
				if m.item_selected = 0
				'{
					m.top.video.globalCaptionMode = GetCaptionModeStringFromIndex( m.current_caption_mode )
					m.caption_modes.text = "[" + m.top.video.globalCaptionMode + "]"
				'}
				else if m.item_selected = 1
				'{
					if m.top.video.availableSubtitleTracks.Count() > 0 and m.current_subtitle_track < m.top.video.availableSubtitleTracks.Count()
					'{
						if m.top.video.availableSubtitleTracks[ m.current_subtitle_track ].TrackName <> m.top.video.currentSubtitleTrack
						'{
							m.subtitle_tracks.text = "[" + GetSubtitleTrackString( m.current_subtitle_track ) + "]"

							m.top.video.subtitleTrack = m.top.video.availableSubtitleTracks[ m.current_subtitle_track ].TrackName
						'}
						end if
					'}
					end if
				'}
				else if m.item_selected = 2
				'{
					if m.top.video.availableAudioTracks.Count() > 0 and m.current_audio_track < m.top.video.availableAudioTracks.Count()
					'{
						if m.top.video.availableAudioTracks[ m.current_audio_track ].Track <> m.top.video.currentAudioTrack
						'{
							m.audio_tracks.text = "[" + GetAudioTrackString( m.current_audio_track ) + "]"

							m.top.video.audioTrack = m.top.video.availableAudioTracks[ m.current_audio_track ].Track
						'}
						end if
					'}
					end if
				'}
				end if
			'}
			end if
		'}
		else if key = "left"
		'{
			if m.item_selected > 0
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "right"
		'{
			if m.item_selected < 2
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "up"
		'{
			HandleOptionSelection( 1 )
		'}
		else if key = "down"
		'{
			HandleOptionSelection( 2 )
		'}
		end if
	'}
	end if

	return true
'}
end function
