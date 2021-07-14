if SERVER then AddCSLuaFile( 'scoreboard_config.lua' ) end
include( 'scoreboard_config.lua' )

if !CLIENT then return end

local Elegant = nil
--local x, y = ScrW(), ScrH()

surface.CreateFont( "CarbonSBFont", { font = "Roboto", size = 35, weight = 800, antialias = true, bold = true } )
surface.CreateFont( "CarbonSBFontSmall", { font = "Roboto", size = 25, weight = 0, antialias = true, bold = true } )
surface.CreateFont( "CarbonSBFontUnder", { font = "Roboto", size = 17, weight = 0, antialias = true, bold = true } )
surface.CreateFont( "CarbonSBFontTiny", { font = "Roboto", size = 20, weight = 500, antialias = true, bold = true } )
surface.CreateFont( "CarbonSBFontMedium", { font = "Roboto", size = 30, weight = 500, antialias = true, bold = true } )
surface.CreateFont( "CarbonSBFontHeader", { font = "Roboto", size = 20, weight = 500, antialias = true, bold = true } )
-- Because it's being a pain in the ass, force set spacing if needed.

if ScrH() <= 720 then
    JobSpace = -83
    RankSpace = 60
    KillSpace = 150
    DeathSpace = 170
else
    JobSpace = 235
    RankSpace = 375
    KillSpace = 470
    DeathSpace = 490
end

local text = {
    { tag = 'Name', spacing = 0 },
    { tag = 'Job', spacing = JobSpace },
    { tag = 'Rank', spacing = RankSpace },
    { tag = 'Kills', spacing = KillSpace },
    { tag = 'Deaths', spacing = DeathSpace },
    { tag = 'Ping', spacing = 750 }
}

local function CanSee()
    if !Carbon_Score_Config.StaffGroups[ LocalPlayer():GetUserGroup() ] then
        return false
    end
    return true
end

local function GetNewX( self, x )
    if IsValid( self ) then
        if self.VBar.Enabled then x = x + 9 end
        return x
    end
end

local function DrawTextHeaders()
    for k, v in pairs( text ) do
        if k == 1 then
            CarbonDrawing.DrawText( v.tag, "CarbonSBFontHeader", 70, 80, Color( 255, 255, 255 ) )
        else
            CarbonDrawing.DrawText( v.tag, "CarbonSBFontHeader", 250 + ( 60 * k ) + v.spacing, 80, Color( 255, 255, 255 ) )
        end
    end
end

local function CreateSimpleButton( parent, x, y, txt, font, col, target, click, cusFunc )
    local self = vgui.Create( 'DButton', parent )
    self:SetPos( x, y )
    self:SetSize( 120, 40 )
    self:SetFont( font )
    self:SetText( txt )
    self:SetTextColor( col )
    --if click then self.DoClick = click end
    if !cusFunc then
        self.DoClick = function()
            -- Check the target is still on the server when executing
            if !IsValid( target ) then return end
            LocalPlayer():ConCommand( click )
        end
    else
        self.DoClick = cusFunc
    end
    self.OnCursorEntered = function( me, w, h ) self.Hover = true end
    self.OnCursorExited = function( me, w, h ) self.Hover = false end
    self.Paint = function( me, w, h )
        if self.Hover then
            CarbonDrawing.DrawRect( 0, 0, w, h, Color( 12, 12, 12, 100 ) )
        else
            CarbonDrawing.DrawRect( 0, 0, w, h, Color( 32, 32, 32, 200 ) )
        end
    end
    return self
end

local function TranslateGroup( x, c )
    if not c then
        if Carbon_Score_Config.Groups[ x ] then
            return Carbon_Score_Config.Groups[ x ].name
        else
            return 'User'
        end
    else
        if Carbon_Score_Config.Groups[ x ] then
            return Carbon_Score_Config.Groups[ x ].color
        else
            return Color( 255, 255, 255 )
        end
    end
end

local function ElegantCreateInspect( x )
    Inspect = vgui.Create( 'DFrame' )
    Inspect:SetSize( 400, 610 )
    Inspect:SetTitle( '' )
    Inspect:SetDraggable( false )
    Inspect:SetVisible( true )
    Inspect:ShowCloseButton( false )
    Inspect:Center()
    Inspect.Paint = function( me, w, h )
        if !IsValid( x ) then Inspect:Remove() return end
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 22, 22, 22 ) )
        CarbonDrawing.DrawRect( 5, 50, w - 10, 3, Color( 185,44,44, 255 ) ) -- Red line
        CarbonDrawing.DrawRect( 5, 5, w - 10, 3, Color( 185,44,44, 255 ) ) -- Red line

        CarbonDrawing.DrawRect( 5, 12, w - 10, 37, Color( 36, 36, 36, 230 ) )
        CarbonDrawing.DrawOutlinedRect( 0, 0, w, h, 4, Color( 0, 0, 0 ) )

        CarbonDrawing.DrawRect( 5, h / 2 + 110, w - 10, 3, Color( 178, 34, 34 ) )
        CarbonDrawing.DrawRect( 5, h / 2 + 50, w - 10, 3, Color( 178, 34, 34 ) )

        CarbonDrawing.DrawText( x:Nick(), "CarbonSBFontMedium", w / 2, 15, Color( 255, 255, 255 ) )
        CarbonDrawing.DrawText( TranslateGroup( x:GetUserGroup(), false ), "CarbonSBFontMedium", w / 2 - 5, 70, TranslateGroup( x:GetUserGroup(), true ) )
        CarbonDrawing.DrawText( x:SteamID(), "CarbonSBFontMedium", w / 2, h / 2 + 65, Color( 255, 255, 255 ) )
        CarbonDrawing.DrawText( 'Basic Commands', "CarbonSBFontMedium", w / 2, h / 2 + 125, Color( 255, 255, 255 ) )
    end

    local model = vgui.Create( 'DModelPanel', Inspect )
    model:SetSize( 210, 225 )
    model:SetPos( 90, 115 )
    model:SetModel( x:GetModel() )
    --model:SetAnimated(true)
    model:SetMouseInputEnabled( true )
    model:SetCamPos( Vector( 50, 0, 60 ) )
    function model:LayoutEntity( Entity ) return end
    local obj = baseclass.Get( 'DModelPanel' )
    model.Paint = function( me, w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 28, 28, 28, 200 ) )
        obj.Paint( me, w, h )
    end

    local steam_copy = vgui.Create( 'DImageButton', Inspect )
    steam_copy:SetPos( Inspect:GetWide() / 2 + 150, Inspect:GetTall() / 2 + 73 )
    steam_copy:SetSize( 16, 16 )
    steam_copy:SetIcon( 'icon16/paste_plain.png' )
    steam_copy.DoClick = function()
        if !IsValid( x ) then return end
        SetClipboardText( x:SteamID() )
        LocalPlayer():ChatPrint( x:Nick() .. "'s SteamID has been copied to your clipboard." )
    end

    CreateSimpleButton( Inspect, 15, Inspect:GetTall() / 2 + 175, 'Teleport To', 'CarbonSBFontTiny', Color( 255, 255, 255 ), x, 'ulx goto ' .. x:Nick() )
    CreateSimpleButton( Inspect, 140, Inspect:GetTall() / 2 + 175, 'Bring', 'CarbonSBFontTiny', Color( 255, 255, 255 ), x, 'ulx bring ' .. x:Nick() )
    CreateSimpleButton( Inspect, Inspect:GetWide() / 2 + 65, Inspect:GetTall() / 2 + 175, x.FreezeState and x.FreezeState or 'Freeze', 'CarbonSBFontTiny', Color( 255, 255, 255 ), x, nil, function( self )
        -- This way it saves their previous state, even if closed. I could make a table, but it's a waste of time.
        -- Concommands have their own checks server-side, so no issues with running these.
        if !x.Is_Frozen then
            x.FreezeState = 'Unfreeze'
            self:SetText( x.FreezeState )
            LocalPlayer():ConCommand( 'ulx freeze ' .. x:Nick() )
            x.Is_Frozen = true
        else
            x.FreezeState = 'Freeze'
            self:SetText( x.FreezeState )
            LocalPlayer():ConCommand( 'ulx unfreeze ' .. x:Nick() )
            x.Is_Frozen = false
        end
    end )
    CreateSimpleButton( Inspect, 80, Inspect:GetTall() / 2 + 225, x.JailState and x.JailState or 'Jail', 'CarbonSBFontTiny', Color( 255, 255, 255 ), x, nil, function( self )
        -- This way it saves their previous state, even if closed. I could make a table, but it's a waste of time.
        -- Concommands have their own checks server-side, so no issues with running these.
        if !x.Is_Jailed then
            x.JailState = 'Unjail'
            self:SetText( x.JailState )
            LocalPlayer():ConCommand( 'ulx jail ' .. x:Nick() )
            x.Is_Jailed = true
        else
            x.JailState = 'Jail'
            self:SetText( x.JailState )
            LocalPlayer():ConCommand( 'ulx unjail ' .. x:Nick() )
            x.Is_Jailed = false
        end
    end )
    CreateSimpleButton( Inspect, 210, Inspect:GetTall() / 2 + 225, 'Spectate', 'CarbonSBFontTiny', Color( 255, 255, 255 ), x, 'fspectate ' .. x:Nick() )
end

local function img(x, y, w, h, mat, color)
	if color then
		surface.SetDrawColor(color.r ,color.g ,color.b)
	else
		surface.SetDrawColor(r or 200,g or 251,b or 255) ---  THIS COLOR ICONS 
	end
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

local function ElegantCreateBase()
    Elegant = vgui.Create( 'DFrame' )
    Elegant:SetSize( ScrW() - 450, ScrH() - 300 )
    Elegant:SetTitle( '' )
    Elegant:SetDraggable( false )
    Elegant:SetVisible( true )
    Elegant:ShowCloseButton( false )
    Elegant:Center()
    gui.EnableScreenClicker( true )
    Elegant.Paint = function( me, w, h )
        CarbonDrawing.BlurMenu( me, 13, 20, 200 )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 8, 8, 8, 255 ) )
        CarbonDrawing.DrawRect( 0, 0, w, h / 2, Color( 14, 14, 14, 255 ) )
        CarbonDrawing.DrawRect( 10, 78, w - 20, 30, Color( 34, 34, 34, 255 ) )
        CarbonDrawing.DrawRect( 0, 0, w, 70, Color( 185, 58, 58, 255 ) )
        DrawTextHeaders()
        img( 3, 3, 64,64, carbonlogo, Color(255,255,255)) 
        CarbonDrawing.DrawText( #player.GetAll() == 1 and 'There is currently 1 person online.' or 'There are currently ' .. #player.GetAll() .. " players online.", "CarbonSBFontUnder", w / 2, h - 19, Color( 185,55,55, 255 ) )
        
    end

    local website = vgui.Create( 'DLabel', Elegant )
    website:SetPos( Elegant:GetWide() - 280, -37 )
    website:SetSize( 300, 150 )
    website:SetFont( "CarbonSBFont" )
    website:SetTextColor( Color( 225,225,225, 255 ) )
    website:SetText( Carbon_Score_Config.WebsiteLink )
    website:SetCursor( "hand" )
    website:SetMouseInputEnabled( true )
    website.OnMousePressed = function()
        gui.OpenURL( 'http://' .. Carbon_Score_Config.WebsiteLink )
    end

    Elegant.PlayerList = vgui.Create( "DPanelList", Elegant )
    Elegant.PlayerList:SetSize( Elegant:GetWide() - 20, Elegant:GetTall() - 130 )
    Elegant.PlayerList:SetPos( 10, 110 )
    Elegant.PlayerList:SetSpacing( 2 )
    Elegant.PlayerList:EnableVerticalScrollbar( true )
    --Elegant.PlayerList:SetStretchHorizontally( false )

    Elegant.PlayerList.Paint = function( me, w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 26, 26, 26, 200 ) )
    end

    local sbar = Elegant.PlayerList.VBar
    function sbar:Paint( w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 0, 0, 0, 100 ) )
    end
    function sbar.btnUp:Paint( w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 44, 44, 44 ) )
    end
    function sbar.btnDown:Paint( w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 44, 44, 44 ) )
    end
    function sbar.btnGrip:Paint( w, h )
        CarbonDrawing.DrawRect( 0, 0, w, h, Color( 56, 56, 56 ) )
    end

    for _, x in pairs( player.GetAll() ) do
        local item = vgui.Create( 'DPanel', Elegant.PlayerList )
        item:SetSize( Elegant.PlayerList:GetWide() - 70, 30 )
        local teamCol = team.GetColor( x:Team() )

        local self = Elegant.PlayerList
        local _y = 7

        item.Paint = function( me, w, h )
            if !IsValid( x ) then item:Remove() return end
            if _ % 2 == 0 then
                CarbonDrawing.DrawRect( 0, 0, w, h, Color( 44, 44, 44, 200 ) )
            else
                CarbonDrawing.DrawRect( 0, 0, w, h, Color( 32, 32, 32, 200 ) )
            end


            CarbonDrawing.DrawText( x:Nick(), "CarbonSBFontTiny", 40, 4, TranslateGroup( x:GetUserGroup(), true ), TEXT_ALIGN_LEFT )
            CarbonDrawing.DrawText( team.GetName( x:Team() ), "CarbonSBFontTiny", GetNewX( self, w / 2 - 148 ), 4, team.GetColor( x:Team() ), TEXT_ALIGN_LEFT )
            CarbonDrawing.DrawText( TranslateGroup( x:GetUserGroup(), false ), "CarbonSBFontTiny", GetNewX( self, w / 2 + 75 ), 3, TranslateGroup( x:GetUserGroup(), true ) )
            CarbonDrawing.DrawText( x:Frags() < 0 and 0 or x:Frags(), "CarbonSBFontTiny", GetNewX( self, w / 2 + 220 ), 4, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
            CarbonDrawing.DrawText( x:Deaths(), "CarbonSBFontTiny", GetNewX( self, w / 2 + 300 ), 4, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
            CarbonDrawing.DrawText( x:Ping(), "CarbonSBFontTiny", GetNewX( self, w - 100 ), 4, Color( 255, 255, 255 ) )

        end

        local bounds = vgui.Create( "DLabel", item )
        bounds:SetSize( item:GetWide() - 5, item:GetTall() )
        bounds:SetPos( 0, 0 )
        bounds:SetText( "" )
        bounds:SetMouseInputEnabled( true )

        bounds.DoDoubleClick = function()
            if !CanSee() then return end
            if IsValid( Inspect ) then
                Inspect:Remove()
            end
            ElegantCreateInspect( x )
        end

        local image = vgui.Create( "AvatarImage", item )
        image:SetSize( 28, 28 )
        image:SetPos( 1, 1 )
        image:SetPlayer( x, 64 )

        local mute = vgui.Create( "DImageButton", item )
        mute:SetSize( 16, 16 )
        mute:SetPos( GetNewX( self, item:GetWide() + 35 ), 7 )
        mute:SetImage( x:IsMuted() and 'materials/muted.png' or 'materials/unmuted.png' )

        mute.DoClick = function()
            if !x:IsMuted() then x:SetMuted( true ) else x:SetMuted( false ) end
            mute:SetImage( x:IsMuted() and 'materials/muted.png' or  'materials/unmuted.png')
        end

        Elegant.PlayerList:AddItem( item )
    end
end

local function ElegantHide()
    Elegant:SetVisible( false )
    gui.EnableScreenClicker( false )
end

hook.Add( 'ScoreboardShow', 'ELEGANT_CREATE_BOARD', function()
    ElegantCreateBase()
    return true
end )

hook.Add( 'ScoreboardHide', 'ELEGANT_REMOVE_BOARD', function()
    if IsValid( Elegant ) then ElegantHide() end
    if IsValid( Inspect ) then Inspect:Remove() end
    return true
end )
