{
  d = {
    actions = {
      init = {
        custom = "----- Demonwrath Targets -----\nlocal A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\nlocal playerGUID = UnitGUID(\"player\")\n\n----- Set options here -----\nlocal refreshThrottle = 100\n\n----- Utility -----\nlocal now\nlocal refreshInterval = 1 / refreshThrottle\nlocal lastRefresh     = -refreshInterval - 1\nlocal customText\nlocal shouldShow      = true\nlocal isOptionsOpen   = WeakAuras.IsOptionsOpen\nlocal playerGUID      = UnitGUID(\"player\")\n\n----- GUI -----\nlocal widgetName    = \"DemonwrathTargets\"\nlocal squareTexture = \"Interface\\\\AddOns\\\\WeakAuras\\\\Media\\\\Textures\\\\Square_White\"\n\n----- Main logic -----\nlocal state = \"ready\"  -- ready, collect\nlocal counter = 0\nlocal lastTransition = -999\n\nlocal function initGUI()\n    local bgName = widgetName..\"BG\"\n    \n    R.bg = R.bg or R:CreateTexture(bgName, \"MEDIUM\")\n    R.bg:ClearAllPoints()\n    R.bg:SetAllPoints(R)\n    R.bg:SetTexture(\"Interface\\\\Icons\\\\spell_warlock_demonwrath\")\n    R.bg:SetVertexColor(1, 1, 1, 0)\n    R.bg:Show()\n    \n    R.bgAnimGroup = R.bgAnimGroup or R.bg:CreateAnimationGroup(bgName..\"AnimGroup\")\n    R.bgAnim = R.bgAnim or R.bgAnimGroup:CreateAnimation(\"Alpha\", bgName..\"Anim\")\n    R.bgAnim:SetFromAlpha(1)\n    R.bgAnim:SetToAlpha(0)\n    R.bgAnim:SetDuration(0.25)\n    R.bgAnim:SetSmoothing(\"IN\")\nend\n\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,\n    destGUID, destName, destFlags, _, spellID, spellName, _, ...)\n    \n    if sourceGUID == playerGUID and subEvent == \"SPELL_DAMAGE\" and spellID == 193439 then\n        if state == \"ready\" then\n            state = \"collect\"\n            counter = 0\n            lastTransition = now\n            R.bgAnim:SetDuration(0.5 / (1 + .01 * GetHaste()))\n            R.bgAnimGroup:Play()\n        end\n        if state == \"collect\" then\n            counter = counter + 1\n        end\n    end\nend\n\nlocal function onRefresh()\n    if state == \"collect\" then\n        if now - lastTransition > 0.20 then\n            state = \"ready\"\n            lastTransition = now\n        end\n        customText = tostring(counter)\n    elseif state == \"ready\" then\n        customText = (now - lastTransition < 2.0) and tostring(counter) or \"\"\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh >= refreshInterval then\n        onRefresh()\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText\n\nlocal triggerDispatch = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n}\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    triggerDispatch[event](...)\n    return shouldShow\nend\nA.doTrigger = doTrigger\n\ninitGUI()",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {},
    color = {
      0.243137254901961,
      0.243137254901961,
      0.243137254901961
    },
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v1.0 2016-08-24",
    disjunctive = "all",
    displayIcon = 1378284,
    displayStacks = "%c",
    displayText = "%c",
    fontSize = 20,
    frameStrata = 3,
    height = 43,
    id = "Demonwrath Targets",
    init_completed = 1,
    justify = "LEFT",
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
        single = 2
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_spec = true
    },
    numTriggers = 1,
    outline = "OUTLINE",
    regionType = "icon",
    selfPoint = "TOPLEFT",
    stacksPoint = "CENTER",
    trigger = {
      custom = "function(...) return aura_env.doTrigger(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 43,
    xOffset = -548,
    yOffset = 288.99993896484398
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}
