---- Legion Stats Pane (Init) ----

-- Note that some of this stuff is copied directly from Blizzard's FrameXML,
-- in particular PaperDollFrame.lua. If anything in here is confusing or gross,
-- it's not my fault. OTOH, if anything in here is amazing or awesome, I take credit.

local A = aura_env
local R = WeakAuras.regions[A.id].region
local S = WeakAurasSaved.displays[A.id]

-- Possible anchor behaviors
-- FIXED: Fixed position, no auto-anchor
-- RIGHT: Anchor to right of character info frame
-- OVERLAY: Anchor directly above default stats pane, hiding it
local ANCHOR_FIXED, ANCHOR_RIGHT, ANCHOR_OVERLAY = 0, 1, 2

---- Set options here ----
local bgColor = {0, 0, 0, 1}    -- Background color/opacity (RGBA)
local headerColor = "33b5ff"      -- Color for category headings
local statNameColor = "f5bc00"    -- Color for stat names
local refreshRate = 10            -- How many times per second to refresh stats
local anchorBehavior = ANCHOR_OVERLAY  -- See above

----- Utility -----
local function printf(...) print(format(...)) end
local function errorf(...) error(format(...)) end

----- Stats string construction, utility -----

-- Gets ranged damage or melee damage based on weapon
local function GetAppropriateDamage(unit)
    if IsRangedWeapon() then
        local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
        return minDamage, maxDamage, nil, nil, 0, 0, percent;
    else
        return UnitDamage(unit);
    end
end

-- Gets the bonus afforded to a pet stat based on a player stat
function ComputePetBonus(stat, value)
    local _, class = UnitClass("player")
    local mult
    if class == "WARLOCK" then
        mult = WARLOCK_PET_BONUS[stat]
    elseif class == "HUNTER" then
        mult = HUNTER_PET_BONUS[stat]
    end
    return mult and (value * mult) or 0
end

-- Wraps text in red color string
local function redFont(s)
    return RED_FONT_COLOR_CODE .. s .. FONT_COLOR_CODE_CLOSE
end

-- Wraps text in green color string
local function greenFont(s)
    return GREEN_FONT_COLOR_CODE .. s .. FONT_COLOR_CODE_CLOSE
end

-- Idk, sorta rewrote some messy Blizzard code
local function formatWithBuffs(effective, base, posBuff, negBuff)
    local B = BreakUpLargeNumbers
    local eff = B(effective)
    local base = B(base)
    local pos = greenFont("+" .. B(posBuff))
    local neg = redFont(B(negBuff))
    if posBuff > 0 then
        if negBuff < 0 then
            return format("%s (%s%s%s)", redFont(eff), base, pos, neg)
        else
            return format("%s (%s%s)", greenFont(eff), base, pos)
        end
    else
        if negBuff < 0 then
            return format("%s (%s%s)", redFont(eff), base, neg)
        else
            return eff
        end
    end
end

-- Common code for certain simple "rating" stats which all
-- (1) use GetCombatRating and GetCombatRatingBonus directly
-- (2) have values expressed in percentages
function formatRatingStat(value, rating)
    return format("%.2f%%%% (%s / +%.2f%%%%)",
        value,
        BreakUpLargeNumbers(GetCombatRating(rating)),
        GetCombatRatingBonus(rating))
end

----- Stats string construction, core -----

-- Array to contain the lines of text.
local lines = {}

-- Add a header line
function addHeader(lines, s)
    tinsert(lines, format("|cff%s==== %s ====|r", headerColor, s))
end

-- Add a line for a stat
function addStat(lines, name, value)
    tinsert(lines, format("|cff%s%s:|r %s",
            statNameColor, name, tostring(value)))
end

-- Add a line for a formatted stat
function addFStat(lines, name, fmt, ...)
    addStat(lines, name, format(fmt, ...))
end

-- Add a line for a stat using formatRatingStat
function addRatingStat(lines, name, value, rating)
    addStat(lines, name, formatRatingStat(value, rating))
end


-- Getters / formatters for individual stats. Each function should
-- append to `lines` the formatted information about the new stat.

-- Health
local function addHealth(lines, unit)
    local health = UnitHealthMax(unit);
    health = BreakUpLargeNumbers(health);
    addStat(lines, "Health", health)
end

-- Power and Alternate Mana
local function addPower(lines, unit)
    local powerType, powerToken = UnitPowerType(unit);
    local power = UnitPowerMax(unit) or 0;
    power = BreakUpLargeNumbers(power);
    if powerToken and _G[powerToken] then
        addStat(lines, _G[powerToken], power)
    end
    
    local _, class = UnitClass(unit)
    if class == "DRUID"
    or (class == "MONK" and GetSpecialization == SPEC_MONK_MISTWEAVER) then
        if powerToken ~= "MANA" then
            local mana = UnitPowerMax(unit, SPELL_POWER_MANA);
            mana = BreakUpLargeNumbers(mana);
            addStat(lines, "Mana", mana)
        end
    end
end

-- Item Level
local function addItemLevel(lines, unit)
    if unit ~= "player" then return end
    local total, equipped, pvp = GetAverageItemLevel();
    if total == pvp then
        addFStat(lines, "Item Level", "%d / %d", equipped, total)
    else
        addFStat(lines, "Item Level", "%d / %d (PvP %d)", equipped, total, pvp)
    end
end

-- Movement Speed
local wasSwimming = nil
local function addMovementSpeed(lines, unit)
    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit);
    runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
    flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
    swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;
    
    -- Pets seem to always actually use run speed
    if (unit == "pet") then
        swimSpeed = runSpeed;
    end
    
    -- Determine whether to display running, flying, or swimming speed
    local speed = runSpeed;
    local swimming = IsSwimming(unit);
    if (swimming) then
        speed = swimSpeed;
    elseif (IsFlying(unit)) then
        speed = flightSpeed;
    end
    
    -- Hack so that your speed doesn't appear to change when jumping out of the water
    if (IsFalling(unit)) then
        if (wasSwimming) then
            speed = swimSpeed;
        end
    else
        wasSwimming = swimming;
    end
    
    -- We'll put the actual Speed stat in the Tertiary section
    addFStat(lines, "Speed", "%.f%%%% (Run %.f%%%% Fly %.f%%%% Swim %.f%%%%)",
    speed, runSpeed, flightSpeed, swimSpeed)
end

-- Primary Stats
local function addPrimaryStat(lines, unit, statIndex)
    local statName = _G["SPELL_STAT"..statIndex.."_NAME"]
    local statValue, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);
    local base = statValue - posBuff - negBuff
    addStat(lines, statName, formatWithBuffs(effectiveStat, base, posBuff, negBuff))
end

-- Critical Strike
local function addCrit(lines, unit)
    if unit ~= "player" then return end
    local rating;
    local spellCrit, rangedCrit, meleeCrit;
    local critChance;
    
    -- Start at 2 to skip physical damage
    local holySchool = 2;
    local minCrit = GetSpellCritChance(holySchool);
    local spellCrit;
    for i=(holySchool+1), MAX_SPELL_SCHOOLS do
        spellCrit = GetSpellCritChance(i);
        minCrit = min(minCrit, spellCrit);
    end
    spellCrit = minCrit
    rangedCrit = GetRangedCritChance();
    meleeCrit = GetCritChance();
    
    if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
        critChance = spellCrit;
        rating = CR_CRIT_SPELL;
    elseif (rangedCrit >= meleeCrit) then
        critChance = rangedCrit;
        rating = CR_CRIT_RANGED;
    else
        critChance = meleeCrit;
        rating = CR_CRIT_MELEE;
    end
    
    if GetCritChanceProvidesParryEffect() then
        local critRating = GetCombatRating(rating);
        addFStat(lines, "Crit", "%.2f%%%% (%s / +%.2f%%%%) (Parry +%.2f%%%%)",
            critChance,
            BreakUpLargeNumbers(critRating),
            GetCombatRatingBonus(rating),
            GetCombatRatingBonusForCombatRatingValue(CR_PARRY, critRating));
    else
        addRatingStat(lines, "Crit", critChance, rating)
    end
end

-- Haste
local function addHaste(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Haste", GetHaste(), CR_HASTE_MELEE)
end

-- Mastery
local function addMastery(lines, unit)
    if not (unit == "player" and UnitLevel("player") >= SHOW_MASTERY_LEVEL) then
        return
    end
    local mastery, bonusCoeff = GetMasteryEffect();
    local masteryRating = GetCombatRating(CR_MASTERY);
    local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;
    addFStat(lines, "Mastery", "%.2f%%%% (%s / +%.2f%%%%)",
        mastery,
        BreakUpLargeNumbers(masteryRating),
    masteryBonus)
end

-- Versatility
local function addVersatility(lines, unit)
    if unit ~= "player" then return end
    local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
    local versatilityDamageBonus =
    GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
    local versatilityDamageTakenReduction =
    GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN)
    + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
    
    addFStat(lines, "Versatility", "%.2f%%%% (%s) (Taken -%.2f%%%%)",
        versatilityDamageBonus,
        BreakUpLargeNumbers(versatility),
    versatilityDamageTakenReduction)
end

-- Lifesteal (Leech)
local function addLifesteal(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Leech", GetLifesteal(), CR_LIFESTEAL)
end

-- Avoidance
local function addAvoidance(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Avoidance", GetAvoidance(), CR_AVOIDANCE)
end

-- Speed
local function addSpeed(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Speed", GetSpeed(), CR_SPEED)
end

-- Attack Damage
local function addAttackDamage(lines, unit)
    local text
    local speed, offhandSpeed = UnitAttackSpeed(unit);
    local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage,
    physicalBonusPos, physicalBonusNeg, percent = GetAppropriateDamage(unit);
    
    -- remove decimal points for display values
    local displayMin = max(floor(minDamage),1);
    local displayMinLarge = BreakUpLargeNumbers(displayMin);
    local displayMax = max(ceil(maxDamage),1);
    local displayMaxLarge = BreakUpLargeNumbers(displayMax);
    
    -- calculate base damage
    minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
    maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
    
    local baseDamage = (minDamage + maxDamage) * 0.5;
    local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
    local totalBonus = (fullDamage - baseDamage);
    -- set tooltip text with base damage
    local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxDamage),1));
    
    local colorPos = "|cff20ff20";
    local colorNeg = "|cffff2020";
    
    -- epsilon check
    if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
        totalBonus = 0.0;
    end
    
    if ( totalBonus == 0 ) then
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text = (displayMinLarge.." - "..displayMaxLarge);    
        else
            text = (displayMinLarge.."-"..displayMaxLarge);
        end
    else
        -- set bonus color and display
        local color;
        if ( totalBonus > 0 ) then
            color = colorPos;
        else
            color = colorNeg;
        end
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text = (color..displayMinLarge.." - "..displayMaxLarge.."|r");    
        else
            text = (color..displayMinLarge.."-"..displayMaxLarge.."|r");
        end
        if ( physicalBonusPos > 0 ) then
            damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
        end
        if ( physicalBonusNeg < 0 ) then
            damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
        end
        if ( percent > 1 ) then
            damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%%|r";
        elseif ( percent < 1 ) then
            damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%%|r";
        end
    end
    
    addStat(lines, "Damage", text)
    addStat(lines, "MH Damage", damageTooltip)
    
    -- If there's an offhand speed then add the offhand info to the tooltip
    if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
        minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
        maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
        
        local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
        local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
        local offhandDamageTooltip = BreakUpLargeNumbers(max(floor(minOffHandDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxOffHandDamage),1));
        if ( physicalBonusPos > 0 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
        end
        if ( physicalBonusNeg < 0 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
        end
        if ( percent > 1 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%%|r";
        elseif ( percent < 1 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%%|r";
        end
        
        addStat(lines, "OH Damage", offhandDamageTooltip)
    end
end

-- Attack Power
local function addAttackPower(lines, unit)
    local tag;
    local text;
    local base, posBuff, negBuff;
    
    local rangedWeapon = IsRangedWeapon();
    
    if ( rangedWeapon ) then
        base, posBuff, negBuff = UnitRangedAttackPower(unit);
        tag = "Ranged AP"
    else 
        base, posBuff, negBuff = UnitAttackPower(unit);
        tag = "Melee AP"
    end
    
    local damageBonus
    local spellPower = 0;
    local effectiveAP = max(0,base + posBuff + negBuff);
    if (GetOverrideAPBySpellPower() ~= nil) then
        local holySchool = 2;
        -- Start at 2 to skip physical damage
        spellPower = GetSpellBonusDamage(holySchool);        
        for i=(holySchool+1), MAX_SPELL_SCHOOLS do
            spellPower = min(spellPower, GetSpellBonusDamage(i));
        end
        spellPower = min(spellPower, GetSpellBonusHealing()) * GetOverrideAPBySpellPower();
        
        text = BreakUpLargeNumbers(spellPower)
        damageBonus = BreakUpLargeNumbers(spellPower / ATTACK_POWER_MAGIC_NUMBER);
    else
        text = formatWithBuffs(effectiveAP, base, posBuff, negBuff)
        damageBonus = BreakUpLargeNumbers(effectiveAP / ATTACK_POWER_MAGIC_NUMBER)
    end
    
    if (GetOverrideSpellPowerByAP() ~= nil) then
        text = text .. format(" (DPS +%s, SP +%s)",
            damageBonus,
            BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5)
        )
    else
        text = text .. format(" (DPS +%s)", damageBonus)
    end
    
    addStat(lines, tag, text)
end

-- Attack Speed
local function addAttackSpeed(lines, unit)
    local meleeHaste = GetMeleeHaste();
    local speed, offhandSpeed = UnitAttackSpeed(unit);
    if offhandSpeed then
        addFStat(lines, "Attack Speed", "%s / %s (Haste +%s%%%%)",
            BreakUpLargeNumbers(speed),
            BreakUpLargeNumbers(offhandSpeed),
            BreakUpLargeNumbers(meleeHaste))
    else
        addFStat(lines, "Attack Speed", "%s (Haste +%s%%%%)",
            BreakUpLargeNumbers(speed),
            BreakUpLargeNumbers(meleeHaste))
    end
end

-- Power Regen (Energy/Focus)
local function addPowerRegen(lines, unit)
    if unit ~= "player" then return end
    local powerType, powerToken = UnitPowerType(unit);
    if powerToken == "ENERGY" or powerToken == "FOCUS" then
        local regenRate = GetPowerRegen()
        addStat(lines, _G[powerToken] .. " Regen",
            BreakUpLargeNumbers(regenRate))
    end
end

-- Rune Regen
local function addRuneRegen(lines, unit)
    if not (unit == "player" and select(2, UnitClass(unit)) == "DEATHKNIGHT") then
        return
    end
    local _, regenRate = GetRuneCooldown(1); -- Assuming they are all the same for now
    addStat(lines, "Rune Speed", BreakUpLargeNumbers(regenRate) .. "s")
end

-- Spell Power
local function addSpellPower(lines, unit)
    local minModifier = 0
    
    if (unit == "player") then
        local holySchool = 2;
        -- Start at 2 to skip physical damage
        minModifier = GetSpellBonusDamage(holySchool);
        
        for i=(holySchool+1), MAX_SPELL_SCHOOLS do
            local bonusDamage = GetSpellBonusDamage(i);
            minModifier = min(minModifier, bonusDamage);
        end
    elseif (unit == "pet") then
        minModifier = GetPetSpellBonusDamage();
    end
    
    addStat(lines, "Spell Power", BreakUpLargeNumbers(minModifier))
end

-- Mana Regen
local function addManaRegen(lines, unit)
    if unit ~= "player" then return end
    if UnitHasMana(unit) then
        local base, combat = GetManaRegen();
        -- All mana regen stats are displayed as mana/5 sec.
        base = BreakUpLargeNumbers(floor( base * 5.0 ));
        combat = BreakUpLargeNumbers(floor( combat * 5.0 ));
        
        addFStat(lines, "Mana Regen", "%s (Noncombat %s)", combat, base)
    else
        addStat(lines, "Mana Regen", "N/A")
    end
end

-- Armor
local function addArmor(lines, unit)
    local baselineArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit)
    local bonusArmor = UnitBonusArmor(unit);
    local nonBonusArmor = effectiveArmor - bonusArmor;
    
    if ( nonBonusArmor < baselineArmor) then
        baselineArmor = nonBonusArmor
    end
    
    local level = UnitEffectiveLevel(unit)
    local baseArmorReduction = GetArmorEffectiveness(baselineArmor, level) * 100;
    local armorReduction = GetArmorEffectiveness(effectiveArmor, level) * 100;
    
    local baseString = ""
    if baseArmorReduction ~= armorReduction then
        baseString = format(" (Base %.2f%%%%)", baseArmorReduction)
    end
    local petString = ""
    if unit == "player" then
        local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor)
        if petBonus > 0 then
            petString = format(" (Pet +%s)", BreakUpLargeNumbers(floor(petBonus)))
        end
    end
    addFStat(lines, "Armor", "%s / %.2f%%%%%s%s",
        BreakUpLargeNumbers(effectiveArmor),
        armorReduction,
        baseString,
    petString)
end

-- Dodge
local function addDodge(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Dodge", GetDodgeChance(), CR_DODGE)
end

-- Parry
local function addParry(lines, unit)
    if unit ~= "player" then return end
    addRatingStat(lines, "Parry", GetParryChance(), CR_PARRY)
end

-- Block
local function addBlock(lines, unit)
    if unit ~= "player" then return end
    local text = format("%s (Stops %d%%%%)",
        formatRatingStat(GetBlockChance(), CR_BLOCK),
        GetShieldBlock())
    addStat(lines, "Block", text)
end

-- Main function that calls the individual stat getters.
-- Obtain all the stats and build a formatted string.
local function makeStatsString(unit)
    -- Clear all lines
    wipe(lines)
    
    -- Category: General
    addHeader(lines, "General")
    addHealth(lines, unit)
    addPower(lines, unit)
    addItemLevel(lines, unit)
    addMovementSpeed(lines, unit)
    
    -- Category: Primary Stats
    if unit == "player" then
        addHeader(lines, "Primary Stats")
        addPrimaryStat(lines, unit, LE_UNIT_STAT_STRENGTH)
        addPrimaryStat(lines, unit, LE_UNIT_STAT_AGILITY)
        addPrimaryStat(lines, unit, LE_UNIT_STAT_INTELLECT)
        addPrimaryStat(lines, unit, LE_UNIT_STAT_STAMINA)
    end
    
    -- Category: Secondary Stats
    if unit == "player" then
        addHeader(lines, "Secondary Stats")
        addCrit(lines, unit)
        addHaste(lines, unit)
        addMastery(lines, unit)
        addVersatility(lines, unit)
    end
    
    -- Category: Tertiary Stats
    if unit == "player" then
        addHeader(lines, "Tertiary Stats")
        addLifesteal(lines, unit)
        addAvoidance(lines, unit)
        addSpeed(lines, unit)
    end
    
    -- Category: Attack
    addHeader(lines, "Attack")
    addAttackDamage(lines, unit)
    addAttackPower(lines, unit)
    addAttackSpeed(lines, unit)
    addPowerRegen(lines, unit)
    addRuneRegen(lines, unit)
    
    -- Category: Spell
    addHeader(lines, "Spell")
    addSpellPower(lines, unit)
    addManaRegen(lines, unit)
    
    -- Category: Defense
    addHeader(lines, "Defense")
    addArmor(lines, unit)
    addDodge(lines, unit)
    addParry(lines, unit)
    addBlock(lines, unit)
    
    -- Concatenate the lines, return the result
    return table.concat(lines, "\n")
end

----- Display and main loop -----

-- Background
R.bg = R.bg or R:CreateTexture("LegionStatsPaneBg", "BACKGROUND")
R.bg:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White")
R.bg:ClearAllPoints()
R.bg:SetVertexColor(unpack(bgColor))
R.bg:SetPoint("BOTTOMLEFT", R, "BOTTOMLEFT", -2, -3)
R.bg:SetPoint("TOPRIGHT", R, "TOPRIGHT", -1, 0)
R.bg:Show()

-- Custom text
local lastRefresh = 0
local refreshInterval = 1/refreshRate
local customText = ""

-- Return a new custom text string
local function makeCustomText()
    -- Normally I'd make the pet stats appear when you're viewing
    -- the pet stats pane, but they removed it for Legion.
    -- So pet stats will also appear when you're targeting your pet.
    if UnitIsUnit("target", "pet") then
        return makeStatsString("pet")
    else
        return makeStatsString("player")
    end
end

local function refreshText()
    lastRefresh = GetTime()
    customText = makeCustomText()
end

-- Positioning and visibility

-- Hack to prevent WeakAuras itself from moving the frame
R.allowMove = (anchorBehavior == ANCHOR_FIXED)

R.shouldShow = CharacterStatsPane and CharacterStatsPane:IsVisible()

-- Anchor the WeakAura according to anchorBehavior
local function doAnchor()
    if anchorBehavior == ANCHOR_FIXED then
        -- No auto-anchoring
        return
    elseif anchorBehavior == ANCHOR_RIGHT then
        -- Anchors the text display to the right of the character frame,
        -- and flush with the top.
        if not CharacterFrame then return end
        R.allowMove = true
        R:ClearAllPoints()
        R:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", 0, 0)
        R.allowMove = false
    elseif anchorBehavior == ANCHOR_OVERLAY then
        -- Anchors the text display in front of the Blizzard stats pane
        -- by anchoring the top left corners.
        if not CharacterFrameInsetRight then return end
        R.allowMove = true
        R:SetParent(CharacterFrameInsetRight)
        R:ClearAllPoints()
        R:SetPoint("TOPLEFT", CharacterStatsPane, "TOPLEFT", 0, 0)
        R.allowMove = false
    end
end

function A.onUpdateTrigger()
    if R.shouldShow then
        if GetTime() - lastRefresh > refreshInterval then
            refreshText()
        end
    end
    return R.shouldShow
end

function A.doCustomText()
    return customText
end

-- Set up hooks

R.hooks = {}

function R.hooks.CharacterStatsPane_OnShow()
    R.shouldShow = true
end

function R.hooks.CharacterStatsPane_OnHide()
    R.shouldShow = false
end

function R.hooks.R_OnShow()
    if anchorBehavior == ANCHOR_OVERLAY then
        CharacterStatsPane:SetAlpha(0)
    end
    refreshText()
    doAnchor()
end

function R.hooks.R_OnHide()
    if anchorBehavior == ANCHOR_OVERLAY then
        CharacterStatsPane:SetAlpha(1)
    end
end

function R.hooks.R_ClearAllPoints(...)
    if R.allowMove then
        R.originals.R_ClearAllPoints(...)
    end
end

function R.hooks.R_SetPoint(...)
    if R.allowMove then
        R.originals.R_SetPoint(...)
    end
end

function R.hooks.R_SetParent(...)
	if R.allowMove then
		R.originals.R_SetParent(...)
	end
end

local function hookStub(name)
    return function(...)
        local f = R.hooks[name]
        if type(f) ~= "function" then
            errorf('%s: R.hooks["%s"] is %s', A.id, tostring(name), tostring(f))
        end
        f(...)
    end
end

if not R.hooked then
    R.originals = {
        R_ClearAllPoints = R.ClearAllPoints,
        R_SetPoint = R.SetPoint,
        R_SetParent = R.SetParent
    }
    CharacterStatsPane:HookScript("OnShow", hookStub("CharacterStatsPane_OnShow"))
    CharacterStatsPane:HookScript("OnHide", hookStub("CharacterStatsPane_OnHide"))
    R:HookScript("OnShow", hookStub("R_OnShow"))
    R:HookScript("OnHide", hookStub("R_OnHide"))
    R.ClearAllPoints = hookStub("R_ClearAllPoints")
    R.SetPoint = hookStub("R_SetPoint")
    R.SetParent = hookStub("R_SetParent")
    R.hooked = true
    
    R.hooks.R_OnShow()
end
