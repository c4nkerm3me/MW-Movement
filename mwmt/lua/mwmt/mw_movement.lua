local cj_enabled = CreateConVar("mwmt_crouch_jump", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

if SERVER then
    local w_speed = CreateConVar("mwmt_walk_speed", 150, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    local r_speed = CreateConVar("mwmt_run_speed", 300, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    local c_speed = CreateConVar("mwmt_crouch_speed", 0.2, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
    local j_power = CreateConVar("mwmt_jump_power", 150, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

    hook.Add( "SetupMove", "movement_move_server", function( ply, mv, cmd )
        local running = mv:KeyDown(IN_SPEED)
        local walking = mv:KeyDown(IN_FORWARD)

        if running && walking then 
            ply:SetNW2Int("Jumping_Combo", 0) 
        end

        if (mv:KeyDown(IN_BACK) || mv:KeyDown(IN_MOVELEFT) || mv:KeyDown(IN_MOVERIGHT)) && !mv:KeyDown(IN_FORWARD) then 
            ply:SprintDisable() 
        else 
            ply:SprintEnable() 
        end
        
        if !ply:GetSprinting() then 
            ply:SetRunSpeed(r_speed:GetFloat()) 
        end

        ply:SetDuckSpeed(c_speed:GetFloat())
        ply:SetUnDuckSpeed(c_speed:GetFloat()+0.05)
        ply:SetWalkSpeed(w_speed:GetFloat())
        ply:SetJumpPower(j_power:GetFloat())
    end)
end