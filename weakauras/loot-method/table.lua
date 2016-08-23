{
  d = {
    actions = {
      init = {
        custom = "----- Loot Method (Init) -----\nlocal A = aura_env\nlocal now\n\n----- Set options here -----\nlocal refreshRate = 5\nlocal methodStrings = {\n    [\"freeforall\"] = \"Free for All\",\n    [\"group\"] = \"Group\",\n    [\"master\"] = \"Master\",\n    [\"personalloot\"] = \"Personal\",\n    [\"roundrobin\"] = \"Round Robin\",\n}\nlocal nonMasterColor = \"ff4242\"\n\n----- Custom text -----\nlocal customText = \"\"\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\n\nlocal function makeCustomText()\n    if WeakAuras.IsOptionsOpen() then return \"Loot: ----------\" end\n    local method, partyMaster, raidMaster = GetLootMethod()\n    if not method then return end\n    local methodString = methodStrings[method] or method\n    if method == \"master\" then\n        local masterLooter\n        if partyMaster then\n            masterLooter = UnitName(partyMaster == 0 and \"player\" or \"party\"..partyMaster)\n        elseif raidMaster then\n            masterLooter = UnitName(\"raid\"..raidMaster)\n        end\n        return format(\"Loot: %s (%s)\", methodString, tostring(masterLooter))\n    else\n        return format(\"Loot: |cff%s%s (!)|r\", nonMasterColor, methodString)\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        customText = makeCustomText() or \"\"\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {},
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v0.0 2016-08-10",
    disjunctive = "all",
    displayText = "%c",
    fontSize = 14,
    height = 14.000039100646973,
    id = "Loot Method",
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
      size = {
        multi = {
          flexible = true,
          fortyman = true,
          ten = true,
          twenty = true,
          twentyfive = true
        }
      },
      talent = {
        multi = {}
      },
      use_size = false
    },
    numTriggers = 1,
    regionType = "text",
    selfPoint = "TOPLEFT",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    width = 103.99998474121094
  },
  m = "d",
  s = "2.2.1.0",
  v = 1421
}
