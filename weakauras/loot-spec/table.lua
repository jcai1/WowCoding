{
  d = {
    actions = {
      init = {
        custom = "----- Loot Spec (Init) -----\nlocal A = aura_env\nlocal now\n\n----- Set options here -----\nlocal refreshRate = 5\n\n----- Custom text -----\nlocal customText = \"\"\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\n\nlocal function makeCustomText()\n    local lootSpecID = GetLootSpecialization()\n    local _, name, icon, star\n    if lootSpecID == 0 then\n        local spec = GetSpecialization()\n        _, name, _, icon = GetSpecializationInfo(spec)\n        star = \"*\"\n    else\n        _, name, _, icon = GetSpecializationInfoByID(lootSpecID)\n        star = \"\"\n    end\n    return format(\"Loot: |T%s:0|t %s%s\", icon, name, star)\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        customText = makeCustomText() or \"\"\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v0.0 2016-08-10",
    displayText = "%c",
    fontSize = 20,
    height = 20.000017166137695,
    id = "Loot Spec",
    init_completed = 1,
    load = {
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
      talent = {
        multi = {}
      }
    },
    numTriggers = 1,
    regionType = "text",
    selfPoint = "LEFT",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    width = 216,
    xOffset = -940.46932411193904,
    yOffset = 400.62609863281301
  },
  m = "d",
  s = "2.2.1.0",
  v = 1421
}
