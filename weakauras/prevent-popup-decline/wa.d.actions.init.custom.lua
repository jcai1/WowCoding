local popups = {
    "RESURRECT",
    "RESURRECT_NO_TIMER",
    "RESURRECT_NO_SICKNESS",
    "CONFIRM_SUMMON",
    "CONFIRM_SUMMON_SCENARIO",
    "CONFIRM_SUMMON_STARTING_AREA",
    "PARTY_INVITE",
    "PARTY_INVITE_XREALM",
}

local popupsTest = {}; for _, v in pairs(popups) do popupsTest[v] = true end

local function findPopupName(which)
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local name = "StaticPopup"..i
        if getglobal(name).which == which then
            return name
        end
    end
end

local function hook_StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)
    if not popupsTest[which] then return end
    
    local name = findPopupName(which)
    
    local popup       = getglobal(name)
    local button2     = getglobal(name.."Button2")
    local button2Text = getglobal(name.."Button2Text")
    
    button2Text:SetText("X")
    button2:ClearAllPoints()
    button2:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -13, -10)
    button2:SetWidth(18)
end

function aura_env.init()
    for _, which in ipairs(popups) do
        local popup = StaticPopupDialogs[which]
        if popup then
            popup.hideOnEscape = nil
        end
    end
    
    hooksecurefunc("StaticPopup_Show", hook_StaticPopup_Show)
end

print(format("WeakAura %s loaded", aura_env.id))
