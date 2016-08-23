{
  d = {
    actions = {
      finish = {
        do_sound = true,
        sound = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\chimes.ogg",
        sound_channel = "Master"
      },
      init = {
        custom = "local function init()\n    local A, t = aura_env, GetTime()\n    \n    local disp = WeakAurasSaved.displays[A.id]\n    if disp and disp.actions and disp.actions.finish then\n        local f = disp.actions.finish\n        if f.do_sound and f.sound then\n            function A.playSound()\n                PlaySoundFile(f.sound, f.sound_channel or MASTER)\n            end\n        end\n    end\n    if not A.playSound then\n        function A.playSound() end\n    end\n    \n    A.t1 = -math.huge -- Time when sound last played\n    \n    A.rings = {[124634] = \"Thorasus\", [124635] = \"Nithramus\", [124636] = \"Maalus\", [124637] = \"Sanctus\", [124638] = \"Etheralus\"}\n    \n    local function getRingInfo()\n        local id1, id2, name1, name2, rings\n        rings = A.rings\n        id1 = GetInventoryItemID(\"player\", INVSLOT_FINGER1)\n        name1 = rings[id1]\n        if name1 then return id1, name1 end\n        id2 = GetInventoryItemID(\"player\", INVSLOT_FINGER2)\n        name2 = rings[id2]\n        if name2 then return id2, name2 end\n    end\n    \n    function A.updateRing()\n        A.currRing, A.currRingName = getRingInfo()\n    end\n    \n    A.updateRing()\n    A.t2 = t -- Time when ring info last updated\nend\ninit()",
        do_custom = true
      },
      start = {
        do_sound = false,
        sound = " custom"
      }
    },
    additional_triggers = {
      {
        trigger = {
          check = "update",
          custom = "function()\n    local A, t = aura_env, GetTime()\n    if t - A.t2 > 1 then\n        A.t2 = t\n        A.updateRing()\n    end\n    return true\nend",
          custom_type = "status",
          event = "Conditions",
          subeventPrefix = "SPELL",
          subeventSuffix = "_CAST_START",
          type = "custom",
          unevent = "auto",
          unit = "player",
          use_alwaystrue = true,
          use_unit = true
        },
        untrigger = {
          custom = "function()\n    return true\nend"
        }
      }
    },
    auto = false,
    cooldown = false,
    customText = "function()\n    local A, t = aura_env, GetTime()\n    if not A.currRing then\n        return\n    end\n    local start, dur = GetItemCooldown(A.currRing)\n    if dur == 0 then\n        return \"|cff00ff00RDY|r\"\n    else\n        local s = t - start\n        if UnitBuff(\"player\", A.currRingName) then\n            if t - A.t1 > 60 then\n                A.t1 = t\n                A.playSound()\n            end\n            local u = math.ceil(15 - s)\n            return string.format(\"|cff%s%d|r\", (u>5 and \"ffff00\" or \"ff0000\"), u)\n        else\n            local u = math.ceil(dur - s)\n            local v = (u >= 60 and string.format(\"1:%02d\", u - 60) or tostring(u))\n            return string.format(\"|cff%s%s|r\", (u>10 and \"ffffff\" or \"00ff00\"), v)\n        end\n    end\n    \nend",
    desc = "Arc v0.1 2016-04-09",
    disjunctive = "all",
    displayIcon = "Interface\\Icons\\Spell_Nature_WispSplode",
    displayStacks = "%c",
    font = "FrancoisOne",
    fontFlags = "THICKOUTLINE",
    fontSize = 24,
    height = 45,
    id = "L.Ring CD (Self)",
    init_completed = 1,
    load = {
      class = {
        multi = {
          WARLOCK = true
        },
        single = "WARLOCK"
      },
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      name = "Arcinde",
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      talent = {
        multi = {}
      },
      use_name = false,
      use_never = false
    },
    numTriggers = 2,
    regionType = "icon",
    stacksPoint = "CENTER",
    trigger = {
      check = "update",
      custom = "function()\n    return aura_env.currRing\nend",
      customDuration = "",
      customIcon = "",
      custom_type = "status",
      event = "Conditions",
      type = "custom",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    untrigger = {
      custom = "function()\n    return true\nend"
    },
    width = 45,
    xOffset = -260.99987792968801,
    yOffset = 269.0009765625
  },
  m = "d",
  s = "2.1.0.25",
  v = 1421
}
