{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n\nlocal tooltipName = \"ArtifactPowerTotalTooltip\"\n\nlocal bags = {BACKPACK_CONTAINER}\nlocal bankBags = {BANK_CONTAINER}\nfor i = 1, NUM_BAG_SLOTS do tinsert(bags, i) end\nfor i = 1, NUM_BANKBAGSLOTS do tinsert(bankBags, NUM_BAG_SLOTS + i) end\n\nlocal function printf(...) return print(format(...)) end\n\nlocal tooltip\nlocal cache = {}\n\nlocal function scanBag(bag)\n    local a = 0\n    for slot = 1, GetContainerNumSlots(bag) do\n        local link = GetContainerItemLink(bag, slot)\n        if link then\n            if cache[link] then\n                a = a + cache[link]\n            elseif strfind(link, \":8388608:\") then\n                tooltip:ClearLines()\n                tooltip:SetHyperlink(link)\n                for i = 1, tooltip:NumLines() do\n                    local fontString = _G[tooltipName..\"TextLeft\"..i]\n                    local text = fontString:GetText()\n                    text = gsub(text, \"[.,]\", \"\")\n                    gsub(text, \"Grants (%d+) Artifact Power\", function(s)\n                            local n = tonumber(s)\n                            a = a + n\n                            cache[link] = n\n                    end)\n                    if cache[link] then break end\n                end\n            end\n        end\n    end\n    return a\nend\n\nfunction R.doCalc()\n    tooltip = _G[tooltipName]\n    if not tooltip then\n        CreateFrame(\"GameTooltip\", tooltipName, nil, \"GameTooltipTemplate\")\n        tooltip = _G[tooltipName]\n        tooltip:SetOwner(UIParent, \"ANCHOR_NONE\")\n    end\n    \n    wipe(cache)\n    \n    local bagTotal = 0\n    local bankTotal = 0\n    for _, bag in ipairs(bags) do\n        bagTotal = bagTotal + scanBag(bag)\n    end\n    for _, bag in ipairs(bankBags) do\n        bankTotal = bankTotal + scanBag(bag)\n    end\n    \n    local B = BreakUpLargeNumbers or tostring\n    printf(\"Total artifact power: %s (Bag %s, Bank %s)\",\n        B(bagTotal + bankTotal), B(bagTotal), B(bankTotal))\nend\n\nlocal playerName = format(\"%s-%s\", UnitFullName(\"player\"))\n\nfunction aura_env.onMessage(event, message, sender)\n    if sender == playerName and strfind(strlower(message), \"^%s*af%s*power%s*$\") then\n        R.doCalc()\n    end\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          event = "Conditions",
          type = "status",
          unevent = "auto",
          unit = "player",
          use_alwaystrue = true,
          use_unit = true
        },
        untrigger = {}
      }
    },
    desc = "Arc v1.0 2016-09-20",
    disjunctive = "all",
    displayText = "",
    height = 1,
    id = "Artifact Power Total",
    numTriggers = 2,
    regionType = "text",
    trigger = {
      custom = "function(...) aura_env.onMessage(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "CHAT_MSG_WHISPER",
      type = "custom"
    },
    width = 1.0000075101852417
  },
  m = "d",
  s = "2.2.1.5",
  v = 1421
}
