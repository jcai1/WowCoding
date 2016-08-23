{
  d = {
    actions = {
      init = {
        custom = "----- Roaring Blaze -----\nlocal A = aura_env\n-- local R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\nlocal playerGUID = UnitGUID(\"player\")\n\n----- Set options here -----\nlocal refreshRate = 20\n\n----- Utility -----\nlocal now\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh     = -refreshInterval - 1\nlocal customText\nlocal shouldShow      = true\nlocal isOptionsOpen   = WeakAuras.IsOptionsOpen\nlocal playerGUID      = UnitGUID(\"player\")\n\n----- Main logic -----\nlocal rbCounts = {}\nlocal rbMults = {[0] = \"1.00\", [1] = \"1.25\", [2] = \"1.56\", [3] = \"1.95\"}\n\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,\n    destGUID, destName, destFlags, _, spellID, spellName, _, ...)\n    \n    if spellID == 17962 then\n        if subEvent == \"SPELL_DAMAGE\" then\n            rbCounts[destGUID] = (rbCounts[destGUID] or 0) + 1\n        end\n    elseif spellID == 157736 then\n        if strsub(subEvent, 1, 11) == \"SPELL_AURA_\" then\n            rbCounts[destGUID] = (subEvent ~= \"SPELL_AURA_REMOVED\") and 0 or nil\n        end\n    end\nend\n\nlocal function onRefresh()\n    if UnitDebuff(\"target\", \"Immolate\", nil, \"PLAYER\") then\n        customText = rbMults[rbCounts[UnitGUID(\"target\")]] or \"???\"\n    else\n        customText = isOptionsOpen() and \"1.00\" or \"\"\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh >= refreshInterval then\n        onRefresh()\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText\n\nlocal triggerDispatch = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n}\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    triggerDispatch[event](...)\n    return shouldShow\nend\nA.doTrigger = doTrigger\n\n\n",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {},
    customText = "function() return aura_env.doCustomText() end\n\n\n\n",
    desc = "Arc v0.0 2016-08-10",
    disjunctive = "all",
    displayText = "%c",
    fontSize = 16,
    frameStrata = 5,
    height = 15.999987602233887,
    id = "Roaring Blaze",
    init_completed = 1,
    load = {
      class = {
        single = "WARLOCK"
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
        single = 3
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_spec = true
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
    width = 40.999977111816406,
    xOffset = -357.99969482421875,
    yOffset = 413.9998779296875
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}
