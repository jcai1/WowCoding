{
  d = {
    actions = {
      init = {
        custom = "----- Gigantic Anger -----\nlocal A = aura_env\n\n----- Set options here -----\nlocal refreshRate = 20\nlocal activeColor = \"ff6969\"\n\n----- Custom text -----\nlocal customText = \"\"\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\n\n----- Main logic -----\nlocal furyTotal = 0\nlocal inCombat = UnitAffectingCombat(\"player\")\n\n----- Utility -----\nlocal now\nlocal playerGUID = UnitGUID(\"player\")\n\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if  inCombat\n    and destGUID == playerGUID\n    and subEvent == \"SPELL_ENERGIZE\"\n    and ... == 208828\n    then\n        furyTotal = furyTotal + select(4, ...)\n    end\nend\n\nlocal function onEnteringCombat()\n    inCombat = true\n    furyTotal = 0\nend\n\nlocal function onLeavingCombat()\n    inCombat = false\nend\n\nlocal function onUpdate()\n    local newInCombat = UnitAffectingCombat(\"player\")\n    if inCombat and not newInCombat then onLeavingCombat()\n    elseif not inCombat and newInCombat then onEnteringCombat()\n    end\nend\n\nlocal function makeCustomText()\n    if WeakAuras.IsOptionsOpen() then return \"1000\" end\n    if inCombat then return format(\"|cff%s%d|r\", activeColor, furyTotal)\n    else return format(\"%d\", furyTotal)\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    onUpdate()\n    if now - lastRefresh > refreshInterval then\n        customText = makeCustomText() or \"\"\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText\n\nlocal dispatch = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n    [\"PLAYER_REGEN_DISABLED\"] = onEnteringCombat,\n    [\"PLAYER_REGEN_ENABLED\"] = onLeavingCombat,\n}\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    dispatch[event](...)\n    return true\nend\nA.doTrigger = doTrigger",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {},
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v0.0 2016-08-10",
    disjunctive = "all",
    displayText = "%c",
    fontSize = 18,
    height = 18.000003814697266,
    id = "Gigantic Anger",
    init_completed = 1,
    load = {
      class = {
        single = "DEMONHUNTER"
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
        multi = {}
      },
      use_class = true,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "text",
    selfPoint = "BOTTOMLEFT",
    trigger = {
      custom = "function(...) return aura_env.doTrigger(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED,PLAYER_REGEN_DISABLED,PLAYER_REGEN_ENABLED",
      type = "custom"
    },
    width = 50.999984741210938
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}