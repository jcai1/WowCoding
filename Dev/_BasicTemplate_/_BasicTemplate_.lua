----- _NAME_HERE_ (Init) -----
local A = aura_env
-- local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]
local now
local playerGUID = UnitGUID("player")

----- Set options here -----
local refreshRate = 10

----- Custom text -----
local refreshInterval = 1 / refreshRate
local lastRefresh = -999
local customText

local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,
	destGUID, destName, destFlags, _, spellID, spellName, _, ...)
	-- _CODE_HERE_
end

local function onRefresh()
	-- _CODE_HERE_
end

local function doCustomText()
	now = GetTime()
	if now - lastRefresh > refreshInterval then
		onRefresh()
		lastRefresh = now
	end
	return customText
end
A.doCustomText = doCustomText

local triggerDispatch = {
	["COMBAT_LOG_EVENT_UNFILTERED"] = onCombatEvent,
}
local function doTrigger(event, ...)
	now = GetTime()
	triggerDispatch[event](...)
	return true
end
A.doTrigger = doTrigger
