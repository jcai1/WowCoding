local t = GetTime()
local A = aura_env
local F = WeakAuras.regions[A.id].region

-- Set constants here
A.nrow = 5
A.font = "Fonts\\FRIZQT__.TTF"
A.headerHeightRel = 0.09
A.headerLengthLimit = 25
A.nameHeightRel = 0.25
A.nameLengthLimit = 5
A.borderThicknessRel = 0.03

-- Creation of UI objects (done once per /reload)
F:SetFrameLevel(0) -- level 0
F.super = F.super or CreateFrame("Frame", nil, F)
F.super:SetFrameLevel(3) -- level 3
F.bg = F.bg or F:CreateTexture(nil, "BACKGROUND", nil, 0)
F.header = F.header or F.super:CreateFontString(nil, "BACKGROUND")
-- F.headerAG = F.headerAG or F.header:CreateAnimationGroup()
-- F.headerTrans = F.headerTrans or F.headerAG:CreateAnimation("Translation")
-- F.headerAlpha = F.headerAlpha or F.headerAG:CreateAnimation("Alpha")
F.tiles = F.tiles or {}
F.icons = F.icons or {}
F.cdFrames = F.cdFrames or {}
F.cds = F.cds or {}
F.names = F.names or {}
F.borders = F.borders or {}
for i = 1, 40 do
    F.tiles[i] = F.tiles[i] or CreateFrame("Frame", nil, F) -- level 1
    local tile = F.tiles[i]
    F.icons[i] = F.icons[i] or tile:CreateTexture(nil, "BACKGROUND", nil, 2)
    F.cdFrames[i] = F.cdFrames[i] or CreateFrame("Cooldown", nil, tile, "CooldownFrameTemplate") -- level 2
    F.cds[i] = F.cds[i] or F.super:CreateFontString(nil, "BACKGROUND")
    F.names[i] = F.names[i] or F.super:CreateFontString(nil, "BACKGROUND")
    F.borders[i] = F.borders[i] or tile:CreateTexture(nil, "BACKGROUND", nil, 1)
end

-- General purpose functions
function A.error(msg)
    print("RaidInterrupts error: " .. msg)
end
function A.fatalError(msg)
    print("RaidInterrupts fatal error: " .. msg)
    A.aborted = true
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
A.deepcopy = deepcopy

function A.formatTime(secs)
    if secs < 0 then
        return "-" .. A.formatTime(-secs)
    end
    if secs < 0.5 then
        return ""
    elseif secs < 59.5 then
        return string.format("%.f", secs)
    elseif secs < 3570 then
        return string.format("%.f", secs / 60) .. "m"
    elseif secs < 84600 then
        return string.format("%.f", secs / 3600) .. "h"
    elseif secs < 8631360 then
        return string.format("%.f", secs / 86400) .. "d"
    else
        return "(!)"
    end
end

function A.scaleText(fontString)
    local fs = fontString
    local wmax, hmax = fs.maxWidth, fs.maxHeight
    if not (wmax and hmax) then
        A.error("scaleText called on a plain FontString")
    else
        local text, w, h = fs:GetText(), fs:GetSize()
        if w == 0 or h == 0 then return end
        local goodness = math.max(w / wmax, h / hmax)
        if text ~= fs.oldText or math.abs(goodness - 1) > 0.06 then
            local prop = w / h
            local hnew = math.floor(hmax * prop <= wmax and hmax or wmax / prop)
            local fontName, _, flags = fs:GetFont()
            if hnew > 32 then
                fs:SetFont(fontName, 32, flags)
                fs:SetTextHeight(hnew)
            else
                fs:SetFont(fontName, hnew, flags)
            end
            fs.oldText = text
        end
    end
end

-- Display initialization
A.headerMsg = ""
A.headerMsgTime = -math.huge
do
    local square = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White"
    local left, bottom, width, height = F:GetRect()
    local headerHeight = height * A.headerHeightRel
    local w0, w1, w2, h0, h1, h2, h3, h4
    h0 = height * (1 - A.headerHeightRel) / A.nrow
    w0 = width / math.ceil(20 / A.nrow)
    w1 = w0 * A.borderThicknessRel
    w2 = w0 - 2 * w1
    h1 = h0 * A.nameHeightRel
    h2 = h0 - h1
    h3 = h0 * A.borderThicknessRel
    h4 = h2 - 2 * h3
    
    local super, bg, header = F.super, F.bg, F.header
    bg:ClearAllPoints()
    bg:SetPoint("LEFT", F, "LEFT", 0, 0) -- later width will dynamically change
    bg:SetSize(F:GetSize())
    bg:SetTexture(square)
    bg:SetVertexColor(0, 0, 0)
    header:ClearAllPoints()
    header:SetFont(A.font, 32, "OUTLINE")
    header:SetPoint("CENTER", F, "TOP", 0, -(headerHeight / 2))
    header.maxWidth = width
    header.maxHeight = headerHeight
    
    for i = 1, 40 do
        local col = math.ceil(i / A.nrow)
        local row = i - A.nrow * (col - 1)
        local tile, icon, cdFrame, cd, name, border
        = F.tiles[i], F.icons[i], F.cdFrames[i], F.cds[i], F.names[i], F.borders[i]
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", F, "TOPLEFT", (col - 1) * w0, -((row - 1) * h0 + headerHeight))
        tile:SetSize(w0, h0)
        icon:ClearAllPoints()
        icon:SetPoint("BOTTOM", tile, "BOTTOM", 0, h3)
        icon:SetSize(w2, h4)
        cdFrame:ClearAllPoints()
        cdFrame:SetAllPoints(icon)
        cdFrame:SetHideCountdownNumbers(true) -- hide Blizzard cd text
        cdFrame.noCooldownCount = true -- tells other addons to hide cd text
        cd:ClearAllPoints()
        cd:SetPoint("CENTER", tile, "BOTTOM", 0, h2 / 2)
        cd:SetFont(A.font, 32, "OUTLINE")
        cd.maxWidth = w2
        cd.maxHeight = h4
        cd:SetText("59m")
        A.scaleText(cd)
        cd:SetText("")
        name:ClearAllPoints()
        name:SetPoint("CENTER", tile, "TOP", 0, -h1 / 2)
        name:SetFont(A.font, 32, "OUTLINE")
        name.maxWidth = w0
        name.maxHeight = h1
        border:ClearAllPoints()
        border:SetPoint("BOTTOM", tile, "BOTTOM", 0, 0)
        border:SetSize(w0, h2)
        border:SetTexture(square)
        border:Hide()
    end
end

-- Core initialization
A.players = {}
A.petMap = {} -- pet GUID -> player GUID

local unitDB = {none = {"player"},
    party = {"player", "party1", "party2", "party3", "party4"},
    raid = {}}
for i = 1, 40 do unitDB.raid[i] = "raid" .. i end
A.unitDB = unitDB
function A.getUnitList()
    if IsInRaid() then
        return A.unitDB.raid
    elseif IsInGroup() then
        return A.unitDB.party
    else
        return A.unitDB.none
    end
end

A.intDB = { -- Baseline
    WARRIOR = {{spell = "Pummel", cd = 15, icon = "INV_Gauntlets_04", on = true},
        {spell = "Heroic Throw", cd = 15, icon = "INV_Axe_66"}},
    PALADIN = {{spell = "Rebuke", cd = 15, icon = "spell_holy_rebuke", on = true},
        {spell = "Avenger's Shield", cd = 15, icon = "Spell_Holy_AvengersShield"}},
    HUNTER = {{spell = "Counter Shot", cd = 24, icon = "inv_ammo_arrow_03", on = true}},
    ROGUE = {{spell = "Kick", cd = 15, icon = "Ability_Kick", on = true}},
    PRIEST = {{spell = "Silence", cd = 45, icon = "ability_priest_silence", on = true}},
    DEATHKNIGHT = {{spell = "Mind Freeze", cd = 15, icon = "Spell_DeathKnight_MindFreeze", on = true},
        {spell = "Strangulate", cd = 60, icon = "Spell_Shadow_SoulLeech_3", on = true},
        {spell = "Asphyxiate", cd = 30, icon = "ability_deathknight_asphixiate"}},
    SHAMAN = {{spell = "Wind Shear", cd = 12, icon = "Spell_Nature_Cyclone", on = true}},
    MAGE = {{spell = "Counterspell", cd = 24, icon = "Spell_Frost_IceShock", on = true}},
    WARLOCK = {{spellID = 132409, spell = "Spell Lock", cd = 24, icon = "Spell_Shadow_MindRot", on = true}, -- GoSac version
        {spellID = 119910, spell = "Spell Lock", cd = 24, icon = "Spell_Shadow_MindRot"},
        {spell = "Optical Blast", cd = 24, icon = "spell_nature_elementalprecision_1"},
        {spell = "Shadow Lock", cd = 24, icon = "Spell_Shadow_PainAndSuffering"}},
    DRUID = {{spell = "Skull Bash", cd = 15, icon = "inv_bone_skull_04"},
        {spell = "Solar Beam", cd = 60, icon = "ability_vehicle_sonicshockwave"},
        {spell = "Faerie Fire", cd = 15, icon = "spell_nature_faeriefire"}},
    MONK = {{spell = "Spear Hand Strike", cd = 15, icon = "ability_monk_spearhand", on = true}}
}

-- Sanity check for A.intDB
for class, ints in pairs(A.intDB) do
    for k = 1, #ints do
        local int = ints[k]
        if not (int.spell or int.spellID) then
            A.fatalError(class .. " interrupt entry has no spell name/ID")
        else
            local name = int.spell or int.spellID
            if not int.cd then
                A.fatalError(class .. " interrupt '" .. name .. "' missing CD info")
            elseif not int.icon then
                A.fatalError(class .. " interrupt '" .. name .. "' missing icon info")
            end
        end
    end
end
if A.aborted then
    return
end

A.ProtPallySpells = {["Avenger's Shield"] = true, ["Shield of the Righteous"] = true, ["Grand Crusader"] = true}
A.HolyPriestSpells = {["Renew"] = true, ["Circle of Healing"] = true, ["Holy Word: Serenity"] = true, ["Binding Heal"] = true}
A.BalanceDruidSpells = {["Starfire"] = true, ["Starsurge"] = true, ["Starfall"] = true}
A.MeleeDruidSpells = {["Lacerate"] = true, ["Maul"] = true, ["Mangle"] = true, ["Thrash"] = true, ["Savage Defense"] = true,
    ["Rake"] = true, ["Rip"] = true, ["Tiger's Fury"] = true}

function A.lookup(ints, spellID, spell, mustBeOn) -- Lookup a spellID/spell pair in the given interrupt table
    for k = 1, #ints do
        local int = ints[k]
        if (not mustBeOn or int.on)
        and ((not int.spellID) or (not spellID) or (int.spellID == spellID))
        and ((not int.spell) or (not spell) or (int.spell == spell)) then
            return int
        end
    end
    return nil
end

local function updateAllUnits()
    -- Raid status refresh run every 0.5 seconds
    local unitList = A.getUnitList()
    
    for i = 1, #unitList do
        local u = unitList[i]
        local pet = u .. "pet"
        local guid, name, class
        if UnitExists(u) then
            guid = UnitGUID(u)
            name = UnitName(u)
            class = select(2, UnitClass(u))
        end
        if guid and name and class then
            A.players[guid] = A.players[guid] or {}
            local p = A.players[guid]
            
            p.unit = u
            p.name = name
            p.class = class
            p.lastSeen = p.lastSeen or -math.huge
            p.dead = UnitIsDeadOrGhost(u)
            if UnitExists(pet) then
                p.pet = UnitCreatureFamily(pet)
                A.petMap[UnitGUID(pet)] = guid
            else
                p.pet = nil
            end
            p.lastPet = p.pet or p.lastPet
            if UnitIsDeadOrGhost(pet) then
                p.pet = nil
            end
            p.ints = p.ints or deepcopy(A.intDB[p.class])
            
            local oldCombat = p.inCombat
            p.inCombat = UnitAffectingCombat(u)
            if p.inCombat and not oldCombat then -- Unit entered combat
                -- Reset their interrupt table to default, keeping the last cast time
                local ints, newInts = p.ints, deepcopy(A.intDB[p.class])
                for k1 = 1, #ints do
                    for k2 = 1, #newInts do
                        local int, newInt = ints[k1], newInts[k2]
                        if int.spell == newInt.spell and int.spellID == newInt.spellID then
                            newInt.lastCast = int.lastCast
                        end
                    end
                end
                p.ints = newInts
                p.seen = (t - p.lastSeen < 10) -- Reset their seen status
            end
            
            local function getInt(self, spell)
                local int
                if type(spell) == "string" then
                    int = A.lookup(self.ints, nil, spell, false)
                elseif type(spell) == "number" then
                    int = A.lookup(self.ints, spell, nil, false)
                end
                if not int then
                    A.error("Interrupt '"..tostring(spell).."' not found")
                end
                return int
            end
            p.getInt = getInt -- Usage: p:getInt("spell") or p:getInt(spellID)
            
            if p.class == "WARLOCK" then
                p.gosac = UnitBuff(u, "Grimoire of Sacrifice")
                local spellLockSac, spellLock, opticalBlast, shadowLock
                
                for k = 1, #(p.ints) do
                    local int = p.ints[k]
                    if int.spellID == 132409 then spellLockSac = int
                    elseif int.spellID == 119910 then spellLock = int
                    elseif int.spell == "Optical Blast" then opticalBlast = int
                    elseif int.spell == "Shadow Lock" then shadowLock = int
                    end
                end
                if spellLockSac and spellLock and opticalBlast and shadowLock then
                    spellLockSac.on = (p.gosac and p.lastPet == "Felhunter")
                    spellLock.on = (p.pet == "Felhunter")
                    opticalBlast.on = (p.pet == "Observer")
                    shadowLock.on = (p.pet == "Doomguard" or p.pet == "Terrorguard")
                    if spellLockSac.on and spellLock.lastCast
                    and ((not spellLockSac.lastCast) or spellLock.lastCast > spellLockSac.lastCast) then
                        spellLockSac.lastCast = spellLock.lastCast
                    end
                end
            end
        end
    end
end

local function updateDisplay()
    -- Display refresh run every 0.1 seconds
    local t = GetTime()
    local scaleText = A.scaleText
    -- do
    -- local header = F.header
    -- header:SetText(A.headerMsg)
    -- local delta = t - A.headerMsgTime
    -- local alpha = (delta < 10) and (1 - delta / 10) ^ 2 or 0
    -- header:SetTextColor(1, 1, 1, alpha)
    -- header:SetTextColor(1, 1, 1, 1)
    -- scaleText(header)
    -- end
    local rightmostPoint = 0
    local unitList = A.getUnitList()
    local usedTiles = {}
    for j = 1, #unitList do
        local u = unitList[j]
        local p = UnitExists(u) and A.players[UnitGUID(u)]
        local i = j -- i = display index; j = index in unitList
        local show
        if p then
            local inCombat = UnitAffectingCombat("player")
            if inCombat then
                show = p.seen and not p.dead
            else
                show = UnitIsVisible(p.unit)
            end
        end
        
        local tile, name, icon, cd, cdFrame, border
        = F.tiles[i], F.names[i], F.icons[i], F.cds[i], F.cdFrames[i], F.borders[i]
        
        if show then
            usedTiles[i] = true
            rightmostPoint = math.max(rightmostPoint, tile:GetRight())
            
            do
                name:SetText(string.sub(p.name, 1, A.nameLengthLimit))
                local c = RAID_CLASS_COLORS[p.class]
                name:SetTextColor(c.r, c.g, c.b)
                scaleText(name)
                name:Show()
            end
            
            local count, charges, minRecharge, iconName = 0, 0, math.huge, nil
            local intWithMinRecharge
            
            for k = 1, #(p.ints) do
                local int = p.ints[k]
                if int.on then
                    count = count + 1
                    local elapsed = t - (int.lastCast or -math.huge)
                    local remain = math.max(0, int.cd - elapsed)
                    if remain == 0 then
                        if charges == 0 then
                            iconName = int.icon
                        end
                        charges = charges + 1
                    elseif remain < minRecharge then
                        minRecharge = remain
                        intWithMinRecharge = int
                        iconName = int.icon
                    end
                end
            end
            if count > 0 then
                icon:SetTexture("Interface\\Icons\\" .. iconName)
                icon:Show()
                if minRecharge < math.huge then
                    cd:SetText(A.formatTime(minRecharge))
                    cdFrame:SetCooldown(intWithMinRecharge.lastCast, intWithMinRecharge.cd)
                    if charges > 0 then
                        cd:SetTextColor(0, 1, 1, 1)
                    else
                        if minRecharge < 5.5 then
                            cd:SetTextColor(1, 0, 0, 1)
                        elseif minRecharge < 59.5 then
                            cd:SetTextColor(1, 1, 0, 1)
                        else
                            cd:SetTextColor(1, 1, 1, 1)
                        end
                    end
                    cd:Show()
                    cdFrame:Show()
                else
                    cd:Hide()
                    cdFrame:Hide()
                end
                if charges >= 1 then
                    border:SetVertexColor(1, 1, 1)
                else
                    border:SetVertexColor(0, 0, 0)
                end
                border:Show()
            else
                icon:Hide()
                cd:Hide()
                cdFrame:Hide()
                border:Hide()
            end
        end
    end
    for i = 1, 40 do
        local name, icon, cd, cdFrame, border
        = F.names[i], F.icons[i], F.cds[i], F.cdFrames[i], F.borders[i]
        if not usedTiles[i] then
            name:Hide()
            icon:Hide()
            cd:Hide()
            cdFrame:Hide()
            border:Hide()
        end
    end
    F.bg:SetWidth(math.max(F:GetWidth(), rightmostPoint - F.bg:GetLeft()))
end

A.periodic = {} -- Array of periodic callbacks. Entry = {interval = ..., callback = ...}
table.insert(A.periodic, {interval = 0.1, callback = updateDisplay})
table.insert(A.periodic, {interval = 0.5, callback = updateAllUnits})


