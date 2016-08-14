--------------------------------------------------------------
-- Init
local A = aura_env
-- local R = WeakAuras.regions[A.id].region
local S = WeakAurasSaved.displays[A.id]

local xdInterval = 1800			-- Interval between xd's, in seconds
local zavinnBTag = "Zavinn#1156"
local zavinnID					-- Zavinn's presenceID
S.lastXd = S.lastXd or 0		-- Time of last xd

-- Returns Zavinn's presenceID, or nil if he's not your BTag friend.
local function getZavinn()
	for i = 1, BNGetNumFriends() do
		local presenceID, _, battleTag = BNGetFriendInfo(i)
		if battleTag == zavinnBTag then
			return presenceID
		end
	end
end

-- xd
local function xd()
	if not zavinnID then
		return
	end
	local isOnline = select(8, BNGetFriendInfoByID(zavinnID))
	if isOnline then
		BNSendWhisper(zavinnID, "xd")
	end
end

local loaded = false
local LOAD_SUCCESS, LOAD_UNSURE, LOAD_FAILED = 0, 1, 2
local lastLoadResult
local loadUnsureStreak = 0
local loadFailedCount = 0

-- Performs load operations that may fail.
local function tryLoad()
	zavinnID = getZavinn()
	if zavinnID then
		return LOAD_SUCCESS
	else
		return LOAD_UNSURE
	end
end

-- Calls tryLoad and controls retry attempts.
local function doLoadAttempt()
	if loaded then return end

	local result = tryLoad()

	if result == LOAD_SUCCESS then
		loaded = true
	elseif result == LOAD_UNSURE then
		if lastLoadResult == LOAD_UNSURE then
			loadUnsureStreak = loadUnsureStreak + 1
		else
			loadUnsureStreak = 1
		end
		if loadUnsureStreak >= 2 then
			-- Assume we succeeded.
			loaded = true
		end
	elseif result == LOAD_FAILED then
		loadFailedCount = loadFailedCount + 1
	end

	lastLoadResult = result

	if not loaded then
		if loadFailedCount >= 4 then
			-- Give up.
			print("WA [" .. A.id .. "] failed to load.")
		else
			C_Timer.After(1, doLoadAttempt)
		end
	end
end

-- Custom text function
local function doText()
	if not loaded then return end
	local rt = time() -- Real time (since epoch)
	if rt - S.lastXd > xdInterval then
		xd()
		S.lastXd = rt
	end
end
A.doText = doText

doLoadAttempt()

--------------------------------------------------------------
-- Custom text
function()
	return aura_env.doText()
end
