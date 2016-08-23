{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal refreshRate = 10\n\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh = -999\nlocal customText\n\nlocal function getLabel()\n    local a = ScenarioObjectiveBlock\n    a = a and a.currentLine\n    a = a and a.Bar\n    return a and a.Label\nend\n\nlocal function makeText()\n    local _, _, numCriteria, _, _, _, _, _, weightedProgress = C_Scenario.GetStepInfo()\n    if numCriteria and numCriteria > 0 then\n        for criteriaIndex = 1, numCriteria do\n            local criteriaString, _, _, quantity, totalQuantity, _, _, quantityString = C_Scenario.GetCriteriaInfo(criteriaIndex)\n            if criteriaString == \"Enemy Forces\" then\n                return format(\"%s/%d (%d%%)\", gsub(quantityString, \"%%$\", \"\"), totalQuantity, quantity)\n            end\n        end\n    end\nend\n\nlocal function doText()\n    local now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        local label = getLabel()\n        if label then\n            local text = makeText()\n            if text then\n                label:SetText(text)\n            end\n        end\n        lastRefresh = now\n    end\nend\nA.doText = doText",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    customText = "function() return aura_env.doText() end",
    desc = "Arc v0.0 2016-08-10",
    displayText = "%c",
    fontSize = 20,
    height = 20.000017166137695,
    id = "Exact Mobcount",
    init_completed = 1,
    load = {
      difficulty = {
        multi = {},
        single = "challenge"
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
        single = "party"
      },
      talent = {
        multi = {}
      },
      use_difficulty = true,
      use_size = true
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
    width = 9.0000019073486328,
    xOffset = -436.00006103515602,
    yOffset = -379.99946594238298
  },
  m = "d",
  s = "2.2.1.0",
  v = 1421
}
