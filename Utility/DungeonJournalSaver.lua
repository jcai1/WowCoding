MySaved.Instances = MySaved.Instances or {}
local allTextures = {}

local function printf(...)
	return print(format(...))
end

local function ensureVisible(frame)
	if frame and frame:IsVisible() then
		return frame
	end
end

local function escapeTex(str)
	return gsub(str, "([$%%_])", "\\%1")
end

local function trim(str)
	return gsub(gsub(str, "^%s+", ""), "%s+$", "")
end

local function parseHeader(header)
	local button, title, desc, abilityIcon, icons
	button = header.button
	title = ensureVisible(button.title)
	desc = ensureVisible(header.description)
	if not (title or desc) then
		printf("Warn: No title or description for %s", header:GetName())
		return
	end
	abilityIcon = ensureVisible(button.abilityIcon)
	icons = {}
	for j = 1, 4 do icons[j] = ensureVisible(button["icon" .. j]) end

	local titleText, descText, abilityIconText, iconsText = "", "", "", ""
	local beginDepth, endDepth = "", ""

	if title then
		titleText = title:GetText()
		titleText = trim(titleText)
		titleText = escapeTex(titleText)
		titleText = format("\\textbf{%s}", titleText)
	end

	if desc then
		descText = desc:GetText()
		descText = gsub(descText, "\r", "")
		descText = trim(descText)
		descText = gsub(descText, "|T[^|]*|t", "")
		descText = gsub(descText, "|H[^|]*|h([^|]*)|h", "%1")
		descText = gsub(descText, "|[Cc]........", "")
		descText = gsub(descText, "|[Rr]", "")
		descText = escapeTex(descText)
		descText = gsub(descText, "\n+", "\\lineBreak ")
	end

	if abilityIcon then
		local texture = abilityIcon:GetTexture()
		if texture then
			if type(texture) ~= "string" then
				assert(type(texture) == "number")
				printf("Note: Texture of %s is %d",
					tostring(title and title:GetText()), texture)
			end
			abilityIconText = tostring(texture)
			if strlower(strsub(abilityIconText, 1, 16)) == "interface\\icons\\" then
				abilityIconText = strlower(strsub(abilityIconText, 17))
			end
			allTextures[abilityIconText] = true
			abilityIconText = format("\\abilityIcon{%s}", abilityIconText)
		end
	end

	for j = 1, 4 do
		local tooltip = icons[j] and icons[j].tooltipTitle
		if tooltip then
			tooltip = gsub(tooltip, " ", "_")
			iconsText = iconsText .. format("\\ejIcon{%s}", tooltip)
		end
	end

	if header.xdepth then
		beginDepth = format("\\begin{depth}{%d}\n", header.xdepth)
		endDepth = "\n\\end{depth}"
	end

	return format("%s%s%s%s: %s%s",
		beginDepth, abilityIconText, titleText, iconsText, descText, endDepth)
end

local function expandAllHeaders()
	while true do
		local numExpanded = 0
		for i = 1, 200 do
			local header = _G["EncounterJournalInfoHeader" .. i]
			if header and not header.expanded then
				EncounterJournal_ToggleHeaders(header)
				if header.expanded then
					numExpanded = numExpanded + 1
				end
			end
		end
		if numExpanded == 0 then
			return
		end
	end
end

local function processEncounter(lines)
	local encounterTitle = ensureVisible(EncounterJournalEncounterFrameInfoEncounterTitle)
	if not encounterTitle then
		print("Error: Encounter title is not visible")
		return
	end
	local encounterID = EncounterJournal.encounterID
	if not encounterID then
		print("Error: No encounterID")
		return
	end
	local encounterName = tostring(encounterTitle:GetText())

	expandAllHeaders()

	--- Determine # of headers, ensure they're valid, get them in order, ensure no gaps
	local headers = {}
	local maxIndex = 0

	for i = 1, 200 do
		local header = _G["EncounterJournalInfoHeader" .. i]
		if not header or not header:IsVisible() then
			-- Nothing
		elseif not header.index or not header.myID or not header.parentID then
			printf("Warn: %s missing index or IDs", header:GetName())
		elseif not header.button or not header.button:IsVisible() then
			printf("Warn: %s has no visible button", header:GetName())
		else
			if not header.expanded then
				printf("Warn: %s not expanded", header:GetName())
			end
			headers[header.index] = header
			maxIndex = max(maxIndex, header.index)
		end
	end

	if maxIndex == 0 then
		printf("Error: No headers")
		return
	end
	for i = 1, maxIndex do
		if not headers[i] then
			printf("Error: Index %d not found (maxIndex = %d)", i, maxIndex)
			return
		end
	end

	--- Determine depths via myID / parentID
	local headerByID = {}

	for i, header in ipairs(headers) do
		headerByID[header.myID] = header
		header.xdepth = nil
	end

	for i, header in ipairs(headers) do
		if header.parentID == encounterID then
			header.xdepth = 0
		else
			if not headerByID[header.parentID] then
				printf("Warning: Invalid parent for %s", header:GetName())
				header.xdepth = 0
			end
		end
	end

	for _ = 1, 200 do
		local anySet
		for i, header in ipairs(headers) do
			if not header.xdepth then
				local parent = headerByID[header.parentID]
				if parent.xdepth then
					header.xdepth = parent.xdepth + 1
					anySet = true
				end
			end
		end
		if not anySet then break end
	end

	for i, header in ipairs(headers) do
		if not header.xdepth then
			printf("Warning: Couldn't deduce depth for %s", header:GetName())
			header.xdepth = 0
		end
	end

	--- Actually parse the headers
	tinsert(lines, format("\\section{%s}", escapeTex(encounterName)))
	for i, header in ipairs(headers) do
		local parsed = parseHeader(header)
		if parsed then
			tinsert(lines, parsed)
		end
	end
	tinsert(lines, "")

	print(format("%s processed successfully!", encounterName))
end

local function processInstance()
	local instanceTitle = ensureVisible(EncounterJournalEncounterFrameInfoInstanceTitle)
	local difficulty = ensureVisible(EncounterJournalEncounterFrameInfoDifficulty)
	if not instanceTitle or not difficulty then
		print("Error: Instance title or difficulty is not visible")
		return
	end
	local instanceName = instanceTitle:GetText()
	local difficultyText = difficulty:GetText()
	printf("Processing instance %s on %s difficulty", instanceName, difficultyText)

	local lines = {}
	local bossIndex = 0
	while true do
		bossIndex = bossIndex + 1
		local bossButton = ensureVisible(_G["EncounterJournalBossButton" .. bossIndex])
		if not bossButton then break end
		local encounterID = bossButton.encounterID
		if not encounterID then
			printf("Warn: Boss %d has no encounterID")
		else
			EncounterJournal_DisplayEncounter(encounterID)
			processEncounter(lines)
		end
	end

	MySaved.Instances[instanceName] = table.concat(lines, "\n")
	MySaved.Textures = allTextures
	printf("Saved %d bosses for %s", bossIndex, instanceName)
end

processInstance()
