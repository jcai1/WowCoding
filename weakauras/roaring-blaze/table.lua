{
  d = {
    actions = {
      init = {
        custom = "----- Roaring Blaze -----\nlocal A = aura_env\n-- local R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\nlocal playerGUID = UnitGUID(\"player\")\n\n----- Set options here -----\nlocal refreshRate = 20\n\n----- Utility -----\nlocal now\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh     = -refreshInterval - 1\nlocal customText\nlocal shouldShow      = true\nlocal isOptionsOpen   = WeakAuras.IsOptionsOpen\nlocal playerGUID      = UnitGUID(\"player\")\n\n----- Main logic -----\nlocal rbCounts = {}\nlocal rbMults = {\n    [0] = \"1.00\",\n    [1] = \"1.25\",\n    [2] = \"1.56\",\n    [3] = \"1.95\",\n    [4] = \"2.44\",\n    [5] = \"3.05\",\n    [6] = \"3.81\",\n    [7] = \"4.77\",\n}\n\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,\n    destGUID, destName, destFlags, _, spellID, spellName, _, ...)\n    \n    if spellID == 17962 then\n        if subEvent == \"SPELL_DAMAGE\" then\n            rbCounts[destGUID] = (rbCounts[destGUID] or 0) + 1\n        end\n    elseif spellID == 157736 then\n        if strsub(subEvent, 1, 11) == \"SPELL_AURA_\" then\n            rbCounts[destGUID] = (subEvent ~= \"SPELL_AURA_REMOVED\") and 0 or nil\n        end\n    end\nend\n\nlocal function onRefresh()\n    if UnitDebuff(\"target\", \"Immolate\", nil, \"PLAYER\") then\n        customText = rbMults[rbCounts[UnitGUID(\"target\")]] or \"???\"\n    else\n        customText = isOptionsOpen() and \"1.00\" or \"\"\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh >= refreshInterval then\n        onRefresh()\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText\n\nlocal triggerDispatch = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n}\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    triggerDispatch[event](...)\n    return shouldShow\nend\nA.doTrigger = doTrigger\n\n",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {},
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v0.1 2016-11-15",
    disjunctive = "all",
    displayText = "%c\n%i",
    font = "FrancoisOne",
    fontSize = 16,
    frameStrata = 4,
    height = 31.999975204467773,
    id = "Roaring Blaze",
    init_completed = 1,
    justify = "CENTER",
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
        multi = {},
        single = 2
      },
      use_class = true,
      use_spec = true,
      use_talent = true
    },
    numTriggers = 1,
    outline = "THICKOUTLINE",
    regionType = "text",
    trigger = {
      custom = "function(...) return aura_env.doTrigger(...) end",
      customIcon = "function() return \"Interface\\\\Icons\\\\ability_warlock_inferno\" end",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 41.000041961669922,
    xOffset = -631,
    yOffset = 184
  },
  m = "d",
  s = "2.2.2.1",
  v = 1421
}
