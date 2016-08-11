--------------------------------------------------------------
-- Init
local A = aura_env
-- local R = WeakAuras.regions[A.id].region

-- Custom text
local lastTextRefresh = 0		-- Time of last refresh
local textRefreshInterval = 0.1	-- Interval between refreshes
local text = ""					-- Actual text to display

local playerGUID				-- Stored UnitGUID("player")
local trinketID = 124517		-- Item ID for Sacred Draenic Incense
local equipped					-- Whether the trinket is equipped

local procCount = 0				-- # of procs since combat started
local castsPending = 0			-- # of RSK casts expecting an RSK hit
local inCombat					-- In combat?
local preCombat = false			-- Did we reset stats anticipating combat?

-- RSK cast "cancels" the next RSK hit.
local function onRSKCast(t)
	-- RSK cast can occur immediately before entering combat
	-- If this is the case, reset stats now, and tell onEnteringCombat not to.
	if not inCombat then
		procCount = 0
		castsPending = 0
		preCombat = true
	end
	castsPending = castsPending + 1
end

-- If an RSK hits without associated cast, count as trinket proc.
local function onRSKHit(t)
	if castsPending > 0 then
		castsPending = castsPending - 1
	else
		procCount = procCount + 1
	end
end

-- COMBAT_LOG_EVENT_UNFILTERED handler
local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if equipped and sourceGUID == playerGUID then
		if subEvent == "SPELL_CAST_SUCCESS" then
			if ... == 107428 then
				-- RSK cast event
				onRSKCast(t)
			end
		elseif subEvent == "SPELL_DAMAGE" then
			if ... == 185099 and not select(14, ...) then
				-- RSK damage event, not multistrike
				onRSKHit(t)
			end
		elseif subEvent == "SPELL_MISSED" then
			if ... == 185099 and not select(6, ...) then
				-- RSK miss event, not multistrike
				onRSKHit(t)
			end
		end
	end
end

-- PLAYER_REGEN_DISABLED handler
local function onEnteringCombat()
	-- Reset stats, if onRSKCast() didn't do it.
	if preCombat then
		preCombat = false
	else
		castsPending = 0
		procCount = 0
	end
	-- Update combat status.
	inCombat = true
end

-- PLAYER_REGEN_ENABLED handler
local function onLeavingCombat()
	-- Update combat status.
	inCombat = false
end

-- Checks whether Sacred Draenic Incense is equipped
local function isTrinketEquipped()
	return (GetInventoryItemID("player", INVSLOT_TRINKET1) == trinketID
		or GetInventoryItemID("player", INVSLOT_TRINKET2) == trinketID)
end

-- PLAYER_EQUIPMENT_CHANGED handler
local function onEquipmentChanged()
	equipped = isTrinketEquipped()
end

-- Called immediately, but also after PLAYER_ENTERING_WORLD with delay.
-- This prevents issues with cold login.
local function doDelayedLoad()
	onEquipmentChanged() -- Check equipment
	playerGUID = UnitGUID("player")
	inCombat = UnitAffectingCombat("player")
end
doDelayedLoad()

-- PLAYER_ENTERING_WORLD handler
local function onEnteringWorld()
	C_Timer.After(1, doDelayedLoad) -- Set up delayed load
end

-- What the trigger should return. true => shown, false => hidden.
local function shouldShow()
	-- Show WA only if equipped
	return equipped
end

-- Trigger dispatch handler
-- We ignore return value of dispatch functions, and instead use shouldShow()
local dispatchTable = {
	["COMBAT_LOG_EVENT_UNFILTERED"] = onCombatEvent,
	["PLAYER_REGEN_DISABLED"] = onEnteringCombat,
	["PLAYER_REGEN_ENABLED"] = onLeavingCombat,
	["PLAYER_EQUIPMENT_CHANGED"] = onEquipmentChanged,
	["PLAYER_ENTERING_WORLD"] = onEnteringWorld,
}
local function doTrigger(event, ...)
	local dispatchFunc = dispatchTable[event]
	dispatchFunc(...)
	return shouldShow()
end
A.doTrigger = doTrigger

-- Return a new custom text string
local function makeText()
	return tostring(procCount)
end

-- Custom text function
local function doText()
	local t = GetTime()
	if t - lastTextRefresh > textRefreshInterval then
		lastTextRefresh = t
		text = makeText()
	end
	return text
end
A.doText = doText

--------------------------------------------------------------
-- Custom trigger
function(...)
	return aura_env.doTrigger(...)
end

--------------------------------------------------------------
-- Custom text
function()
	return aura_env.doText()
end
