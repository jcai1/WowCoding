local A = aura_env
local refreshInterval = 0.05
local lastRefresh = -999
local shouldShow
local now

local followTexture = getglobal("PET_FOLLOW_TEXTURE")
local moveToTexture = getglobal("PET_MOVE_TO_TEXTURE")

local function refresh()
    for i = 1, NUM_PET_ACTION_SLOTS do
        local name, _, texture, _, isActive = GetPetActionInfo(i)
        if isActive then
            if name == "PET_ACTION_FOLLOW" then
                A.texture = followTexture
                A.name = "Follow"
                return true
            elseif name == "PET_ACTION_MOVE_TO" then
                A.texture = moveToTexture
                A.name = "Move To"
                return true
            end
        end
    end
    return false
end

function A.trigger()
    now = GetTime()
    if now - lastRefresh > refreshInterval then
        shouldShow = refresh()
        lastRefresh = now
    end
    return shouldShow
end
