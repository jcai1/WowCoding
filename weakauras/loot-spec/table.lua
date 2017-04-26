{
  d = {
    actions = {
      init = {
        custom = "----- Loot Spec (Init) -----\nlocal A = aura_env\nlocal now\n\n----- Set options here -----\nlocal refreshRate = 5\n\n----- Custom text -----\nlocal customText = \"\"\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\n\nlocal AFFLICTION, DEMONOLOGY, DESTRUCTION = \"Affliction\", \"Demonology\", \"Destruction\"\nlocal DEFAULT = DESTRUCTION\nlocal flashColors = {\"ff4242\", \"ffff00\"}\n\nlocal targetSpecs = {\n}\n\nlocal function makeCustomText()\n    local lootSpecID = GetLootSpecialization()\n    local _, name, icon, star\n    if lootSpecID == 0 then\n        local spec = GetSpecialization()\n        _, name, _, icon = GetSpecializationInfo(spec)\n        star = \"*\"\n    else\n        _, name, _, icon = GetSpecializationInfoByID(lootSpecID)\n        star = \"\"\n    end\n    local intendedSpec = targetSpecs[UnitName(\"target\")]\n    if name and intendedSpec and name ~= intendedSpec then\n        local t = 1 + floor(GetTime()) % 2\n        star = star..string.rep(format(\"\\n|cff%s!!! SHOULD BE %s !!!|r\", flashColors[t], intendedSpec), 5)\n    end\n    return format(\"|T%s:0|t%s\", icon, star)\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        customText = makeCustomText() or \"\"\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    additional_triggers = {},
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v1.0 2017-04-26",
    displayText = "[Loot:%c]",
    font = "FrancoisOne",
    fontSize = 15,
    id = "Loot Spec",
    justify = "RIGHT",
    numTriggers = 1,
    regionType = "text",
    selfPoint = "LEFT",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    }
  },
  m = "d",
  s = "2.4.1",
  v = 1421
}
