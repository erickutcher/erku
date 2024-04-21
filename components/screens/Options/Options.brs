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
	title.text = "Options"

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
	m.keyboard_dialog.text = m.global.feed_url
	m.keyboard_dialog.textEditBox.cursorPosition = -1
	m.keyboard_dialog.textEditBox.maxTextLength = 2083
	m.keyboard_dialog.title = "Enter The Feed URL"
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



	' Feed URL

		label = CreateObject( "roSGNode", "Label" )
		label.height = label_height
		label.translation = [ 20, 20 ]
		label.vertAlign = "center"
		label.font = "font:SmallSystemFont"
		label.text = "Feed URL:"

	m.options_columns.AppendChild( label )


		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_1 = CreateObject( "roSGNode", "Rectangle" )
		option_1.height = label_height
		option_1.width = m.global.screen_width - 40
		option_1.translation = [ 20, 20 + label_height ]
		option_1.color = m.button_selected_color

			button = CreateObject( "roSGNode", "ScrollingLabel" )
			button.height = label_height
			button.translation = [ 20, 0 ]
			button.vertAlign = "center"
			button.font = "font:SmallSystemFont"
			button.text = m.global.feed_url
			button.maxWidth = option_1.width - 40

		column_background.width = option_1.width

		option_1.AppendChild( button )

	m.options_columns.AppendChild( option_1 )

	y_offset = option_1.boundingRect()[ "y" ] + option_1.boundingRect()[ "height" ]


	' Automatic Subtitles
	

		m.auto_subs_icon = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.auto_subs_icon.height = label_height
		m.auto_subs_icon.translation = [ 20, 20 + y_offset ]
		m.auto_subs_icon.vertAlign = "center"
		m.auto_subs_icon.drawingStyles = m.drawing_styles
		if m.global.enable_automatic_subtitles = false
		'{
			m.auto_subs_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
		'}
		else
		'{
			m.auto_subs_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
		'}
		end if

	m.options_columns.AppendChild( m.auto_subs_icon )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.auto_subs_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_2 = CreateObject( "roSGNode", "Rectangle" )
		option_2.height = label_height
		option_2.translation = [ 20 + m.auto_subs_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		option_2.color = m.button_color

			m.auto_subs = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.auto_subs.height = label_height
			m.auto_subs.translation = [ 20, 0 ]
			m.auto_subs.vertAlign = "center"
			m.auto_subs.drawingStyles = m.drawing_styles
			m.auto_subs.text = "Enable Automatic Subtitles"
			option_2.AppendChild( m.auto_subs )

		option_2.width = m.auto_subs.boundingRect()[ "width" ] + 40
		column_background.width = option_2.width


	m.options_columns.AppendChild( option_2 )

	y_offset = option_2.boundingRect()[ "y" ] + option_2.boundingRect()[ "height" ]



	' Sort Type

		label = CreateObject( "roSGNode", "Label" )
		label.height = label_height
		label.translation = [ 20, 20 + y_offset ]
		label.vertAlign = "center"
		label.font = "font:SmallSystemFont"
		label.text = "Sort channels by:"

	m.options_columns.AppendChild( label )

		m.channel_sort_type_1 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.channel_sort_type_1.height = label_height
		m.channel_sort_type_1.translation = [ 20, 20 + y_offset + label_height ]
		m.channel_sort_type_1.vertAlign = "center"
		m.channel_sort_type_1.drawingStyles = m.drawing_styles
		m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked

	m.options_columns.AppendChild( m.channel_sort_type_1 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_3 = CreateObject( "roSGNode", "Rectangle" )
		option_3.height = label_height
		option_3.translation = [ 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_3.color = m.button_color

			stream_type = CreateObject( "roSGNode", "MultiStyleLabel" )
			stream_type.height = label_height
			stream_type.translation = [ 20, 0 ]
			stream_type.vertAlign = "center"
			stream_type.drawingStyles = m.drawing_styles
			stream_type.text = "Number"
			option_3.AppendChild( stream_type )

		option_3.width = stream_type.boundingRect()[ "width" ] + 40
		column_background.width = option_3.width

	m.options_columns.AppendChild( option_3 )


	channel_sort_type_2_offset = 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20 + option_3.width

		m.channel_sort_type_2 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.channel_sort_type_2.height = label_height
		m.channel_sort_type_2.translation = [ channel_sort_type_2_offset + 20, 20 + y_offset + label_height ]
		m.channel_sort_type_2.vertAlign = "center"
		m.channel_sort_type_2.drawingStyles = m.drawing_styles
		m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked

	m.options_columns.AppendChild( m.channel_sort_type_2 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ channel_sort_type_2_offset + 20 + m.channel_sort_type_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_4 = CreateObject( "roSGNode", "Rectangle" )
		option_4.height = label_height
		option_4.translation = [ channel_sort_type_2_offset + 20 + m.channel_sort_type_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_4.color = m.button_color

			stream_type = CreateObject( "roSGNode", "MultiStyleLabel" )
			stream_type.height = label_height
			stream_type.translation = [ 20, 0 ]
			stream_type.vertAlign = "center"
			stream_type.drawingStyles = m.drawing_styles
			stream_type.text = "Name"
			option_4.AppendChild( stream_type )

		option_4.width = stream_type.boundingRect()[ "width" ] + 40
		column_background.width = option_4.width

	m.options_columns.AppendChild( option_4 )

	y_offset = option_3.boundingRect()[ "y" ] + option_3.boundingRect()[ "height" ]


	if m.global.channel_sort_type = 0
	'{
		m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Buttno Unchecked
	'}
	else
	'{
		m.channel_sort_type_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.channel_sort_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	end if




	' Resume last channel.

		m.resume_channel_icon = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.resume_channel_icon.height = label_height
		m.resume_channel_icon.translation = [ 20, 20 + y_offset ]
		m.resume_channel_icon.vertAlign = "center"
		m.resume_channel_icon.drawingStyles = m.drawing_styles
		if m.global.resume_channel = false
		'{
			m.resume_channel_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
		'}
		else
		'{
			m.resume_channel_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
		'}
		end if

	m.options_columns.AppendChild( m.resume_channel_icon )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.resume_channel_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_5 = CreateObject( "roSGNode", "Rectangle" )
		option_5.height = label_height
		option_5.translation = [ 20 + m.resume_channel_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		option_5.color = m.button_color

			m.auto_subs = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.auto_subs.height = label_height
			m.auto_subs.translation = [ 20, 0 ]
			m.auto_subs.vertAlign = "center"
			m.auto_subs.drawingStyles = m.drawing_styles
			m.auto_subs.text = "Resume Channel Upon Startup"
			option_5.AppendChild( m.auto_subs )

		option_5.width = m.auto_subs.boundingRect()[ "width" ] + 40
		column_background.width = option_5.width

	m.options_columns.AppendChild( option_5 )

	y_offset = option_5.boundingRect()[ "y" ] + option_5.boundingRect()[ "height" ]



	' Overscan adjustments.

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20, 20 + y_offset ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_6 = CreateObject( "roSGNode", "Rectangle" )
		option_6.height = label_height
		option_6.translation = [ 20, 20 + y_offset ]
		option_6.color = m.button_color

			button = CreateObject( "roSGNode", "Label" )
			button.height = label_height
			button.translation = [ 20, 0 ]
			button.vertAlign = "center"
			button.font = "font:SmallSystemFont"
			button.text = "Adjust Overscan Coordinates..."

		option_6.width = button.boundingRect()[ "width" ] + 40
		column_background.width = option_6.width

		option_6.AppendChild( button )

	m.options_columns.AppendChild( option_6 )

	''''''''''''''''''''''''

	m.panel.AppendChild( m.options_columns )
	m.top.AppendChild( m.panel )

	' Add this last so that it can overlap the options window.
	m.adjust_overscan = CreateObject( "roSGNode", "AdjustOverscan" )
	m.adjust_overscan.ObserveField( "menu_state", "OnAdjustOverscanStateChanged" )
	m.top.AppendChild( m.adjust_overscan )

	m.options = [ option_1, option_2, option_3, option_4, option_5, option_6 ]
'}
end sub

sub OnKeyboardDialogButtonSelection()
'{
	if m.keyboard_dialog.buttonSelected = 0	' OK button
	'{
		m.options[ 0 ].GetChild( 0 ).text = m.keyboard_dialog.text

		m.global.feed_url = m.keyboard_dialog.text
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
	m.keyboard_dialog.textEditBox.cursorPosition = -1

	m.top.GetScene().dialog = m.keyboard_dialog
'}
end sub

sub OnAdjustOverscanStateChanged()
'{
	if m.adjust_overscan.menu_state = 0
	'{
		m.adjust_overscan.visible = false
		m.options_columns.SetFocus( true )
	'}
	else if m.adjust_overscan.menu_state = 1
	'{
		m.adjust_overscan.visible = true
		m.adjust_overscan.SetFocus( true )
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
			if m.item_selected = 0
			'{
				OnTextBoxSelected()
			'}
			else if m.item_selected = 1
			'{
				if m.global.enable_automatic_subtitles = false
				'{
					m.global.enable_automatic_subtitles = true
					m.auto_subs_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
				'}
				else
				'{
					m.global.enable_automatic_subtitles = false
					m.auto_subs_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
				'}
				end if
			'}
			else if m.item_selected = 2 or m.item_selected = 3
			'{
				channel_sort_type = m.item_selected - 2
				if ( channel_sort_type = 0 or channel_sort_type = 1 ) and channel_sort_type <> m.global.channel_sort_type
				'{
					if channel_sort_type = 0
					'{
						m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					else
					'{
						m.channel_sort_type_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.channel_sort_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					end if

					m.global.channel_sort_type = channel_sort_type
				'}
				end if
			'}
			else if m.item_selected = 4
			'{
				if m.global.resume_channel = false
				'{
					m.global.resume_channel = true
					m.resume_channel_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
				'}
				else
				'{
					m.global.resume_channel = false
					m.resume_channel_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
				'}
				end if
			'}
			else if m.item_selected = 5
			'{
				m.adjust_overscan.menu_state = 1
			'}
			end if
		'}
		else if key = "up"
		'{
			if m.item_selected = 2 or m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 1
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 4
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.channel_sort_type = 0
				'{
					m.item_selected = 2
				'}
				else
				'{
					m.item_selected = 3
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected > 0
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "down"
		'{
			if m.item_selected = 1
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.channel_sort_type = 0
				'{
					m.item_selected = 2
				'}
				else
				'{
					m.item_selected = 3
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 2 or m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 4
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected < m.options.Count() - 1
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "left"
		'{
			if m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "right"
		'{
			if m.item_selected = 2
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
