{
  d = {
    actions = {
      init = {
        custom = "----- Demonwrath Targets -----\nlocal A = aura_env\nlocal R = WeakAuras.regions[A.id].region\nlocal playerGUID = UnitGUID(\"player\")\nlocal customText = \"\"\n\nlocal state = \"ready\"  -- ready, collect\nlocal counter = 0\nlocal lastTransition = -999\n\nlocal flashName = \"DemonwrathTargetsFlash\"\nR.flash = R.flash or R:CreateTexture(flashName, \"MEDIUM\")\nR.flash:ClearAllPoints()\nR.flash:SetAllPoints(R)\nR.flash:SetTexture(\"Interface\\\\Icons\\\\spell_warlock_demonwrath\")\nR.flash:SetVertexColor(1, 1, 1, 0)\nR.flash:Show()\nR.flashAG = R.flashAG or R.flash:CreateAnimationGroup(flashName..\"AG\")\nR.flashAnim = R.flashAnim or R.flashAG:CreateAnimation(\"Alpha\", flashName..\"Anim\")\nR.flashAnim:SetFromAlpha(1)\nR.flashAnim:SetToAlpha(0)\nR.flashAnim:SetSmoothing(\"IN\")\n\nfunction A.onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if subEvent == \"SPELL_DAMAGE\" and sourceGUID == playerGUID and ... == 193439 then\n        if state == \"ready\" then\n            state = \"collect\"\n            counter = 1\n            lastTransition = GetTime()\n            R.flashAnim:SetDuration(0.5 / (1 + .01 * GetHaste()))\n            R.flashAG:Play()\n        elseif state == \"collect\" then\n            counter = counter + 1\n        end\n    end\nend\n\nfunction A.statusTrigger()\n    local now = GetTime()\n    if state == \"collect\" then\n        if now - lastTransition > 0.20 then\n            state = \"ready\"\n            lastTransition = now\n        end\n        customText = tostring(counter)\n    elseif state == \"ready\" then\n        customText = (now - lastTransition < 2.0) and tostring(counter) or \"\"\n    end\n    return (customText ~= \"\")\nend\n\nfunction A.doCustomText()\n    return customText\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          check = "update",
          custom = "function() return aura_env.statusTrigger() end",
          custom_type = "status",
          type = "custom"
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    color = {
      0.10000000000000001,
      0.10000000000000001,
      0.10000000000000001
    },
    customText = "function() return aura_env.doCustomText() end",
    desc = "Arc v1.1 2016-11-10",
    disjunctive = "any",
    displayIcon = 1378284,
    displayStacks = "%c",
    displayText = "%c",
    fontSize = 20,
    frameStrata = 3,
    height = 38,
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
    numTriggers = 2,
    outline = "OUTLINE",
    regionType = "icon",
    selfPoint = "TOPLEFT",
    stacksPoint = "CENTER",
    trigger = {
      custom = "function(event, ...) aura_env.onCombatEvent(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 38,
    xOffset = 0,
    yOffset = 0
  },
  m = "d",
  s = "2.2.2.0",
  v = 1421
}
