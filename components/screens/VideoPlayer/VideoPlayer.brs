'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.video = m.top.FindNode( "Video" )
	m.video.enableUI = false
	if m.video.globalCaptionMode = "Off"
	'{
		m.video.width = m.global.screen_width
		m.video.height = m.global.screen_height
		m.video.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
	'}
	else
	'{
		m.video.width = m.global.preferred_screen_width
		m.video.height = m.global.preferred_screen_height
		m.video.translation = [ 0, 0 ]
	'}
	end if

	m.video.content = CreateObject( "roSGNode", "ContentNode" )

	m.top.video = m.video

	m.video_info = m.top.FindNode( "VideoInfo" )
	m.video_options = m.top.FindNode( "VideoOptions" )

	m.video_info.ObserveField( "menu_state", "OnVideoInfoStateChanged" )
	m.video_options.ObserveField( "menu_state", "OnVideoOptionsStateChanged" )

	m.video.ObserveField( "state", "OnVideoStateChange" )
	m.video.ObserveField( "bufferingStatus", "OnVideoBufferingStatus" )

	m.video_info.video = m.video
	m.video_options.video = m.video

	' Don't set them again if they've been turned on for the current video.
	' This will reset along with the video caption mode if we've switched videos.
	m.automatic_subtitles_set = false

	''''''''''''''''''''''''

	m.background = m.top.FindNode( "Background" )
	m.background.color = "0x000000FF"
	m.background.width = m.video.width
	m.background.height = m.video.height
	m.background.translation = [ m.video.boundingRect()[ "x" ], m.video.boundingRect()[ "y" ] ]

		m.poster = CreateObject( "roSGNode", "Poster" )
		m.poster.width = m.video.width
		m.poster.height = m.video.height
		m.poster.loadDisplayMode = "scaleToZoom"
		m.background.AppendChild( m.poster )

		m.overlay = CreateObject( "roSGNode", "Rectangle" )
		m.overlay.color = "0x000000E0"'m.global.panel_color
		m.overlay.width = m.video.width
		m.overlay.height = m.video.height
		m.background.AppendChild( m.overlay )
	
	m.background.visible = false

	''''''''''''''''''''''''

	label_height = 75
	progress_height = 10

	m.progress_bar = m.top.FindNode( "ProgressBar" )
	m.progress_bar.color = "0x00000000"
	m.progress_bar.width = m.video.width / 2
	m.progress_bar.height = label_height + label_height + progress_height
	m.progress_bar.translation = [ m.video.boundingRect()[ "x" ] + ( m.video.width - m.progress_bar.width ) / 2, m.video.boundingRect()[ "y" ] + ( m.video.height - m.progress_bar.height ) / 2 ]

		m.progress_title = CreateObject( "roSGNode", "ScrollingLabel" )
		m.progress_title.maxWidth = m.progress_bar.width
		m.progress_title.height = label_height
		m.progress_title.vertAlign = "center"
		m.progress_title.horizAlign = "center"
		m.progress_title.font = "font:SmallSystemFont"
		m.progress_bar.AppendChild( m.progress_title )

		m.progress = CreateObject( "roSGNode", "Poster" )
		m.progress.width = m.progress_bar.width
		m.progress.height = progress_height
		m.progress.translation = [ 0, label_height ]
		m.progress.uri = "pkg:/images/progress.9.png"

			m.progress_step = CreateObject( "roSGNode", "Poster" )
			m.progress_step.width = 0
			m.progress_step.height = progress_height
			m.progress_step.uri = "pkg:/images/progress_step.9.png"
			m.progress.AppendChild( m.progress_step )

		m.progress_bar.AppendChild( m.progress )

		m.progress_percent = CreateObject( "roSGNode", "Label" )
		m.progress_percent.width = m.progress_bar.width
		m.progress_percent.height = label_height
		m.progress_percent.translation = [ 0, label_height + progress_height ]
		m.progress_percent.vertAlign = "center"
		m.progress_percent.horizAlign = "center"
		m.progress_percent.font = "font:SmallSystemFont"
		m.progress_bar.AppendChild( m.progress_percent )

	m.progress_bar.visible = false

	''''''''''''''''''''''''

	m.vod_info = CreateObject( "roSGNode", "VODInfo" )

	m.vod_info.ObserveField( "menu_state", "OnVODInfoStateChanged" )

	m.top.AppendChild( m.vod_info )

	' The video player has been repositioned.
	m.video.ObserveField( "translation", "OnTranslationChanged" )
'}
end sub

sub OnTranslationChanged()
'{
	m.background.width = m.top.width
	m.background.height = m.top.height
	m.poster.width = m.top.width
	m.poster.height = m.top.height
	m.overlay.width = m.top.width
	m.overlay.height = m.top.height

	m.background.translation = [ 0, 0 ]
	m.poster.translation = [ 0, 0 ]
	m.overlay.translation = [ 0, 0 ]

	''''''''''''''''''''''''

	width = m.video.width / 2

	m.progress_bar.width = width
	m.progress_title.maxWidth = width
	m.progress.width = width
	m.progress_percent.width = width

	m.progress_bar.translation = [ m.video.boundingRect()[ "x" ] + ( m.video.width - m.progress_bar.width ) / 2, m.video.boundingRect()[ "y" ] + ( m.video.height - m.progress_bar.height ) / 2 ]
'}
end sub

sub OnVODInfoStateChanged()
'{
	if m.vod_info.menu_state = 0
	'{
		m.vod_info.visible = false
		m.vod_info.SetFocus( false )
		m.top.SetFocus( true )
	'}
	else if m.vod_info.menu_state = 1
	'{
		m.vod_info.visible = true
		m.vod_info.SetFocus( true )
	'}
	end if
'}
end sub

sub OnContentChange()
'{
	m.video_info.content = m.top.content
	m.video_options.content = m.top.content

	m.automatic_subtitles_set = false
	m.video.globalCaptionMode = m.global.caption_mode	' Reset

	if m.top.content <> invalid
	'{
		m.poster.uri = m.top.content.HDPosterUrl
	'}
	else
	'{
		m.poster.uri = ""
	'}
	end if

	if m.global.current_content_type = 1 or m.global.current_content_type = 2	' Movies/TV Shows
	'{
		if m.vod_info.content = invalid or m.vod_info.content.isSameNode( m.top.content ) = false
		'{
			m.vod_info.content = m.top.content

			m.global.loading_details = 2	' Loading Video Player details.
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
	'}
	else' if m.global.current_content_type = 0	' Live TV
	'{
		m.vod_info.details_content = invalid
		m.video_info.details_content = invalid
	'}
	end if
'}
end sub

sub OnDetailsContentChange()
'{
	m.vod_info.details_content = m.top.details_content
	m.video_info.details_content = m.top.details_content

	if m.top.details_content <> invalid and m.top.details_content.HDPosterUrl <> ""
	'{
		m.poster.uri = m.top.details_content.HDPosterUrl
	'}
	end if
'}
end sub

sub OnVideoStateChange()
'{
	if m.video.state = "playing"
	'{
		if m.global.enable_automatic_subtitles = true and m.automatic_subtitles_set = false and m.global.caption_mode = "Off" and m.video.globalCaptionMode = "Off"
		'{
			' Are there audio tracks?
			if m.video.availableAudioTracks.Count() > 0
			'{
				' Go through all of them.
				for i = 0 to m.video.availableAudioTracks.Count() - 1
				'{
					' Find the audio track that's currently set.
					if m.video.availableAudioTracks[ i ].Track = m.video.currentAudioTrack
					'{
						' Does the audio track's language match our perferred language?
						if m.video.availableAudioTracks[ i ].Language <> m.global.preferred_caption_language
						'{
							' See if there are any subtitle tracks.
							if m.video.availableSubtitleTracks.Count() > 0
							'{
								' Go through all of them.
								for j = 0 to m.video.availableSubtitleTracks.Count() - 1
								'{
									' Find the subtitle track that matches our preferred language.
									if m.video.availableSubtitleTracks[ j ].Language = m.global.preferred_caption_language
									'{
										m.automatic_subtitles_set = true
										m.video.globalCaptionMode = "On"

										exit for
									'}
									end if
								'}
								end for
							'}
							end if
						'}
						end if

						exit for
					'}
					end if
				'}
				end for
			'}
			end if
		'}
		end if
	'}
	else if m.video.state = "stopped" or m.video.state = "finished" or m.video.state = "error"
	'{
		m.video_info.menu_state = 0	' Hide
		m.video_options.menu_state = 0	' Hide

		m.progress_bar.visible = false

		m.automatic_subtitles_set = false
		m.video.globalCaptionMode = m.global.caption_mode	' Reset

		m.video.control = "stop"
	'}
	end if
'}
end sub

sub OnVideoBufferingStatus()
'{
	if m.video.bufferingStatus <> invalid
	'{
		m.background.visible = true

		m.progress_step.width = Int( ( m.video.bufferingStatus.percentage / 100 ) * m.progress_bar.width )

		m.progress_percent.text = m.video.bufferingStatus.percentage.ToStr() + "%"

		if m.progress_bar.visible = false
		'{
			if m.top.content <> invalid
			'{
				m.progress_title.text = m.top.content.Title
			'}
			end if

			m.progress_bar.visible = true
		'}
		end if
	'}
	else
	'{
		m.progress_bar.visible = false

		m.background.visible = false
	'}
	end if
'}
end sub

sub OnVideoInfoStateChanged()
'{
	if m.video_info.menu_state = 0
	'{
		m.video_info.visible = false
		m.video_info.SetFocus( false )
		m.top.SetFocus( true )
	'}
	else if m.video_info.menu_state = 1
	'{
		m.video_info.visible = true
		m.video_info.SetFocus( true )
	'}
	end if
'}
end sub

sub OnVideoOptionsStateChanged()
'{
	if m.video_options.menu_state = 0
	'{
		m.video_options.visible = false
		m.video_options.SetFocus( false )
		m.top.SetFocus( true )
	'}
	else if m.video_options.menu_state = 1
	'{
		m.video_options.visible = true
		m.video_options.SetFocus( true )
	'}
	end if
'}
end sub

sub OnResume()
'{
	if m.top.resume = true
	'{
		m.top.resume = false

		m.video_info.resume = true
		m.video_info.menu_state = 1	' Show
	'}
	end if
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "down" or key = "fastforward" or key = "rewind"
		'{
			m.video_info.menu_state = 1	' Show

			return true
		'}
		else if key = "right"
		'{
			if m.global.current_content_type = 1 or m.global.current_content_type = 2	' Movies/TV Shows
			'{
				if m.top.content <> invalid
				'{
					if m.vod_info.content = invalid or m.vod_info.content.isSameNode( m.top.content ) = false
					'{
						m.vod_info.content = m.top.content

						m.global.loading_details = 2	' Loading Video Player details.
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

				return true
			'}
			'else if m.global.current_content_type = 0	' Live TV
			'{
				' Fall through and show the guide.
			'}
			end if
		'}
		else if key = "options"
		'{
			m.video_options.menu_state = 1	' Show

			return true
		'}
		end if
	'}
	end if

	return false
'}
end function
	