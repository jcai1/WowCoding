local A = aura_env
local R = WeakAuras.regions[A.id].region
local S = WeakAurasSaved.displays[A.id]

local mapAreas = {
	[1015] = "Aszuna",
	[1018] = "Val'sharah",
	[1024] = "Highmountain",
	[1017] = "Stormheim",
	[1033] = "Suramar",
	[1096] = "Eye of Azshara,"
}

local factions = {
	[1900] = "Court of Farondis",
	[1883] = "Dreamweavers",
	[1828] = "Highmountain Tribe",
	[1948] = "Valarjar",
	[1894] = "The Wardens",
	[1859] = "The Nightfallen",
}

local function printf(...)
	print(format(...))
end

local function colorCyan(str)
	return "|cff00ffff" .. str .. "|r"
end

local function colorYellow(str)
	return "|cffffff00" .. str .. "|r"
end

local lines = {}
local function linef(fmt, ...)
	tinsert(lines, format(fmt, ...))
end

-- Quest properties: name, link, rewardType, reward, faction, location, questType
-- Displayed: questType (icon) | link | rewardType with reward | faction | location
-- Sort by:   questType        | name | rewardType             | faction | location

local quests = {}

local function processTaskInfoEntry(info, mapID)
	local questID = info.questId
	if not (questID and HaveQuestData(questID)) then return end

	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questID)
	if not worldQuestType then return end

	local name, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
	local link = format("|cffffff00|Hquest:%d:110|h[%s]|h|r", questID, name)
	local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
	
	local xp = GetQuestLogRewardXP(questID)
	local money = GetQuestLogRewardMoney(questID)
	local artifactXP = GetQuestLogRewardArtifactXP(questID)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if QuestMapFrame_IsQuestWorldQuest(questID)
	and WorldMap_DoesWorldQuestInfoPassFilters(info) then
		local title, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
		local link = format("|cffffff00|Hquest:%d:110|h[%s]|h|r", questID, title)
		local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
		local xp = GetQuestLogRewardXP(questID)
		local money = GetQuestLogRewardMoney(questID)
		local artifactXP = GetQuestLogRewardArtifactXP(questID)
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
		local numQuestRewards = GetNumQuestLogRewards(questID)

		wipe(lines)
		linef("Quest: %s (Faction: %d) (Time left: %02d:%02d)",
			link, factionID, timeLeftMinutes / 60, timeLeftMinutes % 60)
		if xp > 0 then linef("XP: %d", xp) end
		if money > 0 then linef("Money: %d", money) end
		if artifactXP > 0 then linef(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT, artifactXP) end
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			linef(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, numItems, name);
		end
		if numQuestRewards > 0 then
			local itemTooltip = WorldMapTooltip.ItemTooltip
			itemTooltip.Tooltip:ClearLines()
			EmbeddedItemTooltip_SetItemByQuestReward(itemTooltip, 1, questID)
			local itemName, itemLink = itemTooltip.Tooltip:GetItem()
			linef("%s", tostring(itemLink))
		end
		print(table.concat(lines, "\n"))
	end
end

local allTaskInfos = {}
local function getWorldQuests()
	wipe(allTaskInfos)
	local prevMapID = GetCurrentMapAreaID()
	for mapID, mapName in pairs(mapAreas) do
		SetMapByID(mapID)
		allTaskInfos[mapID] = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
	end
	SetMapByID(prevMapID)
	
	for mapID, mapName in pairs(mapAreas) do
		local taskInfo = allTaskInfos[mapID]
		if taskInfo then
			for _, info in ipairs(taskInfo) do
				processTaskInfoEntry(info, mapID)
			end
		end
	end
end
A.doCalc = doCalc
