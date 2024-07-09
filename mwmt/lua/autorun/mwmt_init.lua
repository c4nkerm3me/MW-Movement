-- Initial file

hook.Add("Initialize", "mwmt_INIT", function()
    if SERVER then
		AddCSLuaFile("mwmt/config.lua")
        AddCSLuaFile("mwmt/tween.lua")
        AddCSLuaFile("mwmt/mw_movement.lua")
        AddCSLuaFile("mwmt/mw_laying.lua")
        AddCSLuaFile("mwmt/mw_sprint.lua")
	end

    include("mwmt/config.lua")
    include("mwmt/tween.lua")
    include("mwmt/mw_movement.lua")
    include("mwmt/mw_laying.lua")
    include("mwmt/mw_sprint.lua")

	print("[MWMT] MW19 Movement loaded!")
end)

if CLIENT then
    hook.Add("InitPostEntity", "mwmt_INIT", function()
        if VManip then
            VManip:RegisterAnim("sprint_anim", {["model"]="test.mdl",["lerp_peak"]=0.4,["lerp_speed_in"]=1,["lerp_speed_out"]=2,["lerp_curve"]=1,["holdtime"]=0.25,["speed"]=1})
        end
    end)

    hook.Add("PopulateToolMenu", "mwmt_options_MENU", function()
		spawnmenu.AddToolMenuOption("Options", "[MWMT] Settings", "mwmt_opts", "Controls", "", "", function(panel)
			panel:SetName("Controls")
			panel:AddControl("Header", {
				Text = "",
				Description = "MW2019 Movement addon settings"
			})

			panel:AddControl("Checkbox", {
				Label = "Double-tap to lay",
				Command = "mwmt_laying_doubletap"
			})

            panel:AddControl("Checkbox", {
				Label = "Double-tap to tactical sprint",
				Command = "mwmt_sprint_doubletap"
			})

			panel:AddControl("Numpad", {
				Label = "(Lay) Bind-key",
				Command = "mwmt_laying_bindkey"
			})

            panel:AddControl("Numpad", {
				Label = "(Tactical sprint) Bind-key",
				Command = "mwmt_sprint_bindkey"
			})
		end)

		spawnmenu.AddToolMenuOption("Options", "[MWMT] Settings", "mwmt_opts_server", "Server", "", "", function(panel)
			panel:SetName("Server")
			panel:AddControl("slider", {
				Label = "Walk speed",
				Command = "mwmt_walk_speed",
				min = 1,
				max = 1000
			})

			panel:AddControl("slider", {
				Label = "Run speed",
				Command = "mwmt_run_speed",
				min = 1,
				max = 1000
			})

			panel:AddControl("slider", {
				type = "float",
				Label = "Crouch speed",
				Command = "mwmt_crouch_speed",
				min = 0,
				max = 1000
			})

			panel:AddControl("slider", {
				Label = "Jump power",
				Command = "mwmt_jump_power",
				min = 1,
				max = 1000
			})

			panel:AddControl("Checkbox", {
				Label = "Enable Tactical Sprint",
				Command = "mwmt_sprint_enabled"
			})

			panel:AddControl("Checkbox", {
				Label = "Enable Lay",
				Command = "mwmt_laying_enabled"
			})

			panel:AddControl("Checkbox", {
				Label = "Enable crouch-jump",
				Command = "mwmt_crouch_jump",
			})
		end)

		spawnmenu.AddToolMenuOption("Options", "[MWMT] Settings", "mwmt_opts_sprint", "Sprint", "", "", function(panel)
			panel:SetName("Sprint")
			panel:AddControl("slider", {
				type = "float",
				Label = "Sprint duration",
				Command = "mwmt_sprint_duration"
			})

            panel:AddControl("slider", {
				type = "float",
				Label = "Sprint refresh time",
				Command = "mwmt_sprint_refresh_time"
			})
		end)
	end)
end
