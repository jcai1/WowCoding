local A = aura_env
local R = WeakAuras.regions[A.id].region

R.customText = ""

local function colorLatency(x)
    if not x then
        return "??"
    elseif x < 100 then
        return format("|cff00ff00%d|r", x) -- less than 100 ms = green
    elseif x < 300 then
        return format("|cffffff00%d|r", x) -- 100-300 ms = yellow
    else
        return format("|cffff0000%d|r", x) -- more than 300 ms = red
    end
end

local function refresh()
    local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
    R.customText = colorLatency(latencyHome).." / "..colorLatency(latencyWorld)
end

function A.customTextFunc()
    return R.customText
end

R.ticker = R.ticker or C_Timer.NewTicker(30, refresh)
