{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal S = WeakAurasSaved.displays[A.id]\n\nlocal soundChannel = \"MASTER\"\nlocal cooldown = 3\n\nlocal lastMeme = 0\nlocal handles = {}\n\nlocal strsub, strfind, strmatch = strsub, strfind, strmatch\n\nlocal function memeSound(sound)\n    local now = GetTime()\n    if now - lastMeme > cooldown then\n        lastMeme = now\n        sound = sound or S.defaultSound\n        if not sound then\n            return\n        end\n        local play = (type(sound) == \"number\") and PlaySoundKitID or PlaySoundFile\n        local success, handle = play(sound, soundChannel)\n        if handle then\n            handles[handle] = true\n        end\n    end\nend\n\nlocal function stopMemes()\n    for handle, _ in pairs(handles) do\n        handles[handle] = nil\n        StopSound(handle)\n    end\nend\n\nlocal function rtrim(s)\n    local n = #s\n    while n > 0 and strfind(s, \"^%s\", n) do n = n - 1 end\n    return strsub(s, 1, n)\nend\n\nfunction A.onChatMessage(event, message)\n    if strfind(message, \"stop memes\") then\n        stopMemes()\n        return\n    end\n    \n    local memeSoundPos = strfind(message, \"meme sound\")\n    if not memeSoundPos then return end\n    message = rtrim(strsub(message, memeSoundPos))\n    \n    if message == \"meme sound\" then\n        memeSound(nil)\n    elseif strsub(message, 1, 11) == \"meme sound \" then\n        message = strsub(message, 12)\n        if strsub(message, 1, 11) == \"of the day \" then\n            message = strsub(message, 12)\n            S.defaultSound = message\n        end\n        if strmatch(message, \"^%d+$\") then\n            message = tonumber(message)\n        end\n        memeSound(message)\n    end\nend",
        do_custom = true
      }
    },
    defaultSound = "Sound/Creature/Elisande/VO_701_Elisande_11.ogg",
    desc = "Arc v1.3 2017-01-24",
    disjunctive = "all",
    displayText = "",
    id = "Meme Sound IMPROVED 3",
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function(...) aura_env.onChatMessage(...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "CHAT_MSG_INSTANCE_CHAT,CHAT_MSG_INSTANCE_CHAT_LEADER,CHAT_MSG_BN_WHISPER,CHAT_MSG_GUILD,CHAT_MSG_PARTY,CHAT_MSG_PARTY_LEADER,CHAT_MSG_RAID,CHAT_MSG_RAID_LEADER,CHAT_MSG_RAID_WARNING,CHAT_MSG_SAY,CHAT_MSG_WHISPER,CHAT_MSG_YELL",
      type = "custom"
    }
  },
  m = "d",
  s = "2.2.2.6",
  v = 1421
}
