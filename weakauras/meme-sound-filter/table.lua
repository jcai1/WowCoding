{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n\nlocal chatChannels = {\n    CHAT_MSG_INSTANCE_CHAT = \"Instance\",\n    CHAT_MSG_INSTANCE_CHAT_LEADER = \"Instance Leader\",\n    CHAT_MSG_BN_WHISPER = \"BNet Whisper\",\n    CHAT_MSG_GUILD = \"Guild\",\n    CHAT_MSG_PARTY = \"Party\",\n    CHAT_MSG_PARTY_LEADER = \"Party Leader\",\n    CHAT_MSG_RAID = \"Raid\",\n    CHAT_MSG_RAID_LEADER = \"Raid Leader\",\n    CHAT_MSG_RAID_WARNING = \"Raid Warning\",\n    CHAT_MSG_SAY = \"Say\",\n    CHAT_MSG_WHISPER = \"Whisper\",\n    CHAT_MSG_YELL = \"Yell\"\n}\n\nlocal history = {}\nlocal historyStart = 1\nlocal historyEnd = 1\nlocal historyLimit = 1000\n\nlocal function historyAdd(event, msg, sender)\n    local line = format(\"|cff00ffff%s|r [%s] [%s]: %s\", tostring(date()), tostring(chatChannels[event]), tostring(sender) ,tostring(msg))\n    history[historyEnd] = line\n    historyEnd = historyEnd + 1\n    if historyEnd - historyStart > historyLimit then\n        history[historyStart] = nil\n        historyStart = historyStart + 1\n    end\nend\n\nlocal function historyDump()\n    print(\"|cff00ffffShowing memes:|r\")\n    for i = historyStart, historyEnd - 1 do\n        print(history[i])\n    end\nend\n\nlocal function historyClear()\n    wipe(history)\n    historyStart = 1\n    historyEnd = 1\nend\n\nfunction R.showMemes()\n    historyDump()\n    historyClear()\nend\n\n-- copied from EPGP's filter functionality\nlocal lastMsgID = nil\nlocal lastMsgFiltered = false\nlocal function ChatFrameFilter(chatFrame, event, msg, sender, ...)\n    local msgID = select(9, ...)\n    \n    -- Do not process WIM History\n    if not msgID or msgID<1 then return end\n    \n    -- Lets speed this up by checking if we already tested the message\n    if lastMsgID == msgID then\n        return lastMsgFiltered\n    else\n        lastMsgID         = msgID\n        lastMsgFiltered   = false\n        \n        if strfind(msg, 'meme sound') or strfind(msg, 'stop memes') then\n            historyAdd(event, msg, sender)\n            lastMsgFiltered = true\n            return true\n        end\n    end\nend\n\nlocal function init()\n    for ch, _ in pairs(chatChannels) do\n        ChatFrame_AddMessageEventFilter(ch, ChatFrameFilter)\n    end\nend\n\nfunction A.PLAYER_ENTERING_WORLD()\n    C_Timer.After(2, function() if not R.initDone then R.initDone = true init() end end)\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    desc = "Arc v1.0 2017-01-31",
    disjunctive = "all",
    displayText = "",
    id = "Meme Sound Filter",
    numTriggers = 1,
    regionType = "text",
    trigger = {
      check = "event",
      custom = "function(event, ...) return aura_env[event](...) end",
      custom_hide = "custom",
      custom_type = "event",
      events = "PLAYER_ENTERING_WORLD",
      type = "custom"
    }
  },
  m = "d",
  s = "2.3.0.0",
  v = 1421
}
