    Carbon_Score_Config = Carbon_Score_Config or {}

    Carbon_Score_Config.ServerName = 'Carbon Networks DarkRP' -- The name displayed on top of the scoreboard.
    Carbon_Score_Config.WebsiteLink = 'CarbonNetworks.net' -- The link to your website. Don't put https or http. Just the bare link such as www.cornhub.com

    Carbon_Score_Config.Groups = { -- Rank Configuration
        [ 'superadmin' ] = { name = 'Super Administrator', color = Color( 199, 44, 44 ) },
        [ 'developer' ] = { name = 'Developer', color = Color( 199, 44, 44 ) },
        [ 'admin' ] = { name = 'Administrator', color = Color( 241, 196, 15 ) },
        [ 'moderator' ] = { name = 'Moderator', color = Color( 52, 152, 219 ) },
        [ 'donator' ] = { name = 'Donator', color = Color( 155, 89, 182 ) },
        [ 'vip' ] = { name = 'VIP', color = Color( 155, 89, 182 ) }
    }

    Carbon_Score_Config.StaffGroups = { -- Who can see the command menu? - For now this only works with ULX cause fuck you 
        [ 'superadmin' ] = true,
        [ 'admin' ] = true,
        [ 'moderator' ] = true,
        [ 'developer' ] = true
    }

    local carbonlogo = Material("materials/logotransparent.png") -- The Logo 
    local muted = Material("materials/muted.png") -- If you really want to change this go ahead
    local unmuted = Material("materials/unmuted.png")
