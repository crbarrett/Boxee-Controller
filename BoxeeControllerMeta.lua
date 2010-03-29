--[[
=head1 NAME

applets.boxee - "Boxee Time" 

=head1 DESCRIPTION

Remotely Control the Boxee User Interface

=head1 FUNCTIONS

=cut
--]]

local oo            = require("loop.simple")
local AppletMeta    = require("jive.AppletMeta")
local appletManager = appletManager
local jiveMain      = jiveMain
 
module(...)
oo.class(_M, AppletMeta)
  
function jiveVersion(meta)
    return 1, 1
end
 
function defaultSettings(meta)
    return {
        currentServer = false,
    }
end
 
function registerApplet(meta)
    jiveMain:addItem(meta:menuItem('boxeeApplet', 'extras', "BOXEE", function(applet, ...) applet:boxee(...) end, 50))
end
--[[

=head1 LICENSE

Copyright 2010 Chris Barrett. All Rights Reserved.

=cut
--]]

