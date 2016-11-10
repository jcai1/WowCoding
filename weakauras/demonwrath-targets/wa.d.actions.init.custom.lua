----- Demonwrath Targets -----
local A = aura_env
local R = WeakAuras.regions[A.id].region
local playerGUID = UnitGUID("player")
local customText = ""

local state = "ready"  -- ready, collect
local counter = 0
local lastTransition = -999

local flashName = "DemonwrathTargetsFlash"
R.flash = R.flash or R:CreateTexture(flashName, "MEDIUM")
R.flash:ClearAllPoints()
R.flash:SetAllPoints(R)
R.flash:SetTexture("Interface\\Icons\\spell_warlock_demonwrath")
R.flash:SetVertexColor(1, 1, 1, 0)
R.flash:Show()
R.flashAG = R.flashAG or R.flash:CreateAnimationGroup(flashName.."AG")
R.flashAnim = R.flashAnim or R.flashAG:CreateAnimation("Alpha", flashName.."Anim")
R.flashAnim:SetFromAlpha(1)
R.flashAnim:SetToAlpha(0)
R.flashAnim:SetSmoothing("IN")

function A.onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
    if subEvent == "SPELL_DAMAGE" and sourceGUID == playerGUID and ... == 193439 then
        if state == "ready" then
            state = "collect"
            counter = 1
            lastTransition = GetTime()
            R.flashAnim:SetDuration(0.5 / (1 + .01 * GetHaste()))
            R.flashAG:Play()
        elseif state == "collect" then
            counter = counter + 1
        end
    end
end

function A.statusTrigger()
    local now = GetTime()
    if state == "collect" then
        if now - lastTransition > 0.20 then
            state = "ready"
            lastTransition = now
        end
        customText = tostring(counter)
    elseif state == "ready" then
        customText = (now - lastTransition < 2.0) and tostring(counter) or ""
    end
    return (customText ~= "")
end

function A.doCustomText()
    return customText
end
