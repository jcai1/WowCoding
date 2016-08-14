-- Custom text refresh
local lastTextRefresh = 0
local textRefreshInterval = 0.1

-- Custom text string
local text = ""

-- NPC names for summons
local npcs = {
	"Lady Jaina Proudmoore",
	"Tyrande Whisperwind",
	"Lady Sylvanas Windrunner",
	"Arthas Menethil"
}
-- How long Temporal Power lasts
local duration = 10.2

local npcsDual = {}		-- NPC name -> index
local times = {}		-- Time last summoned
local active = {}		-- Whether summon is active
for i = 1, #npcs do
	local npc = npcs[i]
	npcsDual[npc] = i
	times[npc] = 0
	active[npc] = false
end

-- Temporal Power stats
local count = 0
local avgExpire = 0

local playerGUID = UnitGUID("player")	-- Player GUID

local function refreshStats()
	local t = GetTime()
	count = 0
	avgExpire = 0

	for i = 1, #npcs do
		local npc = npcs[i]
		if active[npc] then
			local elapsed = t - times[npc]
			if elapsed > 12 then
				-- Assume it fell off & we didn't catch it somehow
				active[npc] = false
			else
				-- Buff is active
				local expire = times[npc] + duration
				count = count + 1
				avgExpire = avgExpire + max(t, expire)
			end
		end
	end
	if count > 0 then
		avgExpire = avgExpire / count
	end
end

local function doDuration()
	refreshStats()
	return duration, avgExpire
end
aura_env.doDuration = doDuration

local function doCombatTrigger(_, _, subEvent, _,
	sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID)
	if destGUID == playerGUID and spellID == 190623 then
		if subEvent == "SPELL_AURA_APPLIED" then
			times[sourceName] = GetTime()
			active[sourceName] = true
		else
			active[sourceName] = false
		end
		refreshStats()
	end
	return count > 0
end
aura_env.doCombatTrigger = doCombatTrigger

local function refreshText()
	lastTextRefresh = GetTime()
	text = tostring(count)
end

local function doText()
	local t = GetTime()
	if t - lastTextRefresh > textRefreshInterval then
		refreshText()
	end
	return text
end
aura_env.doText = doText


--------------------------------------------------------------
-- Combat trigger
function(...)
	return aura_env.doCombatTrigger(...)
end

--------------------------------------------------------------
-- Duration info
function()
	return aura_env.doDuration()
end

--------------------------------------------------------------
-- Custom text
function()
	return aura_env.doText()
end

