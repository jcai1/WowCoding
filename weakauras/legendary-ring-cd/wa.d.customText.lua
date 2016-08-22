function()
    local A, t = aura_env, GetTime()
    if not A.currRing then
        return
    end
    local start, dur = GetItemCooldown(A.currRing)
    if dur == 0 then
        return "|cff00ff00RDY|r"
    else
        local s = t - start
        if UnitBuff("player", A.currRingName) then
            if t - A.t1 > 60 then
                A.t1 = t
                A.playSound()
            end
            local u = math.ceil(15 - s)
            return string.format("|cff%s%d|r", (u>5 and "ffff00" or "ff0000"), u)
        else
            local u = math.ceil(dur - s)
            local v = (u >= 60 and string.format("1:%02d", u - 60) or tostring(u))
            return string.format("|cff%s%s|r", (u>10 and "ffffff" or "00ff00"), v)
        end
    end
    
end




