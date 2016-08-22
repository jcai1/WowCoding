----- Loot Method (Init) -----
local A = aura_env
local now

----- Set options here -----
local refreshRate = 5
local methodStrings = {
    ["freeforall"] = "Free for All",
    ["group"] = "Group",
    ["master"] = "Master",
    ["personalloot"] = "Personal",
    ["roundrobin"] = "Round Robin",
}
local nonMasterColor = "ff4242"

----- Custom text -----
local customText = ""
local refreshInterval = 1 / refreshRate
local lastRefresh = -999

local function makeCustomText()
    if WeakAuras.IsOptionsOpen() then return "Loot: ----------" end
    local method, partyMaster, raidMaster = GetLootMethod()
    if not method then return end
    local methodString = methodStrings[method] or method
    if method == "master" then
        local masterLooter
        if partyMaster then
            masterLooter = UnitName(partyMaster == 0 and "player" or "party"..partyMaster)
        elseif raidMaster then
            masterLooter = UnitName("raid"..raidMaster)
        end
        return format("Loot: %s (%s)", methodString, tostring(masterLooter))
    else
        return format("Loot: |cff%s%s (!)|r", nonMasterColor, methodString)
    end
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

