function()
    local A, t = aura_env, GetTime()
    if A.aborted then return end
    
    if t - A.t2 >= A.dt2 then
        A.refreshRaid()
        A.t2 = t
    end
    
    if t - A.t1 >= A.dt1 then
        A.refreshDisplay()
        A.t1 = t
    end
    
    return A.display
end