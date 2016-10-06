----- EN/06CEN/Nightmare Brambles -----
local A = aura_env

local castSound = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\RobotBlip.ogg"
local refixateSound = "Interface\\AddOns\\WeakAuras\\PowerAurasMedia\\Sounds\\kaching.ogg"

local classColors = getglobal("RAID_CLASS_COLORS")
local text
local startTime = 0
local castAlerted, refixateAlerted

function A.UNIT_SPELLCAST_SUCCEEDED(_, _, _, _, spellID)
    if spellID == 210290 then
        local u = "boss1target"
        local name = tostring(UnitName(u))
        local _, class = UnitClass(u)
        text = class and format("|c%s%s|r", classColors[class].colorStr, name) or name
        startTime = GetTime()
        castAlerted = false
        refixateAlerted = false
    end
end

local function playSound(s)
    if type(s) == "number" then PlaySoundKitID(s) else PlaySoundFile(s) end
end

function A.frameTrigger()
    local t = GetTime() - startTime
    if t < 1.75 then
        if not castAlerted then
            playSound(castSound)
            castAlerted = true
        end
        return true
    elseif (t > 20 and t < 21.75) then
        if not refixateAlerted then
            playSound(refixateSound)
            refixateAlerted = true
        end
        text = "Refixate"
        return true
    end
end

function A.text()
    return text
end
