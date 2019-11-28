
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

local BOREAL_ALYPH_HUD = BOREAL_ALYPH_HUD
local surface = surface
local ScreenSize = ScreenSize
local Matrix = Matrix
local Vector = Vector
local Angle = Angle
local DLib = DLib
local POS_HEALTH = BOREAL_ALYPH_HUD:DefineStaticPosition('health', 0.04, 0.87)

BOREAL_ALYPH_HUD.ENABLE_HEALTH_COUNTER = BOREAL_ALYPH_HUD:CreateConVar('health', '1', 'Enable health counter')
BOREAL_ALYPH_HUD.ENABLE_ARMOR_COUNTER = BOREAL_ALYPH_HUD:CreateConVar('armor', '1', 'Enable armor counter')
BOREAL_ALYPH_HUD.ENABLE_HEV_SUPPORT = BOREAL_ALYPH_HUD:CreateConVar('hev', '1', 'Enable HEV power counter')

function BOREAL_ALYPH_HUD:PaintHealth()
	if not self:GetVarAlive() or not self:GetVarWearingSuit() then return end

	if self.HUD_REV:GetBool() then
		self:PaintHealthRev1(POS_HEALTH())
	else
		self:PaintHealthRev0(POS_HEALTH())
	end
end

function BOREAL_ALYPH_HUD:PaintHealthRev0(x, y)
	if self.ENABLE_HEALTH_COUNTER:GetBool() then
		surface.SetFont(self.HealthCounterIconREV0.REGULAR)
		local w, h = surface.GetTextSize('+')
		surface.SetFont(self.HealthCounter.REGULAR)

		local padding = ScreenSize(self.DEF_PADDING)
		local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)
		local barWidth = ScreenSize(self.BAR_DEF_WIDTH:GetFloat()):max(surface.GetTextSize(self:GetVarHealth()) + padding * 2 + ScreenSize(10))

		surface.SetFont(self.HealthCounterIconREV0.REGULAR)
		local col = self:GetHealthFillage() > 0.3 and self.HealthColor or self.CriticalHealthColor
		local acol = col
		col = col:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or col.a)
		surface.SetTextColor(col)

		surface.SetTextPos(x, y)
		surface.DrawText('+')

		surface.SetFont(self.HealthCounter.REGULAR)

		surface.SetTextPos(x + padding + w, y + ScreenSize(2))
		surface.DrawText(self:GetVarHealth())

		surface.SetDrawColor((col * 50):SetAlpha(acol.a))
		surface.DrawRect(x, y + h + padding, barWidth, barHeight)

		surface.SetDrawColor(col)
		surface.DrawRect(x, y + h + padding, barWidth * self:GetHealthFillage(), barHeight)

		if self.ENABLE_HEV_SUPPORT:GetBool() then
			surface.SetFont(self.HEVPowerCounter.REGULAR)
			local w, h = surface.GetTextSize('W')
			self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, false)
		end

		if self.ENABLE_ARMOR_COUNTER:GetBool() and self:GetVarArmor() > 0 then
			self:PaintArmorRev0(x + barWidth + ScreenSize(self.DEF_PADDING_ELEM), y)
		end
	elseif self.ENABLE_ARMOR_COUNTER:GetBool() then
		if self.ENABLE_HEV_SUPPORT:GetBool() then
			surface.SetFont(self.HEVPowerCounter.REGULAR)
			local w, h = surface.GetTextSize('W')
			self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, false)
		end

		if self.ENABLE_ARMOR_COUNTER:GetBool() and self:GetVarArmor() > 0 then
			self:PaintArmorRev0(x, y)
		end
	elseif self.ENABLE_HEV_SUPPORT:GetBool() then
		surface.SetFont(self.HEVPowerCounter.REGULAR)
		local w, h = surface.GetTextSize('W')
		self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, false)
	end
end

function BOREAL_ALYPH_HUD:PaintHealthRev1(x, y)
	if self.ENABLE_HEALTH_COUNTER:GetBool() then
		surface.SetFont(self.HealthCounterIcon.REGULAR)
		local w, h = surface.GetTextSize('+')
		surface.SetFont(self.HealthCounter.REGULAR)

		local padding = ScreenSize(self.DEF_PADDING)
		local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)

		surface.SetFont(self.HealthCounterIcon.REGULAR)
		local col = self:GetHealthFillage() > 0.3 and self.HealthColor or self.CriticalHealthColor
		local acol = col
		col = col:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or col.a)
		surface.SetTextColor(col)

		surface.SetTextPos(x, y + h - ScreenSize(18))
		surface.DrawText('+')

		surface.SetFont(self.HealthCounterText.REGULAR)

		local text = DLib.i18n.localize('gui.bahud.generic.health')
		local w2, h2 = surface.GetTextSize(text)

		surface.SetTextPos(x + padding + w, y + ScreenSize(25) - h2)
		surface.DrawText(text)

		surface.SetFont(self.HealthCounter.REGULAR)

		local barWidth = ScreenSize(self.BAR_DEF_WIDTH:GetFloat()):max(surface.GetTextSize(self:GetVarHealth()) + padding * 2 + ScreenSize(23) + w2)

		surface.SetTextPos(x + padding + w + w2 + ScreenSize(17), y - ScreenSize(4))
		surface.DrawText(self:GetVarHealth())

		h = h + ScreenSize(3)

		surface.SetDrawColor((col * 50):SetAlpha(acol.a))
		surface.DrawRect(x, y + h + padding, barWidth, barHeight)

		surface.SetDrawColor(col)
		surface.DrawRect(x, y + h + padding, barWidth * self:GetHealthFillage(), barHeight)

		if self.ENABLE_HEV_SUPPORT:GetBool() then
			surface.SetFont(self.HEVPowerCounter.REGULAR)
			local w, h = surface.GetTextSize('W')
			self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, true)
		end

		if self.ENABLE_ARMOR_COUNTER:GetBool() and self:GetVarArmor() > 0 then
			self:PaintArmorRev1(x + barWidth + ScreenSize(self.DEF_PADDING_ELEM), y)
		end
	elseif self.ENABLE_ARMOR_COUNTER:GetBool() then
		if self.ENABLE_HEV_SUPPORT:GetBool() then
			surface.SetFont(self.HEVPowerCounter.REGULAR)
			local w, h = surface.GetTextSize('W')
			self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, true)
		end

		if self.ENABLE_ARMOR_COUNTER:GetBool() and self:GetVarArmor() > 0 then
			self:PaintArmorRev1(x, y)
		end
	elseif self.ENABLE_HEV_SUPPORT:GetBool() then
		surface.SetFont(self.HEVPowerCounter.REGULAR)
		local w, h = surface.GetTextSize('W')
		self:PaintLimitedHEV(x, y - ScreenSize(self.DEF_PADDING_ELEM) - h, true)
	end
end

function BOREAL_ALYPH_HUD:PaintArmorRev1(x, y)
	if not x or not y then
		x, y = POS_HEALTH()
	end

	surface.SetFont(self.ArmorCounterIcon.REGULAR)
	local w, h = surface.GetTextSize('*')
	surface.SetFont(self.ArmorCounter.REGULAR)

	local padding = ScreenSize(self.DEF_PADDING)
	local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)

	local col = self.ArmorColor:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or self.ArmorColor.a)

	surface.SetFont(self.ArmorCounterIcon.REGULAR)
	surface.SetTextColor(col)

	surface.SetTextPos(x, y + h - ScreenSize(16))
	surface.DrawText('*')

	surface.SetFont(self.ArmorCounterText.REGULAR)

	local text = DLib.i18n.localize('gui.bahud.generic.armor')
	local w2, h2 = surface.GetTextSize(text)

	surface.SetTextPos(x + padding + w, y + ScreenSize(25) - h2)
	surface.DrawText(text)

	surface.SetFont(self.ArmorCounter.REGULAR)

	local barWidth = ScreenSize(self.BAR_DEF_WIDTH:GetFloat()):max(surface.GetTextSize(self:GetVarArmor()) + padding * 2 + w2 + ScreenSize(23))

	surface.SetTextPos(x + padding + w + w2 + ScreenSize(17), y - ScreenSize(4))
	surface.DrawText(self:GetVarArmor())

	h = h + ScreenSize(3)

	surface.SetDrawColor((col * 50):SetAlpha(self.ArmorColor.a))
	surface.DrawRect(x, y + h + padding, barWidth, barHeight)

	surface.SetDrawColor(col)
	surface.DrawRect(x, y + h + padding, barWidth * self:GetArmorFillage(), barHeight)
end

BOREAL_ALYPH_HUD.LAST_FULL_SUIT = 0
BOREAL_ALYPH_HUD.LAST_FULL_SUIT_FADE = 0
BOREAL_ALYPH_HUD.LAST_NONFULL_SUIT = 0
BOREAL_ALYPH_HUD.LAST_NONFULL_SUIT_FADE = 0
BOREAL_ALYPH_HUD.LAST_NONFULL_SUIT_STATUS = false

local RealTime = RealTimeL

function BOREAL_ALYPH_HUD:PaintLimitedHEV(x, y, revision)
	if not x or not y then
		x, y = POS_HEALTH()
	end

	local suit = self:GetVarSuitPower():floor()
	if suit < 0 then return end
	local alpha = 1

	if not self.ALWAYS_DRAW_HEV_POWER:GetBool() then
		if suit >= 100 then
			if self.LAST_FULL_SUIT_FADE < RealTime() and not self.LAST_NONFULL_SUIT_STATUS then return end

			if self.LAST_NONFULL_SUIT_STATUS then
				self.LAST_FULL_SUIT = RealTime() + 0.5
				self.LAST_FULL_SUIT_FADE = RealTime() + 0.9
				self.LAST_NONFULL_SUIT_STATUS = false
			end

			alpha = 1 - RealTime():progression(self.LAST_FULL_SUIT, self.LAST_FULL_SUIT_FADE)
		else
			if not self.LAST_NONFULL_SUIT_STATUS then
				self.LAST_NONFULL_SUIT = RealTime()
				self.LAST_NONFULL_SUIT_FADE = RealTime() + 0.4
				self.LAST_NONFULL_SUIT_STATUS = true
			end

			alpha = RealTime():progression(self.LAST_NONFULL_SUIT, self.LAST_NONFULL_SUIT_FADE)
		end
	end

	local padding = ScreenSize(self.DEF_PADDING)
	local col = self.ArmorColor:ModifyAlpha((self.ENABLE_FX:GetBool() and 255 or self.ArmorColor.a) * alpha)

	if revision then
		surface.SetFont(self.HEVPowerIcon.REGULAR)
		local w, h = surface.GetTextSize('D')

		surface.SetTextColor(col)

		surface.SetTextPos(x, y - h * 0.15)
		surface.DrawText('D')

		h = h * 0.7

		surface.SetFont(self.HEVCounterText.REGULAR)

		local text = DLib.i18n.localize('gui.bahud.generic.hev_power')
		local w2, h2 = surface.GetTextSize(text)

		surface.SetTextPos(x + padding + w, y + ScreenSize(25) - h2)
		surface.DrawText(text)

		surface.SetFont(self.HEVPowerCounter.REGULAR)

		surface.SetTextPos(x + padding + w + w2 + ScreenSize(5), y + ScreenSize(2))
		surface.DrawText(suit:clamp(0, 100))
	else
		surface.SetFont(self.HEVPowerIconREV0.REGULAR)
		local w, h = surface.GetTextSize('D')

		surface.SetTextColor(col)

		surface.SetTextPos(x, y - h * 0.25)
		surface.DrawText('D')

		h = h * 0.7

		surface.SetFont(self.HEVPowerCounter.REGULAR)

		surface.SetTextPos(x + padding + w, y + ScreenSize(2))
		surface.DrawText(suit:clamp(0, 100))
	end
end

function BOREAL_ALYPH_HUD:PaintArmorRev0(x, y)
	if not x or not y then
		x, y = POS_HEALTH()
	end

	surface.SetFont(self.ArmorCounterIconREV0.REGULAR)
	local w, h = surface.GetTextSize('*')
	surface.SetFont(self.ArmorCounter.REGULAR)

	local padding = ScreenSize(self.DEF_PADDING)
	local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)
	local barWidth = ScreenSize(self.BAR_DEF_WIDTH:GetFloat()):max(surface.GetTextSize(self:GetVarArmor()) + padding * 2)

	local col = self.ArmorColor:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or self.ArmorColor.a)

	surface.SetFont(self.ArmorCounterIconREV0.REGULAR)
	surface.SetTextColor(col)

	surface.SetTextPos(x, y)
	surface.DrawText('*')

	surface.SetFont(self.ArmorCounter.REGULAR)

	surface.SetTextPos(x + padding + w, y + ScreenSize(2))
	surface.DrawText(self:GetVarArmor())

	surface.SetDrawColor((col * 50):SetAlpha(self.ArmorColor.a))
	surface.DrawRect(x, y + h + padding, barWidth, barHeight)

	surface.SetDrawColor(col)
	surface.DrawRect(x, y + h + padding, barWidth * self:GetArmorFillage(), barHeight)
end

BOREAL_ALYPH_HUD:AddFXPaintHook('PaintHealth')

function BOREAL_ALYPH_HUD:LimitedHEVHUDShouldDraw(str)
	if (str == 'LimitedHEVPower' or str == 'CHudSuitPower') and self.ENABLE_HEV_SUPPORT:GetBool() then return false end
end

BOREAL_ALYPH_HUD:AddHookCustom('HUDShouldDraw', 'LimitedHEVHUDShouldDraw')
