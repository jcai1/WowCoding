function()
    local A, t = aura_env, GetTime()
    local F = WeakAuras.regions[A.id].region
    
    if t - A.t < A.dt then
        return
    else
        A.t = t
    end
    
    local tf = F.topFG
    local tf2 = F.topFG2
    local bf = F.botFG
    local tt = F.topText
    local bt = F.botText
    -- local bt2 = F.botText2
    
    local T = A.timeScale
    local _, _, _, acStacks, _, _, acExpires = UnitDebuff("player", "Arcane Charge", nil, "PLAYER")
    local acRemain = (acExpires or t) - t
    local _, _, _, abCastLength = GetSpellInfo(30451)
    abCastLength = abCastLength * 0.001
    local castName, _, _, _, _, castEnd = UnitCastingInfo("player")
    local abCastRemain = (castName == "Arcane Blast") and (castEnd * 0.001 - t) or abCastLength
    
    local upd = A.updateBar
    upd(tf, abCastLength)
    upd(tf2, abCastLength - abCastRemain)
    upd(bf, acRemain)
    
    tt:SetText(format("%.1f", abCastLength))
    bt:SetText(format("%.1f", acRemain))
    -- bt2:SetText(acStacks or 0)
end
