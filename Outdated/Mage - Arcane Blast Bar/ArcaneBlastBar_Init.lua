local A, t = aura_env, GetTime()
local F = WeakAuras.regions[A.id].region

--- SET OPTIONS HERE ---
A.timeScale = 5
A.font = "Interface\\AddOns\\WeakAuras\\Media\\Fonts\\FiraMono-Medium.ttf"
A.fontSize = 14
A.fontFlags = "OUTLINE"
A.fps = 45
--- END OPTIONS ---

A.t = -math.huge
A.dt = 1 / A.fps

F.BG = F.BG or F:CreateTexture(nil, "BACKGROUND", nil, 0)
F.topBG = F.topBG or F:CreateTexture(nil, "BACKGROUND", nil, 1)
F.topFG = F.topFG or F:CreateTexture(nil, "BACKGROUND", nil, 2)
F.topFG2 = F.topFG2 or F:CreateTexture(nil, "BACKGROUND", nil, 3)
F.topText = F.topText or F:CreateFontString(nil, "BACKGROUND")

F.botBG = F.botBG or F:CreateTexture(nil, "BACKGROUND", nil, 1)
F.botFG = F.botFG or F:CreateTexture(nil, "BACKGROUND", nil, 2)
F.botText = F.botText or F:CreateFontString(nil, "BACKGROUND")
-- F.botText2 = F.botText2 or F:CreateFontString(nil, "BACKGROUND")

local w, h = F:GetSize()
A.w, A.h = w, h

local T = A.timeScale
function A.updateBar(bar, time)
	if time <= 0 then
		bar:Hide()
	else
		bar:SetWidth(min(1, time / T) * w)
		bar:Show()
	end
end

local square = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White"

local bg = F.BG
local tb = F.topBG
local bb = F.botBG
local tf = F.topFG
local tf2 = F.topFG2
local bf = F.botFG
local tt = F.topText
local bt = F.botText
-- local bt2 = F.botText2

local function f(tex)
	tex:SetTexture(square)
	tex:ClearAllPoints()
	tex:SetSize(w, h/2)
end
local function g(fs)
	fs:SetFont(A.font, A.fontSize, A.fontFlags)
	fs:ClearAllPoints()
end

f(bg)
f(tb)
f(tf)
f(tf2)
f(bb)
f(bf)
g(tt)
g(bt)
-- g(bt2)

bg:SetPoint("CENTER", F, "CENTER", 0, 0)
bg:SetSize(w + 3, h + 3)
tb:SetPoint("LEFT", F, "LEFT", 0, h/4)
tf:SetPoint("LEFT", F, "LEFT", 1, h/4)
tf2:SetPoint("RIGHT", tf, "RIGHT", 0, 0)
tt:SetPoint("LEFT", F, "RIGHT", -w*0.23, h/4)
bb:SetPoint("LEFT", F, "LEFT", 0, -h/4)
bf:SetPoint("LEFT", F, "LEFT", 0, -h/4)
bt:SetPoint("LEFT", F, "RIGHT", -w*0.23, -h/4)
-- bt2:SetPoint("RIGHT", F, "RIGHT", -w/4, -h/4)

tb:SetVertexColor(.4, 0, 0)
tf:SetVertexColor(1, 0, 0)
tf2:SetVertexColor(1, .5, .5)
bb:SetVertexColor(0, 0, .4)
bf:SetVertexColor(.2, .3, 1)
