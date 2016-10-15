-- Lua workhorse behind the WeakAura synchronization.

local requireRel
if arg then package.path=arg[0]:match("(.-)[^\\/]+$").."?.lua;"..package.path;requireRel=require
elseif...then local d=(...):match("(.-)[^%.]+$")function requireRel(m)return require(d..m)end end

local Transmission = requireRel("Transmission")
local serpent      = requireRel("serpent")
local JSON         = requireRel("JSON")

local format = string.format
local function errorf(...) error(format(...)) end

local function toDual(tbl)
  local dual = {}
  for k, v in pairs(tbl) do
    dual[v] = k
  end
  return dual
end

local isLuaKeyword = toDual({
  "and"   , "break" , "do"  , "else"    , "elseif",
  "end"   , "false" , "for" , "function", "if"    ,
  "in"    , "local" , "nil" , "not"     , "or"    ,
  "repeat", "return", "then", "true"    , "until" , "while"
})
local function isValidLuaName(str)
  return not isLuaKeyword[str]
  and not string.match(str, "[^%w_]")
  and not string.match(str, "^%d")
end

local function pathAppend(path, key)
  local keyType = type(key)
  if keyType == "string" then
    if isValidLuaName(key) then
      return format("%s.%s", path, key)
    else
      return format("%s['%s']", path, key)
    end
  elseif keyType == "number" then
    return format("%s[%s]", path, tostring(key))
  else
    errorf("at %s, unsupported key type %s", path, keyType)
  end
end

local function descend(path, tbl, key)
  return pathAppend(path, key), tbl[key]
end

-- leaf handling
local function addCodes(acc, path, tbl, keys)
  if not tbl then return end
  for _, key in ipairs(keys) do
    if type(tbl[key]) == "string" then
      acc[pathAppend(path, key)] = tbl[key]
    end
  end
end

--[[
d.trigger.custom
d.untrigger.custom
d.trigger.customDuration
d.trigger.customName
d.trigger.customIcon
d.trigger.customTexture
d.trigger.customStacks
d.additional_triggers[i].trigger.*
d.additional_triggers[i].untrigger.*
d.actions.init.custom
d.actions.start.custom
d.actions.finish.custom
d.animation.start.alphaFunc
d.animation.start.translateFunc
d.animation.start.scaleFunc
d.animation.start.rotateFunc
d.animation.start.colorFunc
d.animation.main.*
d.animation.finish.*
d.customTriggerLogic
d.customText
]]

local function checkTrigger(acc, path, trigger)
  addCodes(acc, path, trigger, {"custom", "customDuration", "customName",
    "customIcon", "customTexture", "customStacks"})
end
local function checkUntrigger(acc, path, untrigger)
  addCodes(acc, path, untrigger, {"custom"})
end
local function checkAction(acc, path, action)
  addCodes(acc, path, action, {"custom"})
end
local function checkAnimation(acc, path, animation)
  addCodes(acc, path, animation, {"alphaFunc, translateFunc",
    "scaleFunc", "rotateFunc", "colorFunc"})
end
local function checkDisplayBase(acc, path, display)
  addCodes(acc, path, display, {"customTriggerLogic", "customText"})
end

local function checkDisplay(acc, dPath, d)
  if not d then return end

  checkTrigger(  acc, descend(dPath, d, "trigger"))
  checkUntrigger(acc, descend(dPath, d, "untrigger"))

  local moreTriggersPath, moreTriggers = descend(dPath, d, "additional_triggers")
  if moreTriggers then
    for i = 1, math.huge do
      local triggerPath, trigger = descend(moreTriggersPath, moreTriggers, i)
      if not trigger then break end
      checkTrigger(  acc, descend(triggerPath, trigger, "trigger"))
      checkUntrigger(acc, descend(triggerPath, trigger, "untrigger"))
    end
  end

  local actionsPath, actions = descend(dPath, d, "actions")
  if actions then
    checkAction(acc, descend(actionsPath, actions, "init"))
    checkAction(acc, descend(actionsPath, actions, "start"))
    checkAction(acc, descend(actionsPath, actions, "finish"))
  end

  local animationPath, animation = descend(dPath, d, "animation")
  if animation then
    checkAnimation(acc, descend(animationPath, animation, "start"))
    checkAnimation(acc, descend(animationPath, animation, "main"))
    checkAnimation(acc, descend(animationPath, animation, "finish"))
  end

  checkDisplayBase(acc, dPath, d)
end

local function checkWA(acc, waPath, wa)
  checkDisplay(acc, descend(waPath, wa, "d"))

  local cPath, c = descend(waPath, wa, "c")
  if c then
    for i = 1, math.huge do
      local childPath, child = descend(cPath, c, i)
      if not child then break end
      checkDisplay(acc, childPath, child)
    end
  end
end

local function extractCustomCode(wa)
  local acc = {}
  checkWA(acc, "wa", wa)
  for k, v in pairs(acc) do
    acc[k] = v:gsub("%s+$", "") .. "\n"
  end
  return acc
end

local function injectCustomCode(wa, code)
  for k, v in pairs(code) do
    -- e.g. wa.c[1].actions.init.custom = v
    local f = loadstring(k .. " = v")
    setfenv(f, {wa = wa, v = v:gsub("%s+$", "")})
    f()
  end
end

local function loadTable(file)
  local block = file:read("*a")
  local ok, result = serpent.load(block)
  if not ok then errorf("table deserialization failed: %s", result) end
  return result
end

local function loadString(file)
  local str = file:read("*a")
  return Transmission:StringToTable(str, true)
end

local function loadJSON(file)
  local json = file:read("*a")
  return JSON:decode(json)
end

local function saveTable(file, data)
  local block = serpent.block(data, {comment = false})
  file:write(block, "\n")
end

local function saveString(file, data)
  local str = Transmission:TableToString(data, true)
  file:write(str)
end

local function saveJSON(file, data)
  local str = JSON:encode_pretty(data)
  file:write(str)
end

local commandUsages = {
  "%s table-to-string          table.txt            >string.txt",
  "%s string-to-table          string.txt           >table.txt",
  "%s extract-code-from-table  table.txt            >code.json",
  "%s extract-code-from-string string.txt           >code.json",
  "%s inject-code-into-table   table.txt  code.json >table.txt",
  "%s inject-code-into-string  string.txt code.json >string.txt",
}
local function printUsage()
  io.write("usage:\n")
  for _, usage in ipairs(commandUsages) do
    io.write("    ", format(usage, arg[0]), "\n")
  end
end

local function main()
  if arg[1] == "table-to-string" then

    local data = loadTable(io.open(arg[2], "r"))
    saveString(io.stdout, data)

  elseif arg[1] == "string-to-table" then

    local data = loadString(io.open(arg[2], "r"))
    saveTable(io.stdout, data)

  elseif arg[1] == "extract-code-from-table" then

    local data = loadTable(io.open(arg[2], "r"))
    local code = extractCustomCode(data)
    saveJSON(io.stdout, code)

  elseif arg[1] == "extract-code-from-string" then

    local data = loadString(io.open(arg[2], "r"))
    local code = extractCustomCode(data)
    saveJSON(io.stdout, code)

  elseif arg[1] == "inject-code-into-table" then

    local data = loadTable(io.open(arg[2], "r"))
    local code = loadJSON(io.open(arg[3], "r"))
    injectCustomCode(data, code)
    saveTable(io.stdout, data)

  elseif arg[1] == "inject-code-into-string" then

    local data = loadString(io.open(arg[2], "r"))
    local code = loadJSON(io.open(arg[3], "r"))
    injectCustomCode(data, code)
    saveString(io.stdout, data)

  else
    printUsage()
    return 1
  end

  return 0
end

return main()
