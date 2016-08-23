{
  d = {
    actions = {
      init = {
        custom = "----- WeakAura Name (Init) -----\nlocal A = aura_env\nlocal R = WeakAuras.regions[A.id].region\nlocal S = WeakAurasSaved.displays[A.id]\n\n----- Set options here -----\nlocal refreshRate = 30\n\n----- Custom text -----\nlocal customText = \"\"\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\nlocal exsangIconString = \"|TInterface\\\\Icons\\\\ability_deathwing_bloodcorruption_earth:0|t\"\n\n----- Main logic -----\n--[[\n    [damage] and not [end]: ongoing accumulation\n    [damage] and     [end]: accumulation ended, but still displaying value\nnot [damage] and     [end]: accumulation ended, no longer displaying value\n]]\nlocal exsangTime = -999\nlocal exsangTarget = \"Dummy\"\nlocal bleedDamage\nlocal ruptureLastTick, ruptureEnd\nlocal garroteLastTick, garroteEnd\n\n----- Utility -----\nlocal now  -- Current value of GetTime()\nlocal playerGUID = UnitGUID(\"player\")\nlocal exsangIconString = \"|TInterface\\\\Icons\\\\ability_deathwing_bloodcorruption_earth:0|t\"\n\n-- pretty-print damage amount\nlocal function damagePP(amt)\n    if amt < 10000 then -- 0 to 9999\n        return format(\"%.f\", amt)\n    elseif amt < 99950 then -- 10.0k to 99.9k\n        return format(\"%.1fk\", amt / 1000)\n    elseif amt < 999500 then -- 100k to 999k\n        return format(\"%.fk\", amt / 1000)\n    else -- 1.00m +\n        return format(\"%.2fm\", amt / 1000000)\n    end\nend\n\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if sourceGUID == playerGUID then\n        if ... == 1943 and destGUID == exsangTarget and not ruptureEnd then\n            if subEvent == \"SPELL_PERIODIC_DAMAGE\" then\n                local damage, overkill = select(4, ...)\n                bleedDamage = bleedDamage + damage - overkill\n                ruptureLastTick = now\n            elseif subEvent == \"SPELL_AURA_REMOVED\" or subEvent == \"SPELL_AURA_REFRESH\" or subEvent == \"SPELL_AURA_APPLIED\" then\n                ruptureEnd = now\n            end\n        elseif ... == 703 and destGUID == exsangTarget and not garroteEnd then\n            if subEvent == \"SPELL_PERIODIC_DAMAGE\" then\n                local damage, overkill = select(4, ...)\n                bleedDamage = bleedDamage + damage - overkill\n                garroteLastTick = now\n            elseif subEvent == \"SPELL_AURA_REMOVED\" or subEvent == \"SPELL_AURA_REFRESH\" or subEvent == \"SPELL_AURA_APPLIED\" then\n                garroteEnd = now\n            end\n        elseif ... == 200806 and subEvent == \"SPELL_CAST_SUCCESS\" then\n            exsangTime = now\n            exsangTarget = destGUID\n            bleedDamage = 0\n            ruptureLastTick = now -- not really, but doesn't matter\n            garroteLastTick = now\n            ruptureEnd = nil\n            garroteEnd = nil\n        end\n    end\nend\n\nlocal function makeCustomText()\n    if not bleedDamage then return end\n    if not ruptureEnd and now - ruptureLastTick > 4 then\n        ruptureEnd = now - 4\n    end\n    if not garroteEnd and now - garroteLastTick > 4 then\n        garroteEnd = now - 4\n    end\n    if ruptureEnd and garroteEnd and now - max(ruptureEnd, garroteEnd) > 3 then\n        bleedDamage = nil\n        return\n    end\n    local damageStr = damagePP(bleedDamage)\n    if not (ruptureEnd and garroteEnd) then\n        damageStr = \"|cffff6699\"..damageStr..\"|r\"\n    end\n    return exsangIconString..damageStr\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        customText = makeCustomText() or \"\"\n        if customText == \"\" and WeakAuras.IsOptionsOpen() then\n            customText = exsangIconString..\"100.0k\"\n        end\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText\n\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    onCombatEvent(...)\n    return true\nend\nA.doTrigger = doTrigger",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v0.1 2016-07-26",
    disjunctive = "all",
    displayText = "%c",
    fontSize = 20,
    height = 20.000017166137695,
    id = "Exsang Damage",
    init_completed = 1,
    load = {
      class = {
        single = "ROGUE"
      },
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      pvptalent = {
        multi = {}
      },
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      spec = {
        single = 1
      },
      talent = {
        multi = {},
        single = 18
      },
      use_class = true,
      use_spec = true,
      use_talent = true
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function(...) return aura_env.doTrigger(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 92.999977111816406,
    yOffset = 50.000244140625
  },
  m = "d",
  s = "2.2.0.8",
  v = 1421
}
