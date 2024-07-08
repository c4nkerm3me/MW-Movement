gant = {}
gant.lay = {}
gant.lay.MaxLaySpeed = 40
gant.lay.ViewZ = 25
gant.lay.Hull = 24

if CLIENT then
    hook.Add("InitPostEntity","mwmt_loadcfg", function()
        gant.LP = LocalPlayer()
        gant.lay.CantGetUpText = "MWMT | There is no room to get up"
    end)

    hook.Add("ShouldDisableLegs", "GML::Support::Slide", function()
        if LocalPlayer():GetSliding() then return true end
    end)
end