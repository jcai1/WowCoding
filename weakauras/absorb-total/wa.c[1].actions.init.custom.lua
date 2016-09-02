----- Absorb Total -----
local A = aura_env
-- local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]

----- Set options here -----
local refreshRate = 20

----- Utility -----
local now
local refreshInterval = 1 / refreshRate
local lastRefresh     = -refreshInterval - 1
local customText
local shouldShow      = true
local isOptionsOpen   = WeakAuras.IsOptionsOpen
-- local playerGUID      = UnitGUID("player")

-- round an integer to about 3 significant figures with suffix, e.g. 24.5k
local kSuffixes = {"k", "m", "b", "t", "q"}
local function intToString3(x)
    if x < x then
        return "NaN"
    elseif x == math.huge then
        return "+Inf"
    elseif x == -math.huge then
        return "-Inf"
    elseif x < 0 then
        return "-"..intToString3(-x)
    elseif x < 10000 then
        return format("%.f", x)
    else
        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false
        while true do
            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then
                return format("%."..(2-subcount).."f", x / div)..kSuffixes[count]
            end
            subcount = subcount + 1
            cap = cap * 10
            if subcount == 3 then
                subcount = 0
                count = count + 1
                div = div * 1000
            end
        end
    end
end

local function onRefresh()
    local amt = UnitGetTotalAbsorbs("player")
    if amt == 0 then
        if isOptionsOpen() then
            customText = "999k"
        else
            customText = ""
        end
    else
        customText = intToString3(amt)
    end
end

local function doCustomText()
    now = GetTime()
    if now - lastRefresh >= refreshInterval then
        onRefresh()
        lastRefresh = now
    end
    return customText
end
A.doCustomText = doCustomText
