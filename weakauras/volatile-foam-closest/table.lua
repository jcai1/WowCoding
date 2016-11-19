{
  a = {},
  c = {
    {
      actions = {
        init = {
          custom = "---- ToV/02GUA/Volatile Foam Closest ----\nlocal A = aura_env\nlocal guarmColors = {\n    {debuff = \"Fiery Phlegm\",   foam = \"Flaming Volatile Foam\", color = \"Orange\", code = \"ff8800\"},\n    {debuff = \"Salty Spittle\",  foam = \"Briney Volatile Foam\",  color = \"Green\",  code = \"00ffaa\"},\n    {debuff = \"Dark Discharge\", foam = \"Shadowy Volatile Foam\", color = \"Purple\", code = \"aa55aa\"}\n}\nlocal FRC = {} -- Friendly Range Check\nlocal noneColorCode = \"ffffff\"\nlocal unsafeColorCode = \"ff2222\"\nlocal maxSafeNearbyShown = 2\nlocal maxUnsafeNearbyShown = 2\n\nlocal refreshInterval = 0.15\nlocal lastRefresh = 0\nlocal customText = \"\"\n\nlocal function colorize(colorCode, str)\n    return format(\"|cff%s%s|r\", colorCode, str)\nend\n\nlocal function checkColor(unit)\n    for _, c in ipairs(guarmColors) do\n        if UnitDebuff(unit, c.debuff) then\n            return c\n        end\n    end\nend\n\nlocal function refresh(foamColor)\n    local youLine = colorize(foamColor.code, format(\"%s on YOU!\", foamColor.color))\n    local youColor = checkColor(\"player\")\n    if (not youColor) or (foamColor == youColor) then\n        return youLine..\"\\n\"..\"Foam color matches!\"\n    end\n    \n    local safeNearby, unsafeNearby = {}, {}\n    local extraSafeNearby, extraUnsafeNearby = 0, 0\n    \n    local closestUnits, closestRange = FRC:GetClosestInGroup()\n    for i, unit in ipairs(closestUnits) do\n        local theirColor  = checkColor(unit)\n        local colorCode = theirColor and theirColor.code or noneColorCode\n        local str = colorize(colorCode, tostring(UnitName(unit)))\n        \n        if theirColor == foamColor or not theirColor then\n            if #safeNearby < maxSafeNearbyShown then\n                tinsert(safeNearby, str)\n            else\n                extraSafeNearby = extraSafeNearby + 1\n            end\n        else\n            if #unsafeNearby < maxUnsafeNearbyShown then\n                tinsert(unsafeNearby, str)\n            else\n                extraUnsafeNearby = extraUnsafeNearby + 1\n            end\n        end\n    end\n    \n    safeNearby = table.concat(safeNearby, \" \")\n    safeNearby = colorize(foamColor.code,  \"Safe: \")..safeNearby\n    if extraSafeNearby > 0 then\n        safeNearby = safeNearby..colorize(foamColor.code, \" +\"..extraSafeNearby)\n    end\n    \n    if #unsafeNearby == 0 and extraUnsafeNearby == 0 then\n        customText = youLine..\"\\n\"..safeNearby\n        return\n    end\n    \n    unsafeNearby = table.concat(unsafeNearby, \" \")\n    unsafeNearby = colorize(unsafeColorCode, \"Unsafe: \")..unsafeNearby\n    if extraUnsafeNearby > 0 then\n        unsafeNearby = unsafeNearby..colorize(unsafeColorCode, \" +\"..extraUnsafeNearby)\n    end\n    customText = youLine..\"\\n\"..safeNearby..\"\\n\"..unsafeNearby\n    return\nend\n\nfunction A.statusTrigger()\n    local foamColor\n    for _, c in ipairs(guarmColors) do\n        if UnitDebuff(\"player\", c.foam) then\n            foamColor = c\n            break\n        end\n    end\n    \n    local now = GetTime()\n    if foamColor then\n        if now - lastRefresh > refreshInterval then\n            lastRefresh = now\n            refresh(foamColor)\n        end\n        return true\n    else\n        customText = \"\"\n        return false\n    end\nend\n\nfunction A.customTextFunc()\n    return customText\nend\n\n---- Friendly Range Check ----\nFRC.items = {\n    {1,    90175},\n    {2,    63390},\n    {3,    42732},\n    {4,    129055},\n    {5,    85267},\n    {7,    88589},\n    {8,    68678},\n    {10,   79884},\n    {15,   20235},\n    {20,   88587},\n    {25,   74771},\n    {30,   22218},\n    {35,   41505},\n    {40,   52490},\n    {45,   62794},\n    {50,   116139},\n    {55,   74637},\n    {60,   50851},\n    {70,   41265},\n    {80,   42769},\n    {90,   133925},\n    {100,  109082},\n    {200,  86546},\n}\n\nFRC.raidUnits, FRC.partyUnits, FRC.noUnits = {}, {}, {}\nfor i = 1, MAX_RAID_MEMBERS do\n    FRC.raidUnits[i] = \"raid\"..i\nend\nfor i = 1, MAX_PARTY_MEMBERS do\n    FRC.partyUnits[i] = \"party\"..i\nend\n\n-- Range(0) = 0, Range(N+1) = infinity\n-- 0 <= i <= N\n-- range index <= i : unit is below Range(i+1)\n-- range index >= i : unit is above Range(i)\n-- range index == i : unit is between Range(i) and Range(i+1)\n\n-- Returns true if unit's range index < threshold.\n-- threshold may be fractional or infinite.\nfunction FRC:RangeBelow(unit, threshold)\n    local N = #self.items\n    if threshold <= 0 then\n        return false\n    elseif threshold > N then\n        return true\n    else\n        threshold = ceil(threshold)\n        local itemID = self.items[threshold][2]\n        return IsItemInRange(itemID, unit)\n    end\nend\n\n-- Implementation of binary search to find the unit's range index.\n-- Precondition (lb <= unit's range index <= ub) must be met.\n-- lb: inclusive lower bound\n-- ub: inclusive upper bound\n-- recdepth: current recursion depth (safety check)\nfunction FRC:_BSearch(unit, lb, ub, recdepth)\n    assert(recdepth < 100)\n    assert(lb <= ub)\n    if lb == ub then\n        return lb\n    end\n    local mid = ceil((lb + ub) / 2)\n    if self:RangeBelow(unit, mid) then\n        return self:_BSearch(unit, lb, mid - 1, recdepth + 1)\n    else\n        return self:_BSearch(unit, mid, ub, recdepth + 1)\n    end\nend\n\n-- Finds the unit's range index, if between lb and ub.\n-- lb: Optional, inclusive lower bound.\n--     Returns lb - 1 if unit's range index < lb.\n-- ub: Optional, inclusive upper bound.\n--     Returns ub + 1 if unit's range index > ub.\nfunction FRC:FindRange(unit, lb, ub)\n    local N = #self.items\n    lb = lb or 0\n    ub = ub or N\n    if self:RangeBelow(unit, lb) then\n        return lb - 1\n    end\n    if not self:RangeBelow(unit, ub + 1) then\n        return ub + 1\n    end\n    return self:_BSearch(unit, lb, ub, 0)\nend\n\nfunction FRC:GetClosestInGroupAux(scanUnits)\n    local N = #self.items\n    local closestUnits = {}\n    local closestRange = N\n    for _, unit in ipairs(scanUnits) do\n        if UnitIsVisible(unit) and not UnitIsUnit(unit, \"player\") then\n            local range = self:FindRange(unit, nil, closestRange)\n            if range < closestRange then\n                closestRange = range\n                wipe(closestUnits)\n                tinsert(closestUnits, unit)\n            elseif range == closestRange then\n                tinsert(closestUnits, unit)\n            end\n        end\n    end\n    return closestUnits, closestRange\nend\n\nfunction FRC:GetClosestInGroup()\n    if IsInRaid() then\n        return self:GetClosestInGroupAux(self.raidUnits)\n    elseif IsInGroup() then\n        return self:GetClosestInGroupAux(self.partyUnits)\n    else\n        return self:GetClosestInGroupAux(self.noUnits)\n    end\nend",
          do_custom = true
        },
        start = {
          do_sound = true,
          sound = " custom",
          sound_path = "Sound/creature/Nightborne_Male_Caster/VO_703_Nightborne_Male_Caster_05.ogg"
        }
      },
      activeTriggerMode = -10,
      customText = "function() return aura_env.customTextFunc() end",
      desc = "Arc v1.1 2016-11-16",
      disjunctive = "all",
      displayText = "%c",
      font = "Fira Mono Medium",
      fontSize = 16,
      height = 16,
      id = "ToV/02GUA/Volatile Foam Closest Text",
      load = {
        encounterid = "1962",
        size = {
          single = "twenty"
        },
        use_encounterid = true,
        use_size = true
      },
      numTriggers = 1,
      regionType = "text",
      trigger = {
        check = "update",
        custom = "function() return aura_env.statusTrigger() end",
        custom_hide = "timed",
        custom_type = "status",
        type = "custom"
      },
      untrigger = {
        custom = "function() return true end"
      },
      width = 8
    }
  },
  d = {
    activeTriggerMode = -10,
    background = "Blizzard Dialog Background",
    borderOffset = 6,
    disjunctive = "all",
    expanded = true,
    height = 16,
    id = "ToV/02GUA/Volatile Foam Closest",
    numTriggers = 1,
    regionType = "dynamicgroup",
    selfPoint = "TOP",
    space = 0,
    width = 8
  },
  m = "d",
  s = "2.2.2.1",
  v = 1421
}
