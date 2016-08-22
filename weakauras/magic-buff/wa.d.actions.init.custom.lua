local A = aura_env
local refreshInterval = 0.05
local lastRefresh = -999
local shouldShow
local now

local function refresh()
    if not UnitCanAttack("player", "target") then return end
    for i = 1, 50 do
        local name, _, texture, count, debuffType, duration, expirationTime = UnitBuff("target", i)
        if not name then break end
        if debuffType == "Magic" then
            A.name, A.texture, A.count, A.duration, A.expirationTime = name, texture, count, duration, expirationTime
            return true
        end
    end
end

function A.trigger()
    now = GetTime()
    if now - lastRefresh > refreshInterval then
        shouldShow = refresh()
        lastRefresh = now
    end
    return shouldShow
end