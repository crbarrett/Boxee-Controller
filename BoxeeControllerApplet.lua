--[[
=head1 NAME

applets.Boxee - "Boxee" 

=head1 DESCRIPTION

Remotely Control Boxee User Interface

=head1 FUNCTIONS

Action Commands -> http://192.168.100.100:8800/xbmcCmds/xbmcHttp/?command=Action(<command>)
http://trac.xbmc.org/browser/branches/linuxport/XBMC/guilib/Key.h?rev=16176
#define ACTION_NONE                    0
#define ACTION_MOVE_LEFT               1
#define ACTION_MOVE_RIGHT              2
#define ACTION_MOVE_UP                 3
#define ACTION_MOVE_DOWN               4
#define ACTION_PAGE_UP                 5
#define ACTION_PAGE_DOWN               6
#define ACTION_SELECT_ITEM             7
#define ACTION_HIGHLIGHT_ITEM          8

Exit Boxee -> http://192.168.100.100:8800/xbmcCmds/xbmcHttp/?command=Exit()
Get Currently Playing -> http://192.168.100.100:8800/xbmcCmds/xbmcHttp/?command=getCurrentlyPlaying()
<html> 
<li>Filename:C:\Users\Public\Videos\dexter\Dexter.S01E11.HDTV.XviD-LOL.avi
<li>PlayStatus:Playing
<li>VideoNo:-1
<li>Type:Video
<li>Show Title:Dexter
<li>Title:Truth Be Told
<li>Director:Keith Gordon
<li>Plotoutline:The Ice Truck Killer puts Dexter in a life changing position when he takes someone close to Dexter hostage. Doakes begins to suspect that Dexter's odd behavior is something darker than he originally thought.
<li>Plot:The Ice Truck Killer puts Dexter in a life changing position when he takes someone close to Dexter hostage. Doakes begins to suspect that Dexter's odd behavior is something darker than he originally thought.
<li>Rating:9.0 ( votes)
<li>Year:2006
<li>Season:1
<li>Episode:11
<li>Thumb:special://masterprofile/profiles/chrisrbarrett/Thumbnails/Video/d/auto-d42f2f3a.tbn
<li>Time:00:12
<li>Duration:53:01
<li>Percentage:0
<li>File size:367144960
<li>Changed:True</html> 

Changing Output types 
http://xbox/xbmcCmds/xbmcHttp?command=setresponseformat(webheader;false;webfooter;false;header;<xml>;footer;</xml>;opentag;<tag>;closetag;</tag>;closefinaltag;true)

Output of getCurrentlyPlaying changes to;
<xml><tag>Filename:C:\Users\Public\Videos\dexter\Dexter.S01E11.HDTV.XviD-LOL.avi</tag><tag>PlayStatus:Playing</tag><tag>VideoNo:-1</tag><tag>Type:Video</tag><tag>Show Title:Dexter</tag><tag>Title:Truth Be Told</tag><tag>Director:Keith Gordon</tag><tag>Plotoutline:The Ice Truck Killer puts Dexter in a life changing position when he takes someone close to Dexter hostage. Doakes begins to suspect that Dexter's odd behavior is something darker than he originally thought.</tag><tag>Plot:The Ice Truck Killer puts Dexter in a life changing position when he takes someone close to Dexter hostage. Doakes begins to suspect that Dexter's odd behavior is something darker than he originally thought.</tag><tag>Rating:9.0 ( votes)</tag><tag>Year:2006</tag><tag>Season:1</tag><tag>Episode:11</tag><tag>Thumb:special://masterprofile/profiles/chrisrbarrett/Thumbnails/Video/d/auto-d42f2f3a.tbn</tag><tag>Time:00:07</tag><tag>Duration:53:01</tag><tag>Percentage:0</tag><tag>File size:367144960</tag><tag>Changed:True</tag></xml>

=cut
--]]

-- stuff we use
local tostring = tostring
local oo                     = require("loop.simple")
local string                 = require("string")

local Applet                 = require("jive.Applet")
local RadioButton            = require("jive.ui.RadioButton")
local Group                  = require("jive.ui.Group")
local RadioGroup             = require("jive.ui.RadioGroup")
local Window                 = require("jive.ui.Window")
local Popup                  = require("jive.ui.Popup")
local Textarea               = require('jive.ui.Textarea')
local SimpleMenu             = require("jive.ui.SimpleMenu")

local SocketHttp             = require("jive.net.SocketHttp")
local RequestHttp            = require("jive.net.RequestHttp")
local jnt                    = jnt

module(...)
oo.class(_M, Applet)
 
local SERVER		= '192.168.100.100'
local PORT			= 8800

local USER          = 'boxee'
local PASSWORD		= 'boxee'

-- SendKey commands for Keyboards use 0xf000 + ASCII_CODE in hex
local COMMANDS      = { 'SendKey(0xf01b)', 'SendKey(0xf00d)', 'SendKey(270)', 'SendKey(271)', 'SendKey(272)', 'SendKey(273)', 'SendKey(274)', 'Pause', 'Stop' }

local BASE_URL      = 'http://' .. SERVER .. ':' .. PORT .. '/xbmcCmds/xbmcHttp?command='


function boxee(self, menuItem)
	log:info("boxee")
	local currentServer = self:getSettings().currentServer

	-- create a SimpleMenu object with selections to be created
	local menu = SimpleMenu("menu")

    -- loop through all available commands to create menu items	
	local items = {}
	for i=1,#COMMANDS do
		items[#items + 1] = { 
							text = self:string(COMMANDS[i]), 
							url = COMMANDS[i],
							sound = "WINDOWSHOW",
							callback = function(event, menuItem)
								boxeeRequest(self, BASE_URL .. menuItem.url, PORT, nil, nil)		
							end, 
							}
	end	

	menu:setItems(items)	  

	-- create a window object
	local window = Window("window", self:string("BOXEE")) 

	-- add the SimpleMenu to the window
	window:addWidget(menu)

	-- show the window
	window:show()
end

function boxeeRequest(self, url, port, callback, menu)
	log:info("fetching boxee data from server: ", url)

	local response = {}
	local req = RequestHttp(
		function(chunk, err)
			if err then
				log:error("error fetching boxee data from server: ", err)
			end
			if chunk then
				log:info("fetched boxee data from server: ", chunk)
				if (callback) then		
					callback(self, chunk, menu)
				end
			end
		end,
		'GET',
		url
	)

	local uri  = req:getURI()
	local http = SocketHttp(jnt, uri.host, uri.port, uri.host)

    http:setCredentials({ ipport = { SERVER, PORT }, realm = 'Basic', username = USER, password = PASSWORD })
	http:fetch(req)
end

--[[
Notes

=head1 LICENSE

Copyright 2010 Chris Barrett. All Rights Reserved.

=cut
--]]
