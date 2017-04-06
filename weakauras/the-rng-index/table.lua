{
  d = {
    actions = {
      start = {
        custom = "local total = 0\n\nlocal function processSpell(desc, link)\n    if not desc then return end\n    desc = strlower(desc)\n    if strfind(desc, \"sometimes\") or strfind(desc, \"a %S*%s?chance\") or strfind(desc, \"occasionally\") then\n        print(\"+1:\", link)\n        total = total + 1\n    end\nend\n\nlocal spells = {}\nlocal usedSpellIDs = {}\n\nlocal function addSpellID(spellID)\n    if (not spellID) or usedSpellIDs[spellID] then\n        return\n    end\n    tinsert(spells, spellID)\n    usedSpellIDs[spellID] = true\nend\n\nlocal name,texture,offset,numSpells = GetSpellTabInfo(2)\nfor i = offset+1, offset+numSpells do\n    local spellID = select(7, GetSpellInfo(i, \"spell\"))\n    addSpellID(spellID)\nend\n\nif not (ArtifactFrame and ArtifactFrame:IsVisible()) then\n    SocketInventoryItem(INVSLOT_MAINHAND)\nend\nlocal artifactPowers = C_ArtifactUI.GetPowers()\nif artifactPowers then\n    for _, powerID in ipairs(artifactPowers) do\n        local spellID = C_ArtifactUI.GetPowerInfo(powerID)\n        addSpellID(spellID)\n    end\nelse\n    print(\"Warning: Couldn't open artifact UI\")\nend\nC_ArtifactUI.Clear()\n\nfor tier = 1, MAX_TALENT_TIERS do\n    for col = 1, NUM_TALENT_COLUMNS do\n        local spellID, _, _, _, selected = select(6, GetTalentInfo(tier, col, 1))\n        if selected then\n            addSpellID(spellID)\n            break\n        end\n    end\nend\n\n\nfor _, spellID in ipairs(spells) do\n    local desc = GetSpellDescription(spellID)\n    local link = GetSpellLink(spellID)\n    processSpell(desc, link)\nend\n\nprint(\"Your RNG Index:\", total)",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    disjunctive = "all",
    displayText = "",
    height = 1.0000075101852417,
    id = "The RNG Index",
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
      },
      use_combat = false
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      duration = "1",
      event = "Chat Message",
      message = "rng",
      messageType = "CHAT_MSG_WHISPER",
      message_operator = "==",
      type = "event",
      unevent = "timed",
      use_message = true,
      use_messageType = true
    },
    width = 1.0000075101852417
  },
  m = "d",
  s = "2.3.9",
  v = 1421
}
