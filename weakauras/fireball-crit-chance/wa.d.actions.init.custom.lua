----- Fireball Crit Chance -----
local A = aura_env
-- local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]

----- Set options here -----
local refreshRate = 60

----- Utility -----
local now
local refreshInterval = 1 / refreshRate
local lastRefresh     = -refreshInterval - 1
local customText

local function onRefresh()
    local baseCrit = GetSpellCritChance()
    local _, _, _, stacks = UnitBuff("player", "Enhanced Pyrotechnics")
    local crit = min(100, baseCrit + (stacks or 0) * 10)
    customText = format("%d", crit)
end

function A.doCustomText()
    now = GetTime()
    if now - lastRefresh >= refreshInterval then
        onRefresh()
        lastRefresh = now
    end
    return customText
end
