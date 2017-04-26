----- Loot Spec (Init) -----
local A = aura_env
local now

----- Set options here -----
local refreshRate = 5

----- Custom text -----
local customText = ""
local refreshInterval = 1 / refreshRate
local lastRefresh = -999

local AFFLICTION, DEMONOLOGY, DESTRUCTION = "Affliction", "Demonology", "Destruction"
local DEFAULT = DESTRUCTION
local flashColors = {"ff4242", "ffff00"}

local targetSpecs = {
}

local function makeCustomText()
    local lootSpecID = GetLootSpecialization()
    local _, name, icon, star
    if lootSpecID == 0 then
        local spec = GetSpecialization()
        _, name, _, icon = GetSpecializationInfo(spec)
        star = "*"
    else
        _, name, _, icon = GetSpecializationInfoByID(lootSpecID)
        star = ""
    end
    local intendedSpec = targetSpecs[UnitName("target")]
    if name and intendedSpec and name ~= intendedSpec then
        local t = 1 + floor(GetTime()) % 2
        star = star..string.rep(format("\n|cff%s!!! SHOULD BE %s !!!|r", flashColors[t], intendedSpec), 5)
    end
    return format("|T%s:0|t%s", icon, star)
end

local function doCustomText()
    now = GetTime()
    if now - lastRefresh > refreshInterval then
        customText = makeCustomText() or ""
        lastRefresh = now
    end
    return customText
end
A.doCustomText = doCustomText
