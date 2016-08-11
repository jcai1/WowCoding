----- Loot Spec (Init) -----
local A = aura_env
local now

----- Set options here -----
local refreshRate = 5

----- Custom text -----
local customText = ""
local refreshInterval = 1 / refreshRate
local lastRefresh = -999

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
	return format("Loot: |T%s:0|t %s%s", icon, name, star)
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
