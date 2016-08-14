local A = aura_env
local refreshInterval, lastRefresh, now, text = 0.05, 0
local playerGUID = UnitGUID("player")
local rbCounts = {}
local rbMults = {[0] = "1.0x", [1] = "1.6x", [2] = "2.4x", [3] = "3.6x"}
function A.combatEvent(_, _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, ...)
	if not (destGUID and sourceGUID == playerGUID) then return end
	if ... == 17962 then
		if subEvent == "SPELL_DAMAGE" then
			rbCounts[destGUID] = (rbCounts[destGUID] or 0) + 1
		end
	elseif ... == 157736 then
		if strsub(subEvent, 1, 11) == "SPELL_AURA_" then
			rbCounts[destGUID] = (subEvent ~= "SPELL_AURA_REMOVED") and 0 or nil
		end
	end
end
function A.text()
	now = GetTime()
	if now - lastRefresh > refreshInterval then
		if UnitDebuff("target", "Immolate", nil, "PLAYER")
		then text = rbMults[rbCounts[UnitGUID("target")]] or "???"
		else text = "   " end
		lastRefresh = now
	end
	return text
end
