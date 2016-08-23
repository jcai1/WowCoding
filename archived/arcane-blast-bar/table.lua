{
  d = {
    actions = {
      init = {
        custom = "local A, t = aura_env, GetTime()\nlocal F = WeakAuras.regions[A.id].region\n\n--- SET OPTIONS HERE ---\nA.timeScale = 5\nA.font = \"Interface\\\\AddOns\\\\WeakAuras\\\\Media\\\\Fonts\\\\FiraMono-Medium.ttf\"\nA.fontSize = 14\nA.fontFlags = \"OUTLINE\"\nA.fps = 45\n--- END OPTIONS ---\n\nA.t = -math.huge\nA.dt = 1 / A.fps\n\nF.BG = F.BG or F:CreateTexture(nil, \"BACKGROUND\", nil, 0)\nF.topBG = F.topBG or F:CreateTexture(nil, \"BACKGROUND\", nil, 1)\nF.topFG = F.topFG or F:CreateTexture(nil, \"BACKGROUND\", nil, 2)\nF.topFG2 = F.topFG2 or F:CreateTexture(nil, \"BACKGROUND\", nil, 3)\nF.topText = F.topText or F:CreateFontString(nil, \"BACKGROUND\")\n\nF.botBG = F.botBG or F:CreateTexture(nil, \"BACKGROUND\", nil, 1)\nF.botFG = F.botFG or F:CreateTexture(nil, \"BACKGROUND\", nil, 2)\nF.botText = F.botText or F:CreateFontString(nil, \"BACKGROUND\")\n-- F.botText2 = F.botText2 or F:CreateFontString(nil, \"BACKGROUND\")\n\nlocal w, h = F:GetSize()\nA.w, A.h = w, h\n\nlocal T = A.timeScale\nfunction A.updateBar(bar, time)\n    if time <= 0 then\n        bar:Hide()\n    else\n        bar:SetWidth(min(1, time / T) * w)\n        bar:Show()\n    end\nend\n\nlocal square = \"Interface\\\\AddOns\\\\WeakAuras\\\\Media\\\\Textures\\\\Square_White\"\n\nlocal bg = F.BG\nlocal tb = F.topBG\nlocal bb = F.botBG\nlocal tf = F.topFG\nlocal tf2 = F.topFG2\nlocal bf = F.botFG\nlocal tt = F.topText\nlocal bt = F.botText\n-- local bt2 = F.botText2\n\nlocal function f(tex)\n    tex:SetTexture(square)\n    tex:ClearAllPoints()\n    tex:SetSize(w, h/2)\nend\nlocal function g(fs)\n    fs:SetFont(A.font, A.fontSize, A.fontFlags)\n    fs:ClearAllPoints()\nend\n\nf(bg)\nf(tb)\nf(tf)\nf(tf2)\nf(bb)\nf(bf)\ng(tt)\ng(bt)\n-- g(bt2)\n\nbg:SetPoint(\"CENTER\", F, \"CENTER\", 0, 0)\nbg:SetSize(w + 3, h + 3)\ntb:SetPoint(\"LEFT\", F, \"LEFT\", 0, h/4)\ntf:SetPoint(\"LEFT\", F, \"LEFT\", 1, h/4)\ntf2:SetPoint(\"RIGHT\", tf, \"RIGHT\", 0, 0)\ntt:SetPoint(\"LEFT\", F, \"RIGHT\", -w*0.23, h/4)\nbb:SetPoint(\"LEFT\", F, \"LEFT\", 0, -h/4)\nbf:SetPoint(\"LEFT\", F, \"LEFT\", 0, -h/4)\nbt:SetPoint(\"LEFT\", F, \"RIGHT\", -w*0.23, -h/4)\n-- bt2:SetPoint(\"RIGHT\", F, \"RIGHT\", -w/4, -h/4)\n\ntb:SetVertexColor(.4, 0, 0)\ntf:SetVertexColor(1, 0, 0)\ntf2:SetVertexColor(1, .5, .5)\nbb:SetVertexColor(0, 0, .4)\nbf:SetVertexColor(.2, .3, 1)",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    auto = false,
    color = {
      [4] = 0
    },
    customText = "function()\n    local A, t = aura_env, GetTime()\n    local F = WeakAuras.regions[A.id].region\n    \n    if t - A.t < A.dt then\n        return\n    else\n        A.t = t\n    end\n    \n    local tf = F.topFG\n    local tf2 = F.topFG2\n    local bf = F.botFG\n    local tt = F.topText\n    local bt = F.botText\n    -- local bt2 = F.botText2\n    \n    local T = A.timeScale\n    local _, _, _, acStacks, _, _, acExpires = UnitDebuff(\"player\", \"Arcane Charge\", nil, \"PLAYER\")\n    local acRemain = (acExpires or t) - t\n    local _, _, _, abCastLength = GetSpellInfo(30451)\n    abCastLength = abCastLength * 0.001\n    local castName, _, _, _, _, castEnd = UnitCastingInfo(\"player\")\n    local abCastRemain = (castName == \"Arcane Blast\") and (castEnd * 0.001 - t) or abCastLength\n    \n    local upd = A.updateBar\n    upd(tf, abCastLength)\n    upd(tf2, abCastLength - abCastRemain)\n    upd(bf, acRemain)\n    \n    tt:SetText(format(\"%.1f\", abCastLength))\n    bt:SetText(format(\"%.1f\", acRemain))\n    -- bt2:SetText(acStacks or 0)\nend",
    desc = "Arc v0.0 2016-01-02",
    displayStacks = "%c",
    height = 32,
    id = "Arcane Blast Bar",
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
        single = 1
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_never = true,
      use_petbattle = false,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "icon",
    stacksContainment = "OUTSIDE",
    stacksPoint = "RIGHT",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    width = 180,
    yOffset = -200
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}
