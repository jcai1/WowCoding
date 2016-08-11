local A = aura_env

-- display refresh
A.t = 0
A.dt = 0.05
-- pandemic duration refresh
A.t2 = 0
A.dt2 = 5
-- string to display
A.display = ""

local tconcat = table.concat

local debuffs = { "Haunt", "Unstable Affliction", "Agony", "Corruption", "Drain Soul" }
local colors = { "66cc66", "cc9900", "ffcc00", "ff66ff", "6666cc" }
local notify = { true, true, true, true, false }
local pandemic = { 3, 4.2, 7.2, 5.4, 0 }
local expireColor = "ff0000"

local debuffsRM = {} -- Reverse mapping (name -> index)
for i = 1, #debuffs do debuffsRM[debuffs[i]] = i end

-- Need to check DoT durations periodically due to T18 class trinket.
-- (Could have been unequipped / equipped)
local function updatePandemic()
	local uaDuration = strmatch(GetSpellDescription(30108), "over ([%d.]*) sec")
	local agonyDuration = strmatch(GetSpellDescription(980), "over ([%d.]*) sec")
	local corrDuration = strmatch(GetSpellDescription(172), "over ([%d.]*) sec")
	if uaDuration then pandemic[debuffsRM["Unstable Affliction"]] = tonumber(uaDuration)*0.3 end
	if agonyDuration then pandemic[debuffsRM["Agony"]] = tonumber(agonyDuration)*0.3 end
	if corrDuration then pandemic[debuffsRM["Corruption"]] = tonumber(corrDuration)*0.3 end
end
A.updatePandemic = updatePandemic

local function doCombatTrigger(
	event, timestamp, subEvent, hideCaster,
	sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	destGUID, destName, destFlags, destRaidFlags, ...
)
	
end
A.doCombatTrigger = doCombatTrigger

local temp = {}
local function makeInfoString(unit)
	local t = GetTime()
	for i = 1, #debuffs do
		temp[i] = "  "
	end
	local j = 1
	while true do
		local name, _, _, stacks, _, duration, expires
			= UnitDebuff(unit, j, "PLAYER")
		if not name then
			break
		end
		local i = debuffsRM[name]
		if i and expires then
			local remain = expires - t
			local color = (remain > pandemic[i]) and colors[i] or expireColor
			temp[i] = format("|cff%s%2.f|r", color, remain)
		end
		j = j + 1
	end
	return tconcat(temp, " ")
end

local function updateDisplay()
	A.display = makeInfoString("target") .. "\n" .. " H UA Ag Cr DS"
end
A.updateDisplay = updateDisplay
