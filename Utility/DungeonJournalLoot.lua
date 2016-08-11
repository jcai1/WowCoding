MySaved.Loot = MySaved.Loot or {}

local function printf(...)
	return print(format(...))
end

local function strip(s)
	s = gsub(s, "|T[^|]*|t", "")
	s = gsub(s, "|H[^|]*|h([^|]*)|h", "%1")
	s = gsub(s, "|[Cc]........", "")
	s = gsub(s, "|[Rr]", "")
	return s
end

local title = EncounterJournal.encounter.info.encounterTitle:GetText()
local lines = {title}
for i = 1, 100 do
	local s, id, _, name, _, slot, armor, _ = pcall(EJ_GetLootInfoByIndex, i)
	if not s then break end
	name = strip(name)
	slot = strip(slot)
	armor = strip(armor)
	local paren
	if armor == "" then
		if slot == "" then
			paren = ""
		else
			paren = format(" (%s)", slot)
		end
	else
		paren = format(" (%s %s)", armor, slot)
	end
	if armor ~= "" then armor = armor .. " " end
	tinsert(lines, format("%s%s - http://legion.wowhead.com/item=%d", name, paren, id))
end
MySaved.Loot[title] = table.concat(lines, "\n")
printf("Finished saving %s", title)
