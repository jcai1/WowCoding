----- Gigantic Anger -----
local A = aura_env

----- Set options here -----
local refreshRate = 20
local activeColor = "ff6969"

----- Custom text -----
local customText = ""
local refreshInterval = 1 / refreshRate
local lastRefresh = -999

----- Main logic -----
local furyTotal = 0
local inCombat = UnitAffectingCombat("player")

----- Utility -----
local now
local playerGUID = UnitGUID("player")

local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
	if  inCombat
	and destGUID == playerGUID
	and subEvent == "SPELL_ENERGIZE"
	and ... == 208828
	then
		furyTotal = furyTotal + select(4, ...)
	end
end

local function onEnteringCombat()
	inCombat = true
	furyTotal = 0
end

local function onLeavingCombat()
	inCombat = false
end

local function onUpdate()
	local newInCombat = UnitAffectingCombat("player")
	if inCombat and not newInCombat then onLeavingCombat()
	elseif not inCombat and newInCombat then onEnteringCombat()
	end
end

local function makeCustomText()
	if WeakAuras.IsOptionsOpen() then return "1000" end
	if inCombat then return format("|cff%s%d|r", activeColor, furyTotal)
	else return format("%d", furyTotal)
	end
end

local function doCustomText()
	now = GetTime()
	onUpdate()
	if now - lastRefresh > refreshInterval then
		customText = makeCustomText() or ""
		lastRefresh = now
	end
	return customText
end
A.doCustomText = doCustomText

local dispatch = {
	["COMBAT_LOG_EVENT_UNFILTERED"] = onCombatEvent,
	["PLAYER_REGEN_DISABLED"] = onEnteringCombat,
	["PLAYER_REGEN_ENABLED"] = onLeavingCombat,
}
local function doTrigger(event, ...)
	now = GetTime()
	dispatch[event](...)
	return true
end
A.doTrigger = doTrigger
