function()
    local A, t = aura_env, GetTime()
    if t - A.t2 > 1 then
        A.t2 = t
        A.updateRing()
    end
    return true
end
