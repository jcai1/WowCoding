function()
    local fns = WeakAuras.custom_funcs
    if not fns then return "no" end
    local t = GetTime()
    local A = aura_env
    if not A.init then
        A.display = ""
        A.dispLastUpdated = -math.huge
        A.queryInterval = 5
        A.lastQueried = {}
        A.history = {}
        A.lines = {}
        function A.cmpUsage(lhs, rhs)
            -- if lhs.prio and not rhs.prio then
            -- return true
            -- elseif rhs.prio and not lhs.prio then
            -- return false
            -- else
            return (lhs.usagePerSec > rhs.usagePerSec)
            -- end
        end
        A.init = true
    end
    
    local lastQueried, history = A.lastQueried, A.history
    
    local needsUpdate
    if t - A.dispLastUpdated > 1 then
        A.dispLastUpdated = t
        needsUpdate = true
    end
    
    for tag, fnList in pairs(fns) do
        for i, fn in ipairs(fnList) do
            local name = format("%s||%d", tag, i)
            history[name] = history[name] or {}
            local hist = history[name]
            lastQueried[name] = lastQueried[name] or (t - math.random() * A.queryInterval) -- Stagger calls to GetFunctionCPUUsage
            local usage, calls = 0, 0
            if t - lastQueried[name] > A.queryInterval then
                lastQueried[name] = t
                usage, calls = GetFunctionCPUUsage(fn, true)
                hist[t] = {name = name, usage = usage, calls = calls, prio = (name:sub(1, 1) == "^")}
            end
        end
    end
    
    if needsUpdate then
        local infoList = {}
        local lines = A.lines
        wipe(lines)
        for name, hist in pairs(history) do
            local usagePerSec, callsPerSec = 0, 0
            local t1, t2 = -math.huge, -math.huge
            for tt, _ in pairs(hist) do
                if tt > t1 then
                    t1 = tt
                elseif tt > t2 then
                    t2 = tt
                end
            end
            if t1 ~= t2 and t1 + t2 > -math.huge then
                usagePerSec = (hist[t1].usage - hist[t2].usage) / (t1 - t2)
                callsPerSec = (hist[t1].calls - hist[t2].calls) / (t1 - t2)
            end
            table.insert(infoList, {name = name, usagePerSec = usagePerSec, callsPerSec = callsPerSec})
        end
        table.sort(infoList, A.cmpUsage)
        for i = 1, math.min(8, #infoList) do
            local info = infoList[i]
            local x1, x2 = info.usagePerSec, info.callsPerSec
            local s1, s2, s3
            s1 = (x2 == 0 and "???" or format("%.2f", x1 / x2 * 1000))
            s2 = format("%.3f", x1 / 10)
            s3 = format("%.1f", x2)
            lines[i] = format("%35s: %5s us/call | %5s%%%% | %5s calls/s\n", info.name, s1, s2, s3)
        end
        A.display = table.concat(lines)
    end
    
    return A.display
end
