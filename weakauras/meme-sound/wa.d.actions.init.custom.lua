local A = aura_env
local S = WeakAurasSaved.displays[A.id]

local soundChannel = "MASTER"
local cooldown = 3

local lastMeme = 0
local handles = {}

local strsub, strfind, strmatch = strsub, strfind, strmatch

local function memeSound(sound)
    local now = GetTime()
    if now - lastMeme > cooldown then
        lastMeme = now
        sound = sound or S.defaultSound
        if not sound then
            return
        end
        local play = (type(sound) == "number") and PlaySoundKitID or PlaySoundFile
        local success, handle = play(sound, soundChannel)
        if handle then
            handles[handle] = true
        end
    end
end

local function stopMemes()
    for handle, _ in pairs(handles) do
        handles[handle] = nil
        StopSound(handle)
    end
end

local function rtrim(s)
    local n = #s
    while n > 0 and strfind(s, "^%s", n) do n = n - 1 end
    return strsub(s, 1, n)
end

function A.onChatMessage(event, message)
    if strfind(message, "stop memes") then
        stopMemes()
        return
    end
    
    local memeSoundPos = strfind(message, "meme sound")
    if not memeSoundPos then return end
    message = rtrim(strsub(message, memeSoundPos))
    
    if message == "meme sound" then
        memeSound(nil)
    elseif strsub(message, 1, 11) == "meme sound " then
        message = strsub(message, 12)
        if strsub(message, 1, 11) == "of the day " then
            message = strsub(message, 12)
            S.defaultSound = message
        end
        if strmatch(message, "^%d+$") then
            message = tonumber(message)
        end
        memeSound(message)
    end
end
