----- WeakAura Name (Init) -----
local A = aura_env
local R = WeakAuras.regions[A.id].region
local S = WeakAurasSaved.displays[A.id]

----- Set options here -----


----- Utility -----
local t  -- Current value of GetTime()
local playerGUID = UnitGUID("player")


-- Runs on event COMBAT_LOG_EVENT_UNFILTERED
local function onCombatEvent(_, subEvent, _,
	sourceGUID, sourceName, sourceFlags, _,
	destGUID, destName, destFlags, _, ...)
end

local function onUpdate()
end

local function doText()
	t = GetTime()
	onUpdate()
end
A.doText = doText

local function doTrigger(event, ...)
	t = GetTime()
	onCombatEvent(...)
	return true
end
A.doTrigger = doTrigger
