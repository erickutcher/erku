'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub RunUserInterface()
'{
	screen = CreateObject( "roSGScreen" )
	screen_port = CreateObject( "roMessagePort" )

	screen.SetMessagePort( screen_port )

	m.global = screen.GetGlobalNode()

	m.global.AddField( "feed_url", "string", true )

	m.global.AddField( "preferred_screen_width", "integer", false )
	m.global.AddField( "preferred_screen_height", "integer", false )
	m.global.AddField( "screen_width", "integer", false )
	m.global.AddField( "screen_height", "integer", false )
	m.global.AddField( "overscan_offset_x", "integer", false )
	m.global.AddField( "overscan_offset_y", "integer", false )
	m.global.AddField( "enable_automatic_subtitles", "bool", true )
	m.global.AddField( "channel_sort_type", "integer", true )

	m.global.AddField( "save_window_dimensions", "bool", true )

	m.global.AddField( "set_resume_channel", "bool", true )
	m.global.AddField( "resume_channel", "bool", true )

	m.global.AddField( "channel_group_id", "integer", false )
	m.global.AddField( "channel_number", "integer", false )
	m.global.AddField( "load_channel", "bool", true )

	m.global.AddField( "last_channel_group_id", "integer", false )
	m.global.AddField( "last_channel_number", "integer", false )

	m.global.AddField( "preferred_caption_language", "string", false )
	m.global.AddField( "caption_mode", "string", false )

	m.global.AddField( "current_content_type", "integer", 0 )	' 0 = Live TV, 1 = Movies, 2 = TV Shows

	m.global.AddField( "request_id", "integer", 0 )
	m.global.AddField( "group_id", "integer", 0 )
	m.global.AddField( "vod_content_group_id", "integer", 0 )		' The ID of a group that has VOD content.
	m.global.AddField( "channel_content_group_id", "integer", 0 )	' The ID of a group that has channel content.

	m.global.AddField( "load_request", "bool", true )	' Load either a group or channel/VOD content.

	m.global.AddField( "epg_content_limit", "integer", false )
	m.global.AddField( "epg_content_offset", "integer", false )
	m.global.AddField( "load_epg_chunk", "bool", true )

	m.global.AddField( "group_content_limit", "integer", false )
	m.global.AddField( "group_content_offset", "integer", false )
	m.global.AddField( "load_group_chunk", "bool", true )

	m.global.AddField( "content_limit", "integer", false )
	m.global.AddField( "content_offset", "integer", false )
	m.global.AddField( "load_content_chunk", "bool", true )

	m.global.AddField( "loading_content", "bool", false )
	m.global.AddField( "loading_epg", "bool", false )
	m.global.AddField( "loading_details", "integer", false )	' 0 = not loading, 1 = loading from VOD menu, 2 = loading from video player, 3 = loading from group menu

	m.global.AddField( "search_query", "string", false )

	m.global.AddField( "favorite_add_remove", "integer", false )
	m.global.AddField( "favorite_id", "integer", false )
	m.global.AddField( "set_favorite", "bool", true )
	m.global.AddField( "favorite_status", "integer", false )

	m.global.AddField( "details_name", "string", false )
	m.global.AddField( "details_year", "string", false )
	m.global.AddField( "details_season", "string", false )
	m.global.AddField( "details_episode", "string", false )
	m.global.AddField( "load_details", "bool", true )

	m.global.AddField( "panel_color", "string", false )

	m.global.panel_color = "0x001020E0"

	m.global.feed_url = ""

	m.global.enable_automatic_subtitles = false

	m.global.channel_sort_type = 0	' 0 = Number, 1 = Name

	m.global.preferred_screen_width = 1920
	m.global.preferred_screen_height = 1080

	m.global.screen_width = m.global.preferred_screen_width
	m.global.screen_height = m.global.preferred_screen_height

	m.global.overscan_offset_x = 0
	m.global.overscan_offset_y = 0

	m.global.save_window_dimensions = false

	m.global.current_content_type = -1

	m.global.search_query = ""

	m.global.loading_content = false
	m.global.loading_epg = false
	m.global.loading_details = 0

	m.global.request_id = 0
	m.global.group_id = 0
	m.global.vod_content_group_id = 0
	m.global.channel_content_group_id = 0

	m.global.load_request = false
	m.global.load_group_chunk = false
	m.global.load_content_chunk = false
	m.global.load_epg_chunk = false

	m.global.epg_content_limit = 100
	m.global.epg_content_offset = 0

	m.global.content_limit = 100
	m.global.content_offset = 0

	m.global.group_content_limit = 100
	m.global.group_content_offset = 0

	m.global.favorite_add_remove = 0
	m.global.favorite_id = 0
	m.global.set_favorite = false
	m.global.favorite_status = 0

	m.global.details_name = ""
	m.global.details_year = ""
	m.global.details_season = ""
	m.global.details_episode = ""
	m.global.load_details = false

	m.global.set_resume_channel = false
	m.global.resume_channel = false

	m.global.channel_group_id = -1
	m.global.channel_number = -1
	m.global.load_channel = false

	GetSettings()

	' channel_group_id and channel_number maybe have been saved.
	m.global.last_channel_group_id = m.global.channel_group_id
	m.global.last_channel_number = m.global.channel_number

	device_info = CreateObject( "roDeviceInfo" )

	country_code_map = { "en": "eng", "es": "spa", "fr": "fra",
						 "de": "deu", "it": "ita", "pt": "por",
						 "ru": "rus", "tr": "tur", "pl": "pol",
						 "uk": "ukr", "ro": "ron", "nl": "nld",
						 "hr": "hrv", "hu": "hun", "el": "ell",
						 "cs": "ces", "sv": "swe" }

	if country_code_map.Lookup( device_info.GetPreferredCaptionLanguage() ) <> invalid
	'{
		m.global.preferred_caption_language = country_code_map[ device_info.GetPreferredCaptionLanguage() ]
	'}
	else
	'{
		m.global.preferred_caption_language = "eng"
	'}
	end if
	m.global.caption_mode = device_info.GetCaptionsMode()

	'cec_status = CreateObject( "roCECStatus" )
	'cec_status.SetMessagePort( screen_port )

	hdmi_status = CreateObject( "roHdmiStatus" )
	hdmi_status.SetMessagePort( screen_port )

	' Allows the SceneGraph to defer back to main.
	m.global.ObserveField( "load_request", screen_port )
	m.global.ObserveField( "load_group_chunk", screen_port )
	m.global.ObserveField( "load_content_chunk", screen_port )
	m.global.ObserveField( "load_epg_chunk", screen_port )
	m.global.ObserveField( "load_details", screen_port )
	m.global.ObserveField( "load_channel", screen_port )
	m.global.ObserveField( "set_favorite", screen_port )
	m.global.ObserveField( "set_resume_channel", screen_port )
	m.global.ObserveField( "resume_channel", screen_port )
	m.global.ObserveField( "channel_sort_type", screen_port )
	m.global.ObserveField( "feed_url", screen_port )
	m.global.ObserveField( "enable_automatic_subtitles", screen_port )
	m.global.ObserveField( "save_window_dimensions", screen_port )

	m.scene = screen.CreateScene( "Home" )
	m.scene.backgroundURI = ""
	m.scene.backgroundColor = "0x000000FF"

	screen.Show()

	while true
	'{
		msg = wait( 0, screen_port )

		msg_type = type( msg )

		if msg_type = "roSGNodeEvent"
		'{
			field = msg.GetField()
			if field = "load_request"
			'{
				' We don't know if this request is for group or channel/VOD content.
				LoadContent( m.global.current_content_type, m.global.channel_sort_type, m.global.request_id, m.global.content_limit, m.global.content_offset, m.global.search_query )
			'}
			else if field = "load_group_chunk"
			'{
				LoadContent( m.global.current_content_type, m.global.channel_sort_type, m.global.group_id, m.global.group_content_limit, m.global.group_content_offset, m.global.search_query )
			'}
			else if field = "load_content_chunk"
			'{
				content_group_id = -1
				if m.global.current_content_type = 0	' Live TV
				'{
					content_group_id = m.global.channel_content_group_id
				'}
				else if m.global.current_content_type = 1 or m.global.current_content_type = 2	' VOD Movies/TV Shows
				'{
					content_group_id = m.global.vod_content_group_id
				'}
				end if

				LoadContent( m.global.current_content_type, m.global.channel_sort_type, content_group_id, m.global.content_limit, m.global.content_offset, m.global.search_query )
			'}
			else if field = "load_epg_chunk"
			'{
				LoadEPG( m.global.channel_sort_type, m.global.channel_content_group_id, m.global.epg_content_limit, m.global.epg_content_offset )
			'}
			else if field = "load_details"
			'{
				LoadDetails( m.global.current_content_type, m.global.details_name, m.global.details_year, m.global.details_season, m.global.details_episode )
			'}
			else if field = "load_channel"
			'{
				LoadChannel( m.global.channel_group_id, m.global.channel_number )
			'}
			else if field = "set_favorite"
			'{
				SetFavorite( m.global.favorite_add_remove, m.global.favorite_id )
			'}
			else if field = "set_resume_channel"
			'{
				RegWrite( "RESUME_CHANNEL_GROUP_ID", m.global.channel_group_id.ToStr() )
				RegWrite( "RESUME_CHANNEL_NUMBER", m.global.channel_number.ToStr() )
			'}
			else if field = "resume_channel"
			'{
				value = "0"
				if m.global.resume_channel = true
				'{
					value = "1"
				'}
				end if

				RegWrite( "RESUME_CHANNEL", value )
			'}
			else if field = "channel_sort_type"
			'{
				RegWrite( "CHANNEL_SORT_TYPE", m.global.channel_sort_type.ToStr() )
			'}
			else if field = "feed_url"
			'{
				RegWrite( "FEED_URL", m.global.feed_url )
			'}
			else if field = "enable_automatic_subtitles"
			'{
				value = "0"
				if m.global.enable_automatic_subtitles = true
				'{
					value = "1"
				'}
				end if

				RegWrite( "ENABLE_AUTOMATIC_SUBTITLES", value )
			'}
			else if field = "save_window_dimensions"
			'{
				RegWrite( "SCREEN_WIDTH", m.global.screen_width.ToStr() )
				RegWrite( "SCREEN_HEIGHT", m.global.screen_height.ToStr() )
				RegWrite( "OVERSCAN_OFFSET_X", m.global.overscan_offset_x.ToStr() )
				RegWrite( "OVERSCAN_OFFSET_Y", m.global.overscan_offset_y.ToStr() )
			'}
			end if
		'}
		' else if msg_type = "roCECStatusEvent"
		' '{
		' 	' This could be used to determine if the TV is off.
		' '}
		else if msg_type = "roHdmiStatusEvent"
		'{
			if msg.GetInfo()[ "Plugged" ] = false
			'{
				m.scene.tv_is_off = true
			'}
			end if
		'}
		else if msg_type = "roSGScreenEvent"
		'{
			if msg.IsScreenClosed()
			'{
				exit while
			'}
			end if
		'}
		end if
	'}
	end while

	if screen <> invalid
	'{
		screen.Close()
		screen = invalid
	'}
	end if
'}
end sub

function RegRead( key, section = invalid ) as dynamic
'{
	if section = invalid
	'{
		section = "Default"
	'}
	end if

	sec = CreateObject( "roRegistrySection", section )

	if sec.Exists( key )
	'{
		return sec.Read( key )
	'}
	end if

	return invalid
'}
end function

sub RegWrite( key, val, section = invalid )
'{
	if section = invalid
	'{
		section = "Default"
	'}
	end if

	sec = CreateObject( "roRegistrySection", section )

	sec.Write( key, val )
	sec.Flush()
'}
end sub

sub GetSettings()
'{
	feed_url = RegRead( "FEED_URL" )
	if feed_url <> invalid
	'{
		m.global.feed_url = feed_url
	'}
	end if

	screen_width = RegRead( "SCREEN_WIDTH" )
	if screen_width <> invalid
	'{
		m.global.screen_width = screen_width.ToInt()
	'}
	end if
	screen_height = RegRead( "SCREEN_HEIGHT" )
	if screen_height <> invalid
	'{
		m.global.screen_height = screen_height.ToInt()
	'}
	end if
	overscan_offset_x = RegRead( "OVERSCAN_OFFSET_X" )
	if overscan_offset_x <> invalid
	'{
		m.global.overscan_offset_x = overscan_offset_x.ToInt()
	'}
	end if
	overscan_offset_y = RegRead( "OVERSCAN_OFFSET_Y" )
	if overscan_offset_y <> invalid
	'{
		m.global.overscan_offset_y = overscan_offset_y.ToInt()
	'}
	end if

	enable_automatic_subtitles = RegRead( "ENABLE_AUTOMATIC_SUBTITLES" )
	if enable_automatic_subtitles <> invalid and enable_automatic_subtitles = "1"
	'{
		m.global.enable_automatic_subtitles = true
	'}
	end if

	channel_sort_type = RegRead( "CHANNEL_SORT_TYPE" )
	if channel_sort_type <> invalid
	'{
		m.global.channel_sort_type = channel_sort_type.ToInt()
	'}
	end if

	resume_channel = RegRead( "RESUME_CHANNEL" )
	if resume_channel <> invalid and resume_channel = "1"
	'{
		m.global.resume_channel = true
	'}
	end if

	resume_channel_group_id = RegRead( "RESUME_CHANNEL_GROUP_ID" )
	if resume_channel_group_id <> invalid
	'{
		m.global.channel_group_id = resume_channel_group_id.ToInt()
	'}
	end if

	resume_channel_number = RegRead( "RESUME_CHANNEL_NUMBER" )
	if resume_channel_number <> invalid
	'{
		m.global.channel_number = resume_channel_number.ToInt()
	'}
	end if
'}
end sub

sub LoadContent( content_type as integer, sort_type as integer, id as integer, content_limit as integer, content_offset as integer, search_query as string )
'{
	got_content = false

	url = m.global.feed_url + "/get_content.php?type=" + content_type.ToStr() + "&sort=" + sort_type.ToStr() + "&id=" + id.ToStr() + "&limit=" + content_limit.ToStr() + "&offset=" + content_offset.ToStr()

	transfer = CreateObject( "roUrlTransfer" )
	'transfer.SetHeaders( { "Cookie": "" } )

	' Special ID for the Search group.
	if id = 5
	'{
		url = url + "&query=" + transfer.Escape( search_query )
	'}
	end if

	transfer.EnablePeerVerification( false )
	transfer.SetURL( url )

	json = transfer.GetToString()
	if json <> ""
	'{
		response = ParseJson( json )
		if response <> invalid
		'{
			if response.data.type = 0	' Groups
			'{
				got_content = true

				m.global.group_id = response.data.id

				content = CreateObject( "roSGNode", "GroupContentNode" )
				content.group_id = response.data.id
				content.Title = response.data.name
				content.total = response.data.total

				for each value in response.data.values
				'{
					if ( value.id <> invalid )
					'{
						node = CreateObject( "roSGNode", "GroupContentNode" )
						node.group_id = value.id
						node.Title = value.name

						''''''''''''''''''''''''

						' For TV Shows.
						if value.series_name <> invalid
						'{
							node.SeriesTitle = value.series_name
						'}
						end if
						if value.type <> invalid
						'{
							node.type = value.type
						'}
						end if
						if value.season <> invalid
						'{
							node.Season = value.season
						'}
						end if
						if value.year <> invalid and value.year > 0
						'{
							node.Year = value.year.ToStr()
						'}
						end if

						''''''''''''''''''''''''

						content.AppendChild( node )
					'}
					end if
				'}
				end for

				m.scene.group_content = content
			'}
			else if response.data.type = 1	' Channels
			'{
				got_content = true

				content = CreateObject( "roSGNode", "GroupContentNode" )
				content.group_id = response.data.id
				content.Title = response.data.name
				content.total = response.data.total

				if m.global.current_content_type = 0	' Live TV
				'{
					m.global.channel_content_group_id = response.data.id

					for each value in response.data.values
					'{
						node = CreateObject( "roSGNode", "ChannelContentNode" )
						node.channel_id = value.id
						node.Number = value.number
						node.Title = value.name
						node.HDPosterUrl = value.logo_url
						node.Url = value.url
						node.StreamFormat = value.extension

						if value.headers <> ""
						'{
							node.HttpHeaders = value.headers.Split( Chr( 13 ) + Chr( 10 ) )
						'}
						end if

						if value.favorite <> 0
						'{
							node.Favorite = true
						'}
						end if

						content.AppendChild( node )
					'}
					end for
				'}
				else if m.global.current_content_type = 1 or m.global.current_content_type = 2	' Movies / TV Shows
				'{
					m.global.vod_content_group_id = response.data.id

					for each value in response.data.values
					'{
						node = CreateObject( "roSGNode", "ChannelContentNode" )
						node.channel_id = value.id
						node.Title = value.name
						node.SubtitleConfig = { Language: "", Description: "Custom", TrackName: value.subtitle_url }
						node.HDPosterUrl = value.logo_url
						node.Url = value.url
						node.StreamFormat = value.extension
						if value.year > 0
						'{
							node.Year = value.year.ToStr()
						'}
						end if
						if value.headers <> ""
						'{
							node.HttpHeaders = value.headers.Split( Chr( 13 ) + Chr( 10 ) )
						'}
						end if

						''''''''''''''''''''''''

						' For TV Shows.
						if value.series_name <> invalid
						'{
							node.SeriesTitle = value.series_name
						'}
						end if
						if value.season_name <> invalid
						'{
							node.SeasonTitle = value.season_name
						'}
						end if
						if value.season <> invalid and value.season >= 0
						'{
							node.Season = value.season
						'}
						end if
						if value.episode <> invalid and value.episode >= 0
						'{
							node.Episode = value.episode
						'}
						end if
						if value.series_year <> invalid and value.series_year >= 0
						'{
							node.SeriesYear = value.series_year
						'}
						end if
						if value.season_year <> invalid and value.season_year >= 0
						'{
							node.SeasonYear = value.season_year
						'}
						end if

						''''''''''''''''''''''''

						content.AppendChild( node )
					'}
					end for
				'}
				end if

				m.scene.content = content
			'}
			end if
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home and Group Menu.
		' It allows the Group Menu to display "No Groups Available".
		m.scene.group_content = invalid
	'}
	end if
'}
end sub

sub LoadEPG( sort_type as integer, id as integer, content_limit as integer, content_offset as integer )
'{
	got_content = false

	url = m.global.feed_url + "/get_epg.php?sort=" + sort_type.ToStr() + "&id=" + id.ToStr() + "&limit=" + content_limit.ToStr() + "&offset=" + content_offset.ToStr()

	transfer = CreateObject( "roUrlTransfer" )
	transfer.EnablePeerVerification( false )
	transfer.SetURL( url )
	json = transfer.GetToString()
	if json <> ""
	'{
		response = ParseJson( json )
		if response <> invalid
		'{
			got_content = true

			content = CreateObject( "roSGNode", "GroupContentNode" )
			content.group_id = response.data.id
			content.Title = response.data.name
			content.total = response.data.total

			for each channel in response.data.values
			'{
				channel_node = CreateObject( "roSGNode", "ChannelContentNode" )
				channel_node.channel_id = channel.id
				channel_node.Number = channel.number
				channel_node.Title = channel.name
				channel_node.HDPosterUrl = channel.logo_url
				channel_node.Url = channel.url
				channel_node.StreamFormat = channel.extension

				if channel.headers <> ""
				'{
					channel_node.HttpHeaders = channel.headers.Split( Chr( 13 ) + Chr( 10 ) )
				'}
				end if

				if channel.favorite <> 0
				'{
					channel_node.Favorite = true
				'}
				end if

				for each program in channel.programs
				'{
					' Do not load programs with weird times.
					if program.start < program.stop
					'{
						program_node = CreateObject( "roSGNode", "EPGContentNode" )
						program_node.Title = program.title
						program_node.Description = program.description
						program_node.start_time = program.start
						program_node.end_time = program.stop

						channel_node.AppendChild( program_node )
					'}
					end if
				'}
				end for

				content.AppendChild( channel_node )
			'}
			end for

			m.scene.epg_content = content
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home and Channel Guide.
		' It allows the Channel Guide to display "Guide Not Available".
		m.scene.epg_content = invalid
	'}
	end if
'}
end sub

sub LoadDetails( content_type as integer, name as string, year as string, season as string, episode as string )
'{
	got_content = false

	url = m.global.feed_url + "/get_content_info.php?type=" + content_type.ToStr() + "&year=" + year + "&season=" + season + "&episode=" + episode

	transfer = CreateObject( "roUrlTransfer" )

	url = url + "&name=" + transfer.Escape( name )

	transfer.EnablePeerVerification( false )
	transfer.SetURL( url )

	json = transfer.GetToString()
	if json <> ""
	'{
		response = ParseJson( json )
		if response <> invalid
		'{
			got_content = true

			content = CreateObject( "roSGNode", "DetailsContentNode" )
			content.Title = response.data.title
			content.Runtime = response.data.runtime
			content.Rating = response.data.rating
			content.ReleaseDate = response.data.release_date
			content.EndDate = response.data.end_date
			content.Seasons = response.data.seasons
			content.Episodes = response.data.episodes
			content.HDPosterUrl = response.data.poster_url
			content.Description = response.data.description

			content.Genres = response.data.genres
			content.Directors = response.data.directors

			content.Actors = CreateObject( "roSGNode", "Node" )
			for each value in response.data.actors
			'{
				actor_content = CreateObject( "roSGNode", "ActorContentNode" )
				actor_content.Name = value.name
				actor_content.CharacterName = value.character_name
				actor_content.HDPosterUrl = value.photo_url

				content.Actors.AppendChild( actor_content )
			'}
			end for

			m.scene.details_content = content
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home, VOD Menu, and VOD Info.
		' It allows VOD Info to display "No information available.".
		m.scene.details_content = invalid
	'}
	end if
'}
end sub

sub LoadChannel( id as integer, channel_number as integer )
'{
	got_content = false

	url = m.global.feed_url + "/get_content.php?type=10&id=" + id.ToStr() + "&channel_number=" + channel_number.ToStr()

	transfer = CreateObject( "roUrlTransfer" )
	transfer.EnablePeerVerification( false )
	transfer.SetURL( url )
	json = transfer.GetToString()
	if json <> ""
	'{
		response = ParseJson( json )
		if response <> invalid
		'{
			' There should only be one channel.
			if response.data.values.Count() > 0
			'{
				got_content = true

				content = CreateObject( "roSGNode", "GroupContentNode" )
				content.group_id = response.data.id
				content.Title = response.data.name
				content.total = response.data.total

				m.global.channel_content_group_id = response.data.id

				''''''''''''''''''''''''

				value = response.data.values[ 0 ]

				node = CreateObject( "roSGNode", "ChannelContentNode" )
				node.channel_id = value.id
				node.Number = value.number
				node.Title = value.name
				node.HDPosterUrl = value.logo_url
				node.Url = value.url
				node.StreamFormat = value.extension

				if value.headers <> ""
				'{
					node.HttpHeaders = value.headers.Split( Chr( 13 ) + Chr( 10 ) )
				'}
				end if

				if value.favorite <> 0
				'{
					node.Favorite = true
				'}
				end if

				content.AppendChild( node )

				''''''''''''''''''''''''

				node = CreateObject( "roSGNode", "Node" )

				for each group in response.data.groups
				'{
					group_content = CreateObject( "roSGNode", "GroupContentNode" )
					group_content.group_id = group.id
					group_content.Title = group.name

					node.AppendChild( group_content )
				'}
				end for

				content.AppendChild( node )

				''''''''''''''''''''''''

				' Save our last valid channel number info if it doesn't match the previously saved channel number info.
				' id = m.global.channel_group_id
				' channel_number = m.global.channel_number
				if id <> m.global.last_channel_group_id or channel_number <> m.global.last_channel_number
				'{
					RegWrite( "RESUME_CHANNEL_GROUP_ID", id.ToStr() )
					RegWrite( "RESUME_CHANNEL_NUMBER", channel_number.ToStr() )
				'}
				end if

				m.scene.channel_content = content
			'}
			end if
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home.
		m.scene.channel_content = invalid
	'}
	end if
'}
end sub

sub SetFavorite( add_remove_type as integer, id as integer )
'{
	favorite_status = -1

	url = m.global.feed_url + "/favorites.php?type=" + add_remove_type.ToStr() + "&id=" + id.ToStr()

	transfer = CreateObject( "roUrlTransfer" )
	transfer.EnablePeerVerification( false )
	transfer.SetURL( url )
	json = transfer.GetToString()
	if json <> ""
	'{
		response = ParseJson( json )
		if response <> invalid
		'{
			favorite_status = response
		'}
		end if
	'}
	end if

	m.global.favorite_status = favorite_status
'}
end sub
