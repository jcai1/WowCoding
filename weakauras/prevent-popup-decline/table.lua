{
  d = {
    actions = {
      init = {
        custom = "local popups = {\n    \"RESURRECT\",\n    \"RESURRECT_NO_TIMER\",\n    \"RESURRECT_NO_SICKNESS\",\n    \"CONFIRM_SUMMON\",\n    \"CONFIRM_SUMMON_SCENARIO\",\n    \"CONFIRM_SUMMON_STARTING_AREA\",\n    \"PARTY_INVITE\",\n    \"PARTY_INVITE_XREALM\",\n}\n\nlocal popupsTest = {}; for _, v in pairs(popups) do popupsTest[v] = true end\n\nlocal function findPopupName(which)\n    for i = 1, STATICPOPUP_NUMDIALOGS do\n        local name = \"StaticPopup\"..i\n        if getglobal(name).which == which then\n            return name\n        end\n    end\nend\n\nlocal function hook_StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)\n    if not popupsTest[which] then return end\n    \n    local name = findPopupName(which)\n    \n    local popup       = getglobal(name)\n    local button2     = getglobal(name..\"Button2\")\n    local button2Text = getglobal(name..\"Button2Text\")\n    \n    button2Text:SetText(\"X\")\n    button2:ClearAllPoints()\n    button2:SetPoint(\"TOPRIGHT\", popup, \"TOPRIGHT\", -13, -10)\n    button2:SetWidth(18)\nend\n\nfunction aura_env.init()\n    for _, which in ipairs(popups) do\n        local popup = StaticPopupDialogs[which]\n        if popup then\n            popup.hideOnEscape = nil\n        end\n    end\n    \n    hooksecurefunc(\"StaticPopup_Show\", hook_StaticPopup_Show)\nend",
        do_custom = true
      }
    },
    desc = "Arc v1.0 2016-09-06",
    disjunctive = "all",
    displayText = "",
    height = 1,
    id = "Prevent Popup Decline",
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function() aura_env.init() end",
      custom_hide = "timed",
      custom_type = "event",
      events = "PLAYER_ENTERING_WORLD",
      type = "custom"
    },
    width = 1
  },
  m = "d",
  s = "2.2.1.4",
  v = 1421
}
