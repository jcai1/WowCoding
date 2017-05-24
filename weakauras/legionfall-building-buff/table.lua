{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal displayText = \"\"\n\nlocal buildings = {\n    {name = \"Mage Tower\", contributionID = 1, trackingQuestID = 46793},\n    {name = \"Command Center\", contributionID = 3, trackingQuestID = 46870},\n    {name = \"Nether Disruptor\", contributionID = 4, trackingQuestID = 46871},\n}\n\nlocal outputNames = {}\n\nlocal function refresh()\n    if not IsQuestFlaggedCompleted(46286) then\n        displayText = \"\"\n        return\n    end\n    \n    wipe(outputNames)\n    \n    for _, building in ipairs(buildings) do\n        local state = C_ContributionCollector.GetState(building.contributionID)\n        if (state == 2 or state == 3) and not IsQuestFlaggedCompleted(building.trackingQuestID) then\n            tinsert(outputNames, building.name)\n        end\n    end\n    \n    if #outputNames > 0 then\n        displayText = \"Missing buffs: \"..table.concat(outputNames, \", \")\n    else \n        displayText = \"\"\n    end\nend\n\nlocal lastRefresh = 0\nfunction A.statusTrigger()\n    local now = GetTime()\n    if now - lastRefresh > 3 then\n        lastRefresh = now\n        refresh()\n    end\n    return true\nend\n\nfunction A.customTextFunc()\n    return displayText\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    customText = "function() return aura_env.customTextFunc() end",
    desc = "Arc v1.0-beta 2017-05-23",
    disjunctive = "all",
    displayText = "%c",
    font = "FrancoisOne",
    fontSize = 20,
    id = "Legionfall Building Buffs",
    load = {
      level = "110",
      level_operator = "==",
      use_level = true
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      check = "update",
      custom = "function() return aura_env.statusTrigger() end",
      custom_type = "status",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    }
  },
  m = "d",
  s = "2.4.2",
  v = 1421
}
