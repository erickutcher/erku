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

	m.item_selected = 0

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = m.global.panel_color
	m.panel.width = m.global.screen_width
	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]

	title = CreateObject( "roSGNode", "Label" )
	title.width = m.global.screen_width
	title.height = 100
	title.horizAlign = "center"
	title.vertAlign = "center"
	title.font = "font:LargeBoldSystemFont"
	title.text = "Search"

	m.panel.AppendChild( title )

	row_line = CreateObject( "roSGNode", "Rectangle" )
	row_line.width = m.global.screen_width
	row_line.height = 3
	row_line.translation = [ 0, 100 ]
	row_line.color = "#FFFFFFFF"

	m.panel.AppendChild( row_line )

	''''''''''''''''''''''''

	m.palette = CreateObject( "roSGNode", "RSGPalette" )
	m.palette.colors = { DialogBackgroundColor: "0x001020E0",
					     DialogItemColor: "0xFFFFFFFF",
					     DialogTextColor: "0xFFFFFFFF",
					     DialogFocusColor: "0xFFFFFFFF",
					     DialogFocusItemColor: "0x002040E0",
					     DialogSecondaryTextColor: "0x80808020",
					     DialogSecondaryItemColor: "0x80808020",
					     DialogInputFieldColor: "0x80808020",
					     DialogKeyboardColor: "0x80808020",
					     DialogFootprintColor: "0x80808020" }

	m.top.GetScene().palette = m.palette

	m.keyboard_dialog = CreateObject( "roSGNode", "StandardKeyboardDialog" )
	m.keyboard_dialog.textEditBox.cursorPosition = -1
	m.keyboard_dialog.textEditBox.maxTextLength = 2083
	m.keyboard_dialog.buttons = [ "OK", "Cancel" ]

	m.keyboard_dialog.ObserveField( "buttonSelected", "OnKeyboardDialogButtonSelection" )
	m.keyboard_dialog.ObserveField( "wasClosed", "OnKeyboardDialogClosed" )

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

	''''''''''''''''''''''''

	m.options_columns = CreateObject( "roSGNode", "Rectangle" )
	m.options_columns.width = m.global.screen_width
	m.options_columns.height = 500
	m.options_columns.translation = [ 0, 105 ]
	m.options_columns.color = "0x00000000"


		label = CreateObject( "roSGNode", "Label" )
		label.height = label_height
		label.translation = [ 20, 20 ]
		label.vertAlign = "center"
		label.font = "font:SmallSystemFont"
		label.text = "Search Type:"

	m.options_columns.AppendChild( label )

		m.search_type_1 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.search_type_1.height = label_height
		m.search_type_1.translation = [ 20, 20 + label_height ]
		m.search_type_1.vertAlign = "center"
		m.search_type_1.drawingStyles = m.drawing_styles
		m.search_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked

	m.options_columns.AppendChild( m.search_type_1 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.search_type_1.boundingRect()[ "width" ] + 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_1 = CreateObject( "roSGNode", "Rectangle" )
		option_1.height = label_height
		option_1.translation = [ 20 + m.search_type_1.boundingRect()[ "width" ] + 20, 20 + label_height ]
		option_1.color = m.button_selected_color

			stream_type = CreateObject( "roSGNode", "MultiStyleLabel" )
			stream_type.height = label_height
			stream_type.translation = [ 20, 0 ]
			stream_type.vertAlign = "center"
			stream_type.drawingStyles = m.drawing_styles
			stream_type.text = "Live TV"
			option_1.AppendChild( stream_type )

		option_1.width = stream_type.boundingRect()[ "width" ] + 40
		column_background.width = option_1.width

	m.options_columns.AppendChild( option_1 )

	''''''''''''''''''''''''

	search_type_2_offset = 20 + m.search_type_1.boundingRect()[ "width" ] + 20 + option_1.width

		m.search_type_2 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.search_type_2.height = label_height
		m.search_type_2.translation = [ search_type_2_offset + 20, 20 + label_height ]
		m.search_type_2.vertAlign = "center"
		m.search_type_2.drawingStyles = m.drawing_styles
		m.search_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked

	m.options_columns.AppendChild( m.search_type_2 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ search_type_2_offset + 20 + m.search_type_2.boundingRect()[ "width" ] + 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_2 = CreateObject( "roSGNode", "Rectangle" )
		option_2.height = label_height
		option_2.translation = [ search_type_2_offset + 20 + m.search_type_2.boundingRect()[ "width" ] + 20, 20 + label_height ]
		option_2.color = m.button_color

			stream_type = CreateObject( "roSGNode", "MultiStyleLabel" )
			stream_type.height = label_height
			stream_type.translation = [ 20, 0 ]
			stream_type.vertAlign = "center"
			stream_type.drawingStyles = m.drawing_styles
			stream_type.text = "Movies"
			option_2.AppendChild( stream_type )

		option_2.width = stream_type.boundingRect()[ "width" ] + 40
		column_background.width = option_2.width

	m.options_columns.AppendChild( option_2 )

	''''''''''''''''''''''''

	search_type_3_offset = search_type_2_offset + 20 + m.search_type_2.boundingRect()[ "width" ] + 20 + option_2.width

		m.search_type_3 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.search_type_3.height = label_height
		m.search_type_3.translation = [ search_type_3_offset + 20, 20 + label_height ]
		m.search_type_3.vertAlign = "center"
		m.search_type_3.drawingStyles = m.drawing_styles
		m.search_type_3.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked

	m.options_columns.AppendChild( m.search_type_3 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ search_type_3_offset + 20 + m.search_type_3.boundingRect()[ "width" ] + 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_3 = CreateObject( "roSGNode", "Rectangle" )
		option_3.height = label_height
		option_3.translation = [ search_type_3_offset + 20 + m.search_type_3.boundingRect()[ "width" ] + 20, 20 + label_height ]
		option_3.color = m.button_color

			stream_type = CreateObject( "roSGNode", "MultiStyleLabel" )
			stream_type.height = label_height
			stream_type.translation = [ 20, 0 ]
			stream_type.vertAlign = "center"
			stream_type.drawingStyles = m.drawing_styles
			stream_type.text = "TV Shows"
			option_3.AppendChild( stream_type )

		option_3.width = stream_type.boundingRect()[ "width" ] + 40
		column_background.width = option_3.width

	m.options_columns.AppendChild( option_3 )

	''''''''''''''''''''''''

		label = CreateObject( "roSGNode", "Label" )
		label.height = label_height
		label.translation = [ 20, 20 + ( label_height * 2 ) + 20 ]
		label.vertAlign = "center"
		label.font = "font:SmallSystemFont"
		label.text = "Search For:"

	m.options_columns.AppendChild( label )


		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20, 20 + ( label_height * 3 ) + 20 ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_4 = CreateObject( "roSGNode", "Rectangle" )
		option_4.height = label_height
		option_4.width = m.global.screen_width - 40
		option_4.translation = [ 20, 20 + ( label_height * 3 ) + 20 ]
		option_4.color = m.button_color

			button = CreateObject( "roSGNode", "ScrollingLabel" )
			button.height = label_height
			button.translation = [ 20, 0 ]
			button.vertAlign = "center"
			button.font = "font:SmallSystemFont"
			button.maxWidth = option_4.width - 40
			
		column_background.width = option_4.width

		option_4.AppendChild( button )

	m.options_columns.AppendChild( option_4 )

	''''''''''''''''''''''''

	m.panel.AppendChild( m.options_columns )
	m.top.AppendChild( m.panel )

	m.options = [ option_1, option_2, option_3, option_4 ]

	m.last_search_strings = [ "", "", "" ]
'}
end sub

sub OnSearchTypeChange()
'{
	if m.top.search_type = 0
	'{
		m.search_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.search_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
		m.search_type_3.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	else if m.top.search_type = 1
	'{
		m.search_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
		m.search_type_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.search_type_3.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	else if m.top.search_type = 2
	'{
		m.search_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
		m.search_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
		m.search_type_3.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
	'}
	end if

	m.options[ 3 ].GetChild( 0 ).text = m.last_search_strings[ m.top.search_type ]

	m.options[ m.item_selected ].color = m.button_color
	m.item_selected = 3
	m.options[ m.item_selected ].color = m.button_selected_color
'}
end sub

sub OnKeyboardDialogButtonSelection()
'{
	if m.keyboard_dialog.buttonSelected = 0	' OK button
	'{
		m.options[ m.item_selected ].GetChild( 0 ).text = m.keyboard_dialog.text

		m.last_search_strings[ m.top.search_type ] = m.keyboard_dialog.text

		m.global.current_content_type = m.top.search_type

		m.global.search_query = m.keyboard_dialog.text

		' We load the parent group (Live TV, Movies, TV Shows) of the Search group first.
		' This way we'll be able to navigate back through the menus as if we had entered them normally.
		m.global.loading_content = true
		m.global.group_id = 0
		m.global.group_content_offset = 0
		m.global.load_group_chunk = true
	'}
	end if

	m.keyboard_dialog.close = true
'}
end sub

sub OnKeyboardDialogClosed()
'{
	m.top.GetScene().dialog = invalid
'}
end sub

sub OnTextBoxSelected()
'{
	m.keyboard_dialog.title = "Search"
	m.keyboard_dialog.text = m.last_search_strings[ m.top.search_type ]

	m.keyboard_dialog.textEditBox.cursorPosition = -1

	m.top.GetScene().dialog = m.keyboard_dialog
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
			if m.item_selected = 3
			'{
				OnTextBoxSelected()
			'}
			else' if m.item_selected = 0 or m.item_selected = 1 or m.item_selected = 2
			'{
				m.top.search_type = m.item_selected
			'}
			end if
		'}
		else if key = "up"
		'{
			if m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 0
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "down"
		'{
			if m.item_selected <> 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 3
				m.options[ m.item_selected ].color = m.button_selected_color
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
			if m.item_selected < 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		end if
	'}
	end if

	return true
'}
end function
