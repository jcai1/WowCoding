{
  d = {
    actions = {
      init = {
        custom = "-- Custom text refresh\nlocal lastTextRefresh = 0\nlocal textRefreshInterval = 0.1\n\n-- Custom text string\nlocal text = \"\"\n\n-- NPC names for summons\nlocal npcs = {\n    \"Lady Jaina Proudmoore\",\n    \"Tyrande Whisperwind\",\n    \"Lady Sylvanas Windrunner\",\n    \"Arthas Menethil\"\n}\n-- How long Temporal Power lasts\nlocal duration = 10.2\n\nlocal npcsDual = {}        -- NPC name -> index\nlocal times = {}        -- Time last summoned\nlocal active = {}        -- Whether summon is active\nfor i = 1, #npcs do\n    local npc = npcs[i]\n    npcsDual[npc] = i\n    times[npc] = 0\n    active[npc] = false\nend\n\n-- Temporal Power stats\nlocal count = 0\nlocal avgExpire = 0\n\nlocal playerGUID = UnitGUID(\"player\")    -- Player GUID\n\nlocal function refreshStats()\n    local t = GetTime()\n    count = 0\n    avgExpire = 0\n    \n    for i = 1, #npcs do\n        local npc = npcs[i]\n        if active[npc] then\n            local elapsed = t - times[npc]\n            if elapsed > 12 then\n                -- Assume it fell off & we didn't catch it somehow\n                active[npc] = false\n            else\n                -- Buff is active\n                local expire = times[npc] + duration\n                count = count + 1\n                avgExpire = avgExpire + max(t, expire)\n            end\n        end\n    end\n    if count > 0 then\n        avgExpire = avgExpire / count\n    end\nend\n\nlocal function doDuration()\n    refreshStats()\n    return duration, avgExpire\nend\naura_env.doDuration = doDuration\n\nlocal function doCombatTrigger(_, _, subEvent, _,\n    sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID)\n    if destGUID == playerGUID and spellID == 190623 then\n        if subEvent == \"SPELL_AURA_APPLIED\" then\n            times[sourceName] = GetTime()\n            active[sourceName] = true\n        else\n            active[sourceName] = false\n        end\n        refreshStats()\n    end\n    return count > 0\nend\naura_env.doCombatTrigger = doCombatTrigger\n\nlocal function refreshText()\n    lastTextRefresh = GetTime()\n    text = tostring(count)\nend\n\nlocal function doText()\n    local t = GetTime()\n    if t - lastTextRefresh > textRefreshInterval then\n        refreshText()\n    end\n    return text\nend\naura_env.doText = doText",
        do_custom = true
      }
    },
    auto = false,
    cooldown = true,
    customText = "function()\n    return aura_env.doText()\nend",
    desc = "Arc v0.1 2016-03-04",
    displayIcon = "Interface\\Icons\\timelesscoin",
    displayStacks = "%c",
    fontSize = 14,
    height = 45,
    id = "Temporal Power",
    init_completed = 1,
    load = {
      class = {
        single = "MAGE"
      },
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      level = "100",
      level_operator = "==",
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
      use_level = true,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "icon",
    selfPoint = "BOTTOM",
    trigger = {
      custom = "function(...)\n    return aura_env.doCombatTrigger(...)\nend",
      customDuration = "function()\n    return aura_env.doDuration()\nend",
      custom_hide = "custom",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 45,
    xOffset = -525.000244140625,
    yOffset = 200
  },
  m = "d",
  s = "2.1.0.21",
  v = 1421
}
