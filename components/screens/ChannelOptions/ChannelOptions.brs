'
'	Erku - IPTV client for the Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.row_width = m.global.screen_width

	m.button_background_color = "0x002040E0"
	m.button_selected_color = "0xFFFFFF30"

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = "0x000000FF"
	m.panel.width = m.row_width

	m.container = CreateObject( "roSGNode", "Rectangle" )
	m.container.width = m.row_width
	m.container.color = m.global.panel_color

	title = CreateObject( "roSGNode", "Label" )
	title.width = m.global.screen_width
	title.height = 75
	title.translation = [ 0, 20 ]
	title.horizAlign = "center"
	title.font = "font:LargeBoldSystemFont"
	title.text = "Channel Options"

	m.container.AppendChild( title )

	m.channel_name = CreateObject( "roSGNode", "ScrollingLabel" )
	m.channel_name.maxWidth = m.global.screen_width
	m.channel_name.height = 75
	m.channel_name.translation = [ 0, 20 + 75 + 20 ]
	m.channel_name.horizAlign = "center"

	m.container.AppendChild( m.channel_name )

	''''''''''''''''''''''''

	m.drawing_styles = {
		"icon": {
			"fontSize": 48
			"fontUri": "pkg:/components/fonts/Erku.ttf"
			"color": "#FFFFFFFF"
		}
		"default": {
			"fontUri": "font:SmallSystemFont"
			"color": "#FFFFFFFF"
		}
	}

	label_height = 75

	m.options_columns = CreateObject( "roSGNode", "Rectangle" )
	m.options_columns.width = m.global.screen_width
	m.options_columns.height = 500
	m.options_columns.translation = [ 0, 20 + 150 + 20 ]
	m.options_columns.color = "0x00000000"

		m.favorites_icon = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.favorites_icon.height = label_height
		m.favorites_icon.translation = [ 20, 20 ]
		m.favorites_icon.vertAlign = "center"
		m.favorites_icon.drawingStyles = m.drawing_styles
		m.favorites_icon.text = "<icon>" + chr( 59655 ) + "</icon>"	' Add Bookmark

	m.options_columns.AppendChild( m.favorites_icon )

		m.add_remove_favorites_background = CreateObject( "roSGNode", "Rectangle" )
		m.add_remove_favorites_background.height = label_height
		m.add_remove_favorites_background.translation = [ 20 + m.favorites_icon.boundingRect()[ "width" ] + 20, 20 ]
		m.add_remove_favorites_background.color = m.button_background_color

	m.options_columns.AppendChild( m.add_remove_favorites_background )

		m.add_remove_favorites_selected = CreateObject( "roSGNode", "Rectangle" )
		m.add_remove_favorites_selected.height = label_height
		m.add_remove_favorites_selected.translation = [ 20 + m.favorites_icon.boundingRect()[ "width" ] + 20, 20 ]
		m.add_remove_favorites_selected.color = m.button_selected_color

			m.add_remove_favorites = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.add_remove_favorites.height = label_height
			m.add_remove_favorites.translation = [ 20, 0 ]
			m.add_remove_favorites.vertAlign = "center"
			m.add_remove_favorites.drawingStyles = m.drawing_styles
			m.add_remove_favorites.text = "Add to Favorites"
			m.add_remove_favorites_selected.AppendChild( m.add_remove_favorites )

		m.add_remove_favorites_selected.width = m.add_remove_favorites.boundingRect()[ "width" ] + 40
		m.add_remove_favorites_background.width = m.add_remove_favorites_selected.width


	m.options_columns.AppendChild( m.add_remove_favorites_selected )

	m.container.AppendChild( m.options_columns )

	
	''''''''''''''''''''''''
	
	m.container.height = m.global.screen_height
	m.panel.AppendChild( m.container )


	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
	m.top.AppendChild( m.panel )

	m.top.ObserveField( "visible", "OnVisible" )

	m.saving_favorite = false
'}
end sub

sub OnFavoriteStatusChanged()
'{
	if m.global.favorite_status = 1
	'{
		if m.global.favorite_add_remove = false
		'{
			m.top.add_remove_favorite_state = 0	' Remove from Favorites.
		'}
		else
		'{
			m.top.add_remove_favorite_state = 1	' Add to Favorites.
		'}
		end if
	'}
	end if

	m.global.favorite_status = 0

	m.saving_favorite = false

	m.top.menu_state = 0	' Hide
'}
end sub

sub OnVisible()
'{
	if m.top.visible = true
	'{
		m.global.ObserveField( "favorite_status", "OnFavoriteStatusChanged" )

		if m.top.content <> invalid
		'{
			m.channel_name.text = m.top.content.Title

			if m.top.content.Favorite = false
			'{
				m.favorites_icon.text = "<icon>" + chr( 59655 ) + "</icon>"	' Add Bookmark
				m.add_remove_favorites.text = "Add to Favorites"
			'}
			else
			'{
				m.favorites_icon.text = "<icon>" + chr( 59654 ) + "</icon>"	' Remove Bookmark
				m.add_remove_favorites.text = "Remove from Favorites"
			'}
			end if

			m.add_remove_favorites_selected.width = m.add_remove_favorites.boundingRect()[ "width" ] + 40
			m.add_remove_favorites_background.width = m.add_remove_favorites_selected.width
		'}
		end if
	'}
	else
	'{
		m.global.UnobserveField( "favorite_status" )
	'}
	end if
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "OK"
		'{
			if m.top.content <> invalid
			'{
				if m.saving_favorite = false
				'{
					m.saving_favorite = true

					m.global.favorite_id = m.top.content.channel_id

					if m.top.content.Favorite = false	' Add to Favorites.
					'{
						m.global.favorite_add_remove = true
					'}
					else	' Remove from Favorites.
					'{
						m.global.favorite_add_remove = false
					'}
					end if

					m.global.set_favorite = true
				'}
				end if
			'}
			end if
		'}
		else if key = "back"
		'{
			m.top.menu_state = 0	' Hide
		'}
		end if
	'}
	end if

	return true
'}
end function
