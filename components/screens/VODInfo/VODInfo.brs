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

	m.visible_actors = 0
	m.max_visible_actors = 8

	m.content_index = 0
	m.first_visible_content_index = 0

	m.selected_actor_index = 0

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
	m.panel.width = m.global.screen_width
	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
	m.panel.color = "0x000000FF"

	m.container = CreateObject( "roSGNode", "Poster" )
	m.container.loadDisplayMode = "scaleToZoom"
	m.container.width = m.global.screen_width
	m.container.height = m.global.screen_height

	''''''''''''''''''''''''

	row = CreateObject( "roSGNode", "Rectangle" )
	row.width = m.global.screen_width
	row.height = m.global.screen_height
	row.color = "0x000000E0"

		vod_logo_width = 300
		vod_logo_height = 300

		vod_name_width = m.global.screen_width - ( vod_logo_width + 20 ) - 40
		vod_time_width = vod_name_width
		vod_genres_width = vod_name_width
		vod_directors_width = vod_name_width
		vod_description_width = vod_name_width

		' VOD Logo
		m.vod_logo = CreateObject( "roSGNode", "Poster" )
		m.vod_logo.loadDisplayMode = "scaleToFit"
		m.vod_logo.width = vod_logo_width
		m.vod_logo.height = vod_logo_height
		m.vod_logo.translation = [ 20, 20 ]
		m.vod_logo.uri = "pkg:/images/no-poster.png"
		m.vod_logo.failedBitmapUri = "pkg:/images/no-poster.png"
		row.AppendChild( m.vod_logo )

		' VOD Name
		m.vod_name = CreateObject( "roSGNode", "ScrollingLabel" )
		m.vod_name.maxWidth = vod_name_width
		m.vod_name.translation = [ 20 + vod_logo_width + 20, 20 ]
		m.vod_name.font = "font:LargeSystemFont"
		row.AppendChild( m.vod_name )
		vod_name_height = m.vod_name.boundingRect()[ "height" ]

		' VOD Release Date, Rating, Runtime
		m.vod_release_info = CreateObject( "roSGNode", "Label" )
		m.vod_release_info.width = vod_time_width
		m.vod_release_info.numLines = 1
		m.vod_release_info.translation = [ 20 + vod_logo_width + 20, 20 + vod_name_height + 20 ]
		m.vod_release_info.font = "font:SmallestSystemFont"
		row.AppendChild( m.vod_release_info )
		vod_release_info_height = m.vod_release_info.boundingRect()[ "height" ]

		' VOD Genres
		m.vod_genres = CreateObject( "roSGNode", "Label" )
		m.vod_genres.width = vod_genres_width
		m.vod_genres.numLines = 1
		m.vod_genres.translation = [ 20 + vod_logo_width + 20, 20 + vod_name_height + 20 + vod_release_info_height + 20 ]
		m.vod_genres.font = "font:SmallestSystemFont"
		row.AppendChild( m.vod_genres )
		vod_genres_height = m.vod_genres.boundingRect()[ "height" ]

		' VOD Directors
		m.vod_directors = CreateObject( "roSGNode", "Label" )
		m.vod_directors.width = vod_directors_width
		m.vod_directors.numLines = 1
		m.vod_directors.translation = [ 20 + vod_logo_width + 20, 20 + vod_name_height + 20 + vod_release_info_height + 20 + vod_genres_height + 20 ]
		m.vod_directors.font = "font:SmallestSystemFont"
		row.AppendChild( m.vod_directors )
		vod_directors_height = m.vod_directors.boundingRect()[ "height" ]

		' VOD Description
		m.vod_description = CreateObject( "roSGNode", "Label" )
		m.vod_description.width = vod_description_width
		m.vod_description.numLines = 8
		m.vod_description.translation = [ 20 + vod_logo_width + 20, 20 + vod_name_height + 20 + vod_release_info_height + 20 + vod_genres_height + 20 + vod_directors_height + 20 + 20 ]
		m.vod_description.wrap = true
		m.vod_description.text = ""
		row.AppendChild( m.vod_description )

	m.container.AppendChild( row )
	
	''''''''''''''''''''''''

	label_height = 75

	card_width = 170
	card_height = 315

	card_poster_width = 150
	card_poster_height = 230

	card_spacing = card_width + 40

	m.visible_actors = 0
	m.max_visible_actors = Int( m.global.screen_width / card_spacing )

	m.actor_cards = []

	m.actors = CreateObject( "roSGNode", "Rectangle" )
	m.actors.width = m.global.screen_width
	m.actors.height = card_height
	m.actors.color = "0x00000000"

		m.actor_label = CreateObject( "roSGNode", "Label" )
		m.actor_label.width = m.global.screen_width
		m.actor_label.height = label_height
		m.actor_label.translation = [ 20, 0 ]
		m.actor_label.vertAlign = "center"
		m.actor_label.font = "font:SmallestSystemFont"
		m.actors.AppendChild( m.actor_label )

		for i = 0 to m.max_visible_actors - 1
		'{
			card = CreateObject( "roSGNode", "Rectangle" )
			card.width = card_width
			card.height = card_height
			card.translation = [ 20 + ( i * card_spacing ), label_height ]
			card.color = "0x000000FF"
			card.visible = false

				vod_actor_panel = CreateObject( "roSGNode", "Rectangle" )
				vod_actor_panel.width = card_width
				vod_actor_panel.height = card_height
				vod_actor_panel.color = m.global.panel_color

					vod_actor_background = CreateObject( "roSGNode", "Rectangle" )
					vod_actor_background.width = card_width
					vod_actor_background.height = card_height
					vod_actor_background.color = m.button_background_color

						vod_actor_frame = CreateObject( "roSGNode", "Rectangle" )
						vod_actor_frame.width = card_width
						vod_actor_frame.height = card_height
						if i = 0
						'{
							vod_actor_frame.color = m.button_selected_color
						'}
						else
						'{
							vod_actor_frame.color = m.button_color
						'}
						end if

							vod_actor = CreateObject( "roSGNode", "Poster" )
							vod_actor.loadDisplayMode = "scaleToFit"
							vod_actor.width = card_poster_width
							vod_actor.height = card_poster_height
							vod_actor.translation = [ 10, 10 ]
							vod_actor.failedBitmapUri = "pkg:/images/no-actor.png"
							vod_actor_frame.AppendChild( vod_actor )

							label = CreateObject( "roSGNode", "Label" )
							label.width = card_poster_width
							label.height = label_height
							label.translation = [ 10, 10 + card_poster_height ]
							label.vertAlign = "center"
							label.horizAlign = "center"
							label.font = "font:SmallestSystemFont"
							vod_actor_frame.AppendChild( label )

						m.actor_cards.Push( vod_actor_frame )

					vod_actor_background.AppendChild( vod_actor_frame )
				vod_actor_panel.AppendChild( vod_actor_background )
			card.AppendChild( vod_actor_panel )

			m.actors.AppendChild( card )
		'}
		end for

	m.actors.translation = [ ( m.global.screen_width - ( m.max_visible_actors * card_spacing ) ) / 2, m.global.screen_height - ( label_height + card_height + 20 ) ]

	m.container.AppendChild( m.actors )

	m.panel.AppendChild( m.container )

	m.top.AppendChild( m.panel )

	m.top.ObserveField( "visible", "OnVisible" )
'}
end sub

sub OnVisible()
'{
	if m.top.visible = true
	'{
		' We're in the process of loading the details.
		if m.global.loading_details <> 0
		'{
			for i = 0 to m.max_visible_actors - 1
			'{
				m.actors.GetChild( 1 + i ).visible = false
				m.actor_cards[ i ].GetChild( 0 ).uri = "pkg:/images/no-actor.png"
				m.actor_cards[ i ].GetChild( 1 ).text = ""
			'}
			end for

			m.container.uri =  ""
			m.vod_logo.uri =  "pkg:/images/no-poster.png"

			if m.top.content <> invalid
			'{
				if m.top.content.SeriesTitle <> ""
				'{
					title = m.top.content.SeriesTitle
					' Series Name - Episode Name
					if title <> "" and m.top.content.Title <> ""
					'{
						title = title + " - " + m.top.content.Title
					'}
					end if
					m.vod_name.text = title
				'}
				else
				'{
					m.vod_name.text = m.top.content.Title
				'}
				end if
				m.vod_release_info.text = m.top.content.Year
			'}
			else
			'{
				m.vod_name.text = ""
				m.vod_release_info.text = ""
			'}
			end if
			m.vod_genres.text = ""
			m.vod_directors.text = ""
			m.vod_description.text = "Loading information..."

			m.actor_label.text = ""
		'}
		end if
	'}
	end if
'}
end sub

' time_val is in minutes.
function FormatRuntime( time_val as integer ) as string
'{
	hours = int( time_val / 60 )
	minutes = time_val MOD 60

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

sub OnDetailsContentChange()
'{
	m.content_index = 0
	m.first_visible_content_index = 0

	m.actor_cards[ m.selected_actor_index ].color = m.button_color
	m.selected_actor_index = 0
	m.actor_cards[ m.selected_actor_index ].color = m.button_selected_color

	if m.top.details_content <> invalid
	'{
		m.visible_actors = m.top.details_content.Actors.GetChildCount()
		if m.visible_actors > m.max_visible_actors
		'{
			m.visible_actors = m.max_visible_actors
		'}
		end if

		title = ""
		if m.top.content <> invalid
		'{
			title = m.top.content.SeriesTitle

			' Handle only Season types for Group Content Nodes.
			if ( m.top.content.subtype() = "GroupContentNode" and m.top.content.type = 2 ) or m.top.content.subtype() = "ChannelContentNode"
			'{
				if title <> ""
				'{
					if m.top.details_content.Title <> ""
					'{
						title = title + " - " + m.top.details_content.Title
					'}
					else if m.top.content.Title <> ""
					'{
						title = title + " - " + m.top.content.Title
					'}
					end if
				'}
				else
				'{
					title = m.top.details_content.Title
				'}
				end if
			'}
			end if

			if title = ""
			'{
				title = m.top.content.Title
			'}
			end if
		'}
		else
		'{
			title = m.top.details_content.Title
		'}
		end if
		m.vod_name.text = title

		' The m.container.uri should be uninitialized.
		poster_url = m.top.details_content.HDPosterUrl
		if poster_url = "" and m.top.content <> invalid
		'{
			poster_url =  m.top.content.HDPosterUrl
		'}
		end if
		m.container.uri = poster_url

		poster_url = m.top.details_content.HDPosterUrl
        if m.vod_logo.uri <> poster_url
        '{
            m.vod_logo.loadingBitmapUri = m.vod_logo.uri
            if poster_url = ""
            '{
				if m.top.content <> invalid and m.top.content.HDPosterUrl <> ""
				'{
					poster_url =  m.top.content.HDPosterUrl
				'}
				else
				'{
                	poster_url = "pkg:/images/no-poster.png"
				'}
				end if
            '}
            end if
            m.vod_logo.uri = poster_url
        '}
        end if

		release_info = []
		if m.top.details_content.ReleaseDate <> ""
		'{
			release_text = m.top.details_content.ReleaseDate
			if m.top.details_content.EndDate <> ""
			'{
				release_text = release_text + " to " + m.top.details_content.EndDate
			'}
			end if

			release_info.Push( release_text )
		'}
		else if m.top.content <> invalid and m.top.content.Year <> ""
		'{
			release_info.Push( m.top.content.Year )
		'}
		end if
		if m.top.details_content.Rating <> ""
		'{
			release_info.Push( m.top.details_content.Rating )
		'}
		end if
		if m.top.content <> invalid and m.top.content.subtype() = "ChannelContentNode"
		'{
			if m.top.content.Season <> -1
			'{
				release_info.Push( "Season " + m.top.content.Season.ToStr() )
			'}
			end if
			if m.top.content.Episode <> -1
			'{
				release_info.Push( "Episode " + m.top.content.Episode.ToStr() )
			'}
			end if
		'}
		else
		'{
			if m.top.details_content.Seasons > 0
			'{
				plural = ""
				if m.top.details_content.Seasons > 1
				'{
					plural = "s"
				'}
				end if
				release_info.Push( m.top.details_content.Seasons.ToStr() + " Season" + plural )
			'}
			end if
			if m.top.details_content.Episodes > 0
			'{
				plural = ""
				if m.top.details_content.Episodes > 1
				'{
					plural = "s"
				'}
				end if
				release_info.Push( m.top.details_content.Episodes.ToStr() + " Episode" + plural )
			'}
			end if
		'}
		end if
		formatted_runtime = FormatRuntime( m.top.details_content.Runtime )
		if formatted_runtime <> ""
		'{
			release_info.Push( formatted_runtime )
		'}
		end if
		m.vod_release_info.text = release_info.Join( " • " )

		m.vod_genres.text = m.top.details_content.Genres.Join( ", " )

		if m.top.details_content.Directors.Count() > 0
		'{
			m.vod_directors.text = "Directed by " + m.top.details_content.Directors.Join( ", " )
		'}
		else
		'{
			m.vod_directors.text = ""
		'}
		end if

		m.vod_description.text = m.top.details_content.Description

		if m.visible_actors > 0
		'{
			character_name = ""
			if m.top.details_content.Actors.GetChild( 0 ).Name <> "" and m.top.details_content.Actors.GetChild( 0 ).CharacterName <> ""
			'{
				character_name = " as " + m.top.details_content.Actors.GetChild( 0 ).CharacterName
			'}
			end if
	
			m.actor_label.text = m.top.details_content.Actors.GetChild( 0 ).Name + character_name
	
			for i = 0 to m.visible_actors - 1
			'{
				poster_url = m.top.details_content.Actors.GetChild( i ).HDPosterUrl
				if m.actor_cards[ i ].GetChild( 0 ).uri <> poster_url
				'{
					m.actor_cards[ i ].GetChild( 0 ).loadingBitmapUri = m.actor_cards[ i ].GetChild( 0 ).uri
					if poster_url = ""
					'{
						poster_url = "pkg:/images/no-actor.png"
					'}
					end if
					m.actor_cards[ i ].GetChild( 0 ).uri = poster_url
				'}
				end if
				m.actor_cards[ i ].GetChild( 1 ).text = m.top.details_content.Actors.GetChild( i ).Name
				m.actors.GetChild( 1 + i ).visible = true
			'}
			end for
		'}
		else
		'{
			m.actor_label.text = ""
		'}
		end if
	'}
	else
	'{
		m.visible_actors = 0

		m.container.uri =  ""
		m.vod_logo.uri =  "pkg:/images/no-poster.png"

		if m.top.content <> invalid
		'{
			if m.top.content.SeriesTitle <> ""
			'{
				title = m.top.content.SeriesTitle
				' Series Name - Episode Name
				if title <> "" and m.top.content.Title <> ""
				'{
					title = title + " - " + m.top.content.Title
				'}
				end if
				m.vod_name.text = title
			'}
			else
			'{
				m.vod_name.text = m.top.content.Title
			'}
			end if
			m.vod_release_info.text = m.top.content.Year
		'}
		else
		'{
			m.vod_name.text = ""
			m.vod_release_info.text = ""
		'}
		end if
		m.vod_genres.text = ""
		m.vod_directors.text = ""
		m.vod_description.text = ""

		m.actor_label.text = ""
	'}
	end if

	for i = m.visible_actors to m.max_visible_actors - 1
	'{
		m.actors.GetChild( 1 + i ).visible = false
		m.actor_cards[ i ].GetChild( 0 ).uri = ""
		m.actor_cards[ i ].GetChild( 1 ).text = ""
	'}
	end for
'}
end sub

sub Scroll( scroll_type as integer )
'{
	scroll_offset = 1
	if scroll_type >= 10
	'{
		scroll_offset = m.visible_actors
	'}
	end if

	if scroll_type = 1 or scroll_type = 10	' Move Up
	'{
		if m.selected_actor_index > 0
		'{
			m.actor_cards[ m.selected_actor_index ].color = m.button_color
			
			if scroll_type = 1
			'{
				m.selected_actor_index--
			'}
			else' if scroll_type = 10
			'{
				m.selected_actor_index = 0
			'}
			end if

			m.actor_cards[ m.selected_actor_index ].color = m.button_selected_color
		'}
		else
		'{
			m.first_visible_content_index = m.first_visible_content_index - scroll_offset
		'}
		end if
	'}
	else' if scroll_type = 2 or scroll_type = 20	' Move Down
	'{
		if m.selected_actor_index < m.visible_actors - 1
		'{
			m.actor_cards[ m.selected_actor_index ].color = m.button_color
			
			if scroll_type = 2
			'{
				m.selected_actor_index++
			'}
			else' if scroll_type = 20
			'{
				m.selected_actor_index = m.visible_actors - 1
			'}
			end if

			m.actor_cards[ m.selected_actor_index ].color = m.button_selected_color
		'}
		else
		'{
			m.first_visible_content_index = m.first_visible_content_index + scroll_offset
		'}
		end if
	'}
	end if

	if m.first_visible_content_index < 0
	'{
		m.first_visible_content_index = 0
	'}
	else if m.first_visible_content_index > ( m.top.details_content.Actors.GetChildCount() - m.visible_actors )
	'{
		m.first_visible_content_index = m.top.details_content.Actors.GetChildCount() - m.visible_actors
	'}
	end if

	m.content_index = m.first_visible_content_index + m.selected_actor_index

	character_name = ""
	if m.top.details_content.Actors.GetChild( m.content_index ).Name <> "" and m.top.details_content.Actors.GetChild( m.content_index ).CharacterName <> ""
	'{
		character_name = " as " + m.top.details_content.Actors.GetChild( m.content_index ).CharacterName
	'}
	end if

	m.actor_label.text = m.top.details_content.Actors.GetChild( m.content_index ).Name + character_name

	for i = 0 to m.visible_actors - 1
	'{
		content_index = m.first_visible_content_index + i

		poster_url = m.top.details_content.Actors.GetChild( content_index ).HDPosterUrl
		if m.actor_cards[ i ].GetChild( 0 ).uri <> poster_url
		'{
			m.actor_cards[ i ].GetChild( 0 ).loadingBitmapUri = m.actor_cards[ i ].GetChild( 0 ).uri
			if poster_url = ""
			'{
				poster_url = "pkg:/images/no-actor.png"
			'}
			end if
			m.actor_cards[ i ].GetChild( 0 ).uri = poster_url
		'}
		end if
		m.actor_cards[ i ].GetChild( 1 ).text = m.top.details_content.Actors.GetChild( content_index ).Name
	'}
	end for
'}
end sub

sub HandleScroll()
'{
	if ( m.top.details_content <> invalid ) and ( m.top.details_content.Actors.GetChildCount() > 0 ) and ( m.scroll_type <> 0 )
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
			m.top.menu_state = 0	' Hide
		'}
		else if key = "left" or key = "right" or key = "rewind" or key = "fastforward"
		'{
			if m.top.menu_state = 1
			'{
				if key = "left"
				'{
					m.scroll_type = 1
				'}
				else if key = "right"
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
		end if
	'}
	else if not press
	'{
		if key = "left" or key = "right" or key = "rewind" or key = "fastforward"
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

	return true
'}
end function
