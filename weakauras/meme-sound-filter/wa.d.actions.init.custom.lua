local A = aura_env
local R = WeakAuras.regions[A.id].region

local history = {}
local historyStart = 1
local historyEnd = 1
local historyLimit = 1000

local function historyAdd(msg, sender)
    local line = format("|cff00ffff%s|r [%s]: %s", tostring(date()), tostring(sender) ,tostring(msg))
    history[historyEnd] = line
    historyEnd = historyEnd + 1
    if historyEnd - historyStart > historyLimit then
        history[historyStart] = nil
        historyStart = historyStart + 1
    end
end

local function historyDump()
    print("|cff00ffffShowing memes:|r")
    for i = historyStart, historyEnd - 1 do
        print(history[i])
    end
end

local function historyClear()
    wipe(history)
    historyStart = 1
    historyEnd = 1
end

function R.showMemes()
    historyDump()
    historyClear()
end

-- copied from EPGP's filter functionality
local lastMsgID = nil
local lastMsgFiltered = false
local function ChatFrameFilter(chatFrame, ...)
    --local event = select(1, ...)
    local sender = select(3, ...)
    local msg = select(2, ...)
    local msgID = select(12, ...)
    
    -- Do not process WIM History
    if not msgID or msgID<1 then return end
    
    -- Lets speed this up by checking if we already tested the message
    if lastMsgID == msgID then
        return lastMsgFiltered
    else
        lastMsgID         = msgID
        lastMsgFiltered   = false
        
        if strfind(msg, 'meme sound') or strfind(msg, 'stop memes') then
            historyAdd(msg, sender)
            lastMsgFiltered = true
            return true
        end
    end
end

local chatChannels = {
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_YELL"
}

local function init()
    for _, ch in ipairs(chatChannels) do
        ChatFrame_AddMessageEventFilter(ch, ChatFrameFilter)
    end
end

function A.PLAYER_ENTERING_WORLD()
    C_Timer.After(2, function() if not R.initDone then R.initDone = true init() end end)
end
