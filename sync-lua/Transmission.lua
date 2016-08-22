local requireRel
if arg and arg[0] then
    package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path
    requireRel = require
elseif ... then
    local d = (...):match("(.-)[^%.]+$")
    function requireRel(module) return require(d .. module) end
end

local bit           = require("bit")
local LibCompress   = requireRel("LibCompress")
local AceSerializer = requireRel("AceSerializer")

local Transmission = {}

-- Lua APIs
local tinsert, tconcat, tremove = table.insert, table.concat, table.remove
local fmt, tostring, string_char, strsplit = string.format, tostring, string.char, strsplit
local select, pairs, next, type, unpack = select, pairs, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget
local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local coroutine = coroutine

-- local functions
local encodeB64, decodeB64, tableAdd, tableSubtract, DisplayStub, removeSpellNames
local CompressDisplay, DecompressDisplay, ShowTooltip, TableToString, StringToTable
local RequestDisplay, TransmitError, TransmitDisplay

local WeakAuras = {L = {}}
local L = WeakAuras.L
setmetatable(WeakAuras.L, {__index = function(self, key) return key end})

local bytetoB64 = {
  [0]="a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p",
  "q","r","s","t","u","v","w","x",
  "y","z","A","B","C","D","E","F",
  "G","H","I","J","K","L","M","N",
  "O","P","Q","R","S","T","U","V",
  "W","X","Y","Z","0","1","2","3",
  "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
  a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
  i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
  q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
  y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
  G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
  O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
  W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
  ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {};

local function encodeB64(str)
  local B64 = encodeB64Table;
  local remainder = 0;
  local remainder_length = 0;
  local encoded_size = 0;
  local l=#str
  local code
  for i=1,l do
    code = string.byte(str, i);
    remainder = remainder + bit_lshift(code, remainder_length);
    remainder_length = remainder_length + 8;
    while(remainder_length) >= 6 do
      encoded_size = encoded_size + 1;
      B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
      remainder = bit_rshift(remainder, 6);
      remainder_length = remainder_length - 6;
    end
  end
  if remainder_length > 0 then
    encoded_size = encoded_size + 1;
    B64[encoded_size] = bytetoB64[remainder];
  end
  return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

local function decodeB64(str)
  local bit8 = decodeB64Table;
  local decoded_size = 0;
  local ch;
  local i = 1;
  local bitfield_len = 0;
  local bitfield = 0;
  local l = #str;
  while true do
    if bitfield_len >= 8 then
      decoded_size = decoded_size + 1;
      bit8[decoded_size] = string_char(bit_band(bitfield, 255));
      bitfield = bit_rshift(bitfield, 8);
      bitfield_len = bitfield_len - 8;
    end
    ch = B64tobyte[str:sub(i, i)];
    bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
    bitfield_len = bitfield_len + 6;
    if i > l then
      break;
    end
    i = i + 1;
  end
  return table.concat(bit8, "", 1, decoded_size)
end

local function tableAdd(augend, addend)
  local function recurse(augend, addend)
    for i,v in pairs(addend) do
      if(type(v) == "table") then
        augend[i] = augend[i] or {};
        recurse(augend[i], addend[i]);
      else
        if(augend[i] == nil) then
          augend[i] = v;
        end
      end
    end
  end
  recurse(augend, addend);
end

local function tableSubtract(minuend, subtrahend)
  local function recurse(minuend, subtrahend)
    for i,v in pairs(subtrahend) do
      if(minuend[i] ~= nil) then
        if(type(minuend[i]) == "table" and type(v) == "table") then
          if(recurse(minuend[i], v)) then
            minuend[i] = nil;
          end
        else
          if(minuend[i] == v) then
            minuend[i] = nil;
          end
        end
      end
    end
    local num = 0;
    for i,v in pairs(minuend) do
      num = num + 1;
    end
    return num == 0;
  end
  recurse(minuend, subtrahend);
end

local Compresser = LibCompress
local Encoder = Compresser:GetAddonEncodeTable()
local Serializer = AceSerializer

function Transmission:TableToString(inTable, forChat)
  local serialized = Serializer:Serialize(inTable);
  local compressed = Compresser:CompressHuffman(serialized);
  if(forChat) then
    return encodeB64(compressed);
  else
    return Encoder:Encode(compressed);
  end
end

function Transmission:StringToTable(inString, fromChat)
  local decoded;
  if(fromChat) then
    decoded = decodeB64(inString);
  else
    decoded = Encoder:Decode(inString);
  end
  local decompressed, errorMsg = Compresser:Decompress(decoded);
  if not(decompressed) then
    return "Error decompressing: "..errorMsg;
  end
  local success, deserialized = Serializer:Deserialize(decompressed);
  if not(success) then
    return "Error deserializing "..deserialized;
  end
  return deserialized;
end

return Transmission
