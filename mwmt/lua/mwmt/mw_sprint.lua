local meta = FindMetaTable("Player")

local twohanded_table = {}
local onehanded_table = {}

local mult_table = {
    ["Submachine Guns"] = 1.15,
    ["Pistols"] = 1.15,
    ["Assault Rifles"] = 1,
    ["mg_mike57"] = 1,
    ["mg_delta"] = 1,
    ["Shotguns"] = 1,
    ["Sniper Rifles"] = 0.85,
    ["Specials"] = 0.75,
    ["Launchers"] = 0.85,
    ["Lightmachine Guns"] = 0.85,
}

function meta:GetSprinting()
    return self:GetNW2Bool("IsSprinting",false)
end

function meta:SetSprinting(b)
    if b then self:SetNW2Float("Sprinting_Start_Time",CurTime()) end
    return self:SetNW2Bool("IsSprinting",b)
end

function meta:GetSprintMult(ply)
    if !ply:Alive() then return 1 end

    local wep = ply:GetActiveWeapon()
    if wep then
        local sprint_mult = (mult_table[wep:GetClass()] or mult_table[wep.SubCategory]) or 1.25
        return weapons.IsBasedOn(wep:GetClass(), "mg_base") and sprint_mult or 1
    end
end

if CLIENT then
    local sprint_bindkey = CreateClientConVar("mwmt_sprint_bindkey",79,true,false,"Use SpawnMenu > Options > [MWMT] Settings to change the bind!")
    local is_doubletap = CreateClientConVar("mwmt_sprint_doubletap",1,true,false)
    local is_anim_played = false
    local last_request, resettime = 0, false
    local was_pressed, doubletap = false, true
    local ease, tvec = TWEEN_EASE_EXPO_OUT, Vector(-1.5,-5,-14)
    local tang = 3
    local tang2 = 0
    local tang3 = 60
    local t, t2, t3, tx, ty, tz = Tween(0, tang3, 0.5, ease), Tween(0, tang, 0.5, ease), Tween(0, tang2, 0.5, ease), Tween(0, tvec.x, 0.5, ease), Tween(0, tvec.y, 0.5, ease), Tween(0, tvec.z, 0.5, ease)

    twohanded_table = {"mg_sbeta","mg_acharlied","mg_ngsierra","mg_tsierra12","mg_romeo700",
    "Sniper Rifles", "mg_kilo98", "mg_mike26", "mg_romeo870", "mg_dblmg"}
    onehanded_table = {"mg_delta"}

    local vec_table = {["mg_lima86"] = Vector(-3,-5,-10), ["mg_akilo47"] = Vector(0,-5,-10), ["mg_akilo545"] = Vector(0,-3,-10), ["mg_akilo762"] = Vector(0,-3,-10),
    ["mg_mike4"] = Vector(-1.5,-3,-10), ["mg_mike4miiw"] = Vector(-2,0,-15), ["mg_ngsierra"] = Vector(0,-10,-22), ["mg_tango21"] = Vector(-3,-3,-11), ["mg_tango21_mw3"] = Vector(-3,-3,-11),
    ["mg_mcharlie"] = Vector(-1.5,-5,-11), ["mg_kilo433"] = Vector(-3,-3,-10), ["mg_mcharlie_b"] = Vector(-1.5,-1.5,-11), ["mg_asierra12"] = Vector(-2,-5,-9), ["mg_aromeo200"] = Vector(-3,-4,-11),
    ["mg_sierra552"] = Vector(-3,-3,-10), ["mg_g3a3"] = Vector(-3,-3,-13), ["mg_falpha"] = Vector(-3,-4,-10), ["mg_scharlie"] = Vector(-3,-3,-11), ["mg_falima"] = Vector(-3,-4,-9), ["mg_galima"] = Vector(-4,-3,-10),
    ["mg_chimera"] =  Vector(-3,-4,-11), ["mg_mcbravo"] =  Vector(-1.5,-1.5,-13), ["mg_balpha27"] = Vector(-3,-3,-11), ["mg_valpha"] = Vector(-3,-3,-10), ["mg_anovember94"] = Vector(-5,-2,-10),
    ["mg_sbeta"] = Vector(1,-1.5,-13), ["mg_sksierra"] = Vector(-5,-2,-12), ["mg_acharlied"] = Vector(0,-8,-18), ["mg_kilo98"] = Vector(0,-2,-16), ["mg_mike14"] = Vector(-3,-3,-10), ["mg_crossbow"] = Vector(-5,-7,-13),
    ["mg_mike25"] = Vector(-5,-3,-12), ["mg_pcharlie9"] = Vector(-5,-3,-13), ["mg_taq_555"] = Vector(-1.5,-1.5,-11), ["mg_mike2011"] = Vector(-5.5,-10,-9), ["mg_swhiskey"] = Vector(-1.5,-4,-18),
    ["mg_mw2deagle"] = Vector(-3,-5,-18), ["mg_mpapa5"] = Vector(-5,-3,-12), ["mg_secho"] = Vector(-1.5,-5,-10), ["mg_mpapax"] = Vector(-4,0,-10), ["mg_augolf"] = Vector(-4,-5,-13), 
    ["mg_mwiip220"] = Vector(-6,-3,-8), ["mg_delta"] = Vector(-3,-3,-11), ["mg_dpapa12"] = Vector(-5,-5,-6), ["mg_mike26"] = Vector(-1,-5,-10), ["mg_romeo870"] = Vector(-2,-5,-12),
    ["mg_charlie725"] = Vector(0,-2,-10), ["mg_charlie725_1"] = Vector(0,-3,-11), ["mg_aalpha12"] = Vector(-2,-5,-7), ["mg_xmike5"] = Vector(-1.5,-3,-16), ["mg_foxtrot2000"] = Vector(-3,-3,-11)}

    local ang_table = {["mg_mike4miiw"] = {16,-12}, ["mg_mike2011"] = {30,10,30}, ["mg_sbeta"] = {-32}, ["mg_kilo98"] = {-32}, ["mg_mpapax"] = {16,-12,45}, ["mg_mwiip220"] = {20,-10,30}}

    function sprinting_request(force)
        local walkspeed = gant.LP:GetWalkSpeed()
        local is_force = force || false
        local b = !gant.LP:GetSprinting() 
        if is_force != true && !b then return end
        if (gant.LP:GetSliding()) && b == true then return end
        net.Start("sprint_netrowrking")
        net.WriteBool(b)
        net.SendToServer()
    end

    hook.Add( "StartCommand", "sprint_move", function( ply, mv )
        local running = mv:KeyDown(IN_SPEED)
        local walking = mv:KeyDown(IN_FORWARD)
        local jump = mv:KeyDown(IN_JUMP)
        local wep = ply:GetActiveWeapon() || ply

        if ply:OnGround() && ply:GetMoveType() != MOVETYPE_NOCLIP && !vgui.GetKeyboardFocus() && !gui.IsGameUIVisible() && !gui.IsConsoleVisible() && system.HasFocus() && !mv:KeyDown(IN_BACK) || system.IsLinux() then 
            if input.IsKeyDown(sprint_bindkey:GetInt()) then 
                was_pressed = true
                resettime = CurTime() + .22
            else 
                if was_pressed then 
                    if last_request < CurTime() then
                        doubletap = !doubletap
                        if !is_doubletap:GetBool() || doubletap then
                            sprinting_request() 
                        end
                    end
                end 

                was_pressed = false
            end

            if resettime ~= false && resettime < CurTime() then
                resettime = false
                doubletap = true
            end
        end

        if VManip then
            if !ply:GetSprinting() then
                VManip:QuitHolding("sprint_anim") is_anim_played = false 
            end
        end

        if (!running || !walking || jump || ply:GetMoveType() == MOVETYPE_NOCLIP || !ply:Alive() || ply:GetSliding() || ply:IsProne()) && ply:GetSprinting() then sprinting_request(true) is_anim_played = false end
    end)

    hook.Add("StartCommand", "sprint_cmd", function(ply, cmd)
        if ply:GetSprinting() then cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_SPEED)) end
    end)

    hook.Add("EntityNetworkedVarChanged","sprint_nw_changed", function(ent,name,old,b) 
        if name == "IsSprinting" && ent == gant.LP then 
            if b then t = Tween(0, tang3, 0.5, ease) t2 = Tween(0, tang, 0.5, ease) t3 = Tween(0, tang2, 0.5, ease)
                tx = Tween(0, tvec.x, 0.5, ease) ty = Tween(0, tvec.y, 0.5, ease) tz = Tween(0, tvec.z, 0.5, ease)
            else t = Tween(t:GetValue(), 0, 0.5, ease) t2 = Tween(t2:GetValue(), 0, 0.5, ease) t3 = Tween(t3:GetValue(), 0, 0.5, ease)
                tx = Tween(tx:GetValue(), 0, 0.5, ease) ty = Tween(ty:GetValue(), 0, 0.5, ease) tz = Tween(tz:GetValue(), 0, 0.5, ease) 
            end t:Start() t2:Start() t3:Start() tx:Start() ty:Start() tz:Start()
        end 
    end)
    
    hook.Add( "CalcViewModelView", "sprint_calcvm", function(wep,vm,opos,oang,pos,ang)
        tvec = vec_table[wep:GetClass()] or Vector(-1.5,-5,-14)
        tang = ang_table[wep:GetClass()] and ang_table[wep:GetClass()][1] or 3
        tang2 = ang_table[wep:GetClass()] and ang_table[wep:GetClass()][2] or 0
        tang3 = ang_table[wep:GetClass()] and ang_table[wep:GetClass()][3] or 60

        if (!gant.LP:GetSprinting()) && t:GetValue() == 0 && tx:GetValue() == 0 then return end
        if !weapons.IsBasedOn(wep:GetClass(), "mg_base") or wep.SubCategory == "Melee" then return end

        if (!table.HasValue(twohanded_table, wep:GetClass()) and !table.HasValue(twohanded_table, wep.SubCategory)) or table.HasValue(onehanded_table, wep:GetClass()) then
            if VManip then if VManip:GetCurrentAnim() != "sprint_anim" then VManip:PlayAnim("sprint_anim") end end
        end
        if (vm:GetSequence() != vm:LookupSequence"idle" || vm:GetSequence() != vm:LookupSequence"reference") then vm:SetSequence("idle") end
        if !is_anim_played then vm:SetSequence("sprint_loop") vm:SetSequence("idle") is_anim_played = true end

        local off = Vector(tx:GetValue(),ty:GetValue(),tz:GetValue()) off:Rotate(ang)
        ang:RotateAroundAxis(ang:Right(),t:GetValue()) ang:RotateAroundAxis(ang:Forward(),t2:GetValue()) ang:RotateAroundAxis(ang:Up(),t3:GetValue())
        return pos + off, ang
    end)

    concommand.Add("mwmt_sprint",sprinting_request)
else
    util.AddNetworkString("sprint_netrowrking")
    local s_enabled = CreateConVar("mwmt_sprint_enabled", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    local s_duration = CreateConVar("mwmt_sprint_duration", 3, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    local s_refresh = CreateConVar("mwmt_sprint_refresh_time", 5, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    
    net.Receive("sprint_netrowrking", function(len,ply)
        local b = net.ReadBool()
        local start_time = CurTime()
        
        if !b then ply:SetNW2Float("Sprinting_LastUseTime",CurTime()-(s_refresh:GetFloat()-0.7)) end
        if ((math.abs(start_time-ply:GetNW2Float("Sprinting_LastUseTime",0)) <= s_refresh:GetFloat())) || !s_enabled:GetBool() then ply:SetSprinting(false) return end
        ply:SetSprinting(b)
    end)

    hook.Add( "SetupMove", "sprint_move", function( ply, mv, cmd )
        if ply:GetSprinting() then ply:SetRunSpeed(GetConVar("mwmt_run_speed"):GetFloat()+100) end
        if !ply:GetSprinting() then return end
        local start_time, time_of_sprinting = ply:GetNW2Float("Sprinting_Start_Time",0), math.abs(ply:GetNW2Float("Sprinting_Start_Time",0)-CurTime())

        if mv:KeyDown(IN_DUCK) then
            ply:SetSprinting(false)
            ply:SetNW2Float("Sprinting_LastUseTime",CurTime()-(s_refresh:GetFloat()-0.7))
        end

        if time_of_sprinting >= s_duration:GetFloat() then
            ply:SetSprinting(false)
            ply:SetNW2Float("Sprinting_LastUseTime",CurTime())
        end
    end)
end