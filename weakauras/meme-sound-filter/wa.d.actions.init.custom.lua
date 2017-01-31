local A = aura_env
local R = WeakAuras.regions[A.id].region

local chatChannels = {
    CHAT_MSG_INSTANCE_CHAT = "Instance",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "Instance Leader",
    CHAT_MSG_BN_WHISPER = "BNet Whisper",
    CHAT_MSG_GUILD = "Guild",
    CHAT_MSG_PARTY = "Party",
    CHAT_MSG_PARTY_LEADER = "Party Leader",
    CHAT_MSG_RAID = "Raid",
    CHAT_MSG_RAID_LEADER = "Raid Leader",
    CHAT_MSG_RAID_WARNING = "Raid Warning",
    CHAT_MSG_SAY = "Say",
    CHAT_MSG_WHISPER = "Whisper",
    CHAT_MSG_YELL = "Yell"
}

local history = {}
local historyStart = 1
local historyEnd = 1
local historyLimit = 1000

local function historyAdd(event, msg, sender)
    local line = format("|cff00ffff%s|r [%s] [%s]: %s", tostring(date()), tostring(chatChannels[event]), tostring(sender) ,tostring(msg))
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
local function ChatFrameFilter(chatFrame, event, msg, sender, ...)
    local msgID = select(9, ...)
    
    -- Do not process WIM History
    if not msgID or msgID<1 then return end
    
    -- Lets speed this up by checking if we already tested the message
    if lastMsgID == msgID then
        return lastMsgFiltered
    else
        lastMsgID         = msgID
        lastMsgFiltered   = false
        
        if strfind(msg, 'meme sound') or strfind(msg, 'stop memes') then
            historyAdd(event, msg, sender)
            lastMsgFiltered = true
            return true
        end
    end
end

local function init()
    for ch, _ in pairs(chatChannels) do
        ChatFrame_AddMessageEventFilter(ch, ChatFrameFilter)
    end
end

function A.PLAYER_ENTERING_WORLD()
    C_Timer.After(2, function() if not R.initDone then R.initDone = true init() end end)
end
