{
  d = {
    actions = {
      init = {
        custom = "----- Fireball Crit Chance -----\nlocal A = aura_env\n-- local R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\n\n----- Set options here -----\nlocal refreshRate = 60\n\n----- Utility -----\nlocal now\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh     = -refreshInterval - 1\nlocal customText\n\nlocal function onRefresh()\n    local baseCrit = GetSpellCritChance()\n    local _, _, _, stacks = UnitBuff(\"player\", \"Enhanced Pyrotechnics\")\n    local crit = min(100, baseCrit + (stacks or 0) * 10)\n    customText = format(\"%d\", crit)\nend\n\nfunction A.doCustomText()\n    now = GetTime()\n    if now - lastRefresh >= refreshInterval then\n        onRefresh()\n        lastRefresh = now\n    end\n    return customText\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v1.0 2016-09-14",
    disjunctive = "all",
    displayText = "%i%c%",
    fontSize = 16,
    height = 15.999987602233887,
    id = "Fireball Crit Chance",
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
        single = 2
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
      check = "update",
      custom = "function() return true end",
      customIcon = "function() return \"Interface\\\\Icons\\\\spell_fire_flamebolt\" end",
      custom_type = "status",
      event = "Conditions",
      type = "custom",
      unevent = "auto",
      use_unit = true
    },
    width = 54.73504638671875,
    xOffset = -480.99996948242187,
    yOffset = 306.00018310546875
  },
  m = "d",
  s = "2.2.1.4",
  v = 1421
}
