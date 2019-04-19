
-- Copyright (C) 2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

BOREAL_ALYPH_HUD.REPLACE_KILLFEED = BOREAL_ALYPH_HUD:CreateConVar('fx_replace_killfeed', '1', 'Replace killfeed when FX is on. This usually improve performance, since this one is :optimized:')
BOREAL_ALYPH_HUD.FORCE_REPLACE_KILLFEED = BOREAL_ALYPH_HUD:CreateConVar('force_replace_killfeed', '0', 'Always replace killfeed')

local _G = _G
local draw = draw
local surface = surface
local setfenv = setfenv
local getfenv = getfenv
local rawget = rawget
local RealTimeL = RealTimeL
local killicon = killicon
local Color = Color
local team = team
local table = table

local POS_KILLFEED = BOREAL_ALYPH_HUD:DefineStaticPosition('killfeed', 0.85, 0.04)

function BOREAL_ALYPH_HUD:DrawDeathNotice(x, y)
	if not self.FORCE_REPLACE_KILLFEED:GetBool() and (not self.ENABLE_FX:GetBool() or not self.REPLACE_KILLFEED:GetBool()) then return end
	return true
end

local hud_deathnotice_time = GetConVar('hud_deathnotice_time')
local track = {}

function BOREAL_ALYPH_HUD:AddDeathNotice(attacker, team1, inflictor, victim, team2)
	if not self.FORCE_REPLACE_KILLFEED:GetBool() and (not self.ENABLE_FX:GetBool() or not self.REPLACE_KILLFEED:GetBool()) then return end

	local notice = {}
	notice.ignore_time		= RealTimeL() + hud_deathnotice_time:GetFloat() * 0.9
	notice.start_fade		= RealTimeL() + hud_deathnotice_time:GetFloat() * 0.8
	notice.end_fade			= RealTimeL() + hud_deathnotice_time:GetFloat()

	notice.left				= attacker
	notice.right			= victim
	notice.icon				= inflictor

	if team1 == -1 then
		notice.color1 = Color(self.KillfeedGenericColor)
	else
		notice.color1 = Color(team.GetColor(team1))
	end

	if team2 == -1 then
		notice.color2 = Color(self.KillfeedGenericColor)
	else
		notice.color2 = Color(team.GetColor(team2))
	end

	if notice.left == notice.right then
		notice.left = nil
		notice.icon = "suicide"
	end

	table.insert(track, notice)
	return
end

local killicon = killicon
local surface = surface

local function DrawDeath(x, y, data, alpha, font)
	local w, h = killicon.GetSize(data.icon)
	if not w or not h then return end

	killicon.Draw(x, y, data.icon, 255 * alpha)
	surface.SetFont(font)
	data.color1:SetAlpha(255 * alpha)
	data.color2:SetAlpha(255 * alpha)

	if data.left then
		surface.SetTextColor(data.color1)
		local tw, th = surface.GetTextSize(data.left)
		surface.SetTextPos(x - (w / 2) - 16 - tw, y)
		h = h:max(th)
		surface.DrawText(data.left)

		surface.SetTextColor(data.color2)
		surface.SetTextPos(x + (w / 2) + 16, y)
		surface.DrawText(data.right)
	else
		surface.SetTextColor(data.color2)
		surface.SetTextPos(x + (w / 2) + 16, y)
		local tw, th = surface.GetTextSize(data.right)
		h = h:max(th)

		surface.DrawText(data.right)
	end

	return y + h * 0.70
end

local ScrWL, ScrHL = ScrWL, ScrHL
local Lerp = Lerp

function BOREAL_ALYPH_HUD:RenderDeathNotice()
	if not self.FORCE_REPLACE_KILLFEED:GetBool() and (not self.ENABLE_FX:GetBool() or not self.REPLACE_KILLFEED:GetBool()) then return end
	local x, y = POS_KILLFEED()
	local ftime = FrameTime() * 6
	local rtime = RealTimeL()

	local toremove

	for i, notice in ipairs(track) do
		if not notice.y then
			notice.y = y
		end

		notice.y = Lerp(ftime, notice.y, y)
		local ny = DrawDeath(x, notice.y, notice, 1 - rtime:progression(notice.start_fade, notice.end_fade), self.KillfeedFont.REGULAR)

		if notice.ignore_time > rtime then
			y = ny
		end

		if notice.end_fade <= rtime then
			toremove = toremove or {}
			table.insert(toremove, i)
		end
	end

	if toremove then
		table.removeValues(track, toremove)
	end
end

BOREAL_ALYPH_HUD:AddHook('DrawDeathNotice')
BOREAL_ALYPH_HUD:AddHook('AddDeathNotice')
BOREAL_ALYPH_HUD:AddPaintHook('RenderDeathNotice')
