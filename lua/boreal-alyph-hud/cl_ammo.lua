
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

local POS_AMMO = BOREAL_ALYPH_HUD:DefineStaticPosition('ammo', 0.96, 0.87)

BOREAL_ALYPH_HUD.ENABLE_AMMO_COUNTER = BOREAL_ALYPH_HUD:CreateConVar('ammo', '1', 'Enable Ammo counter')

function BOREAL_ALYPH_HUD:PaintAmmo()
	if not self:GetVarAlive() or not self:GetVarWearingSuit() then return end
	if not self.ENABLE_AMMO_COUNTER:GetBool() then return end

	local x, y = POS_AMMO()

	if not self:ShouldDisplaySecondaryAmmo() then
		if not self:ShouldDisplayAmmo() then
			return
		end

		self:DrawPrimaryAmmo(x, y)
		return
	end

	if not self:ShouldDisplayAmmo() then
		self:DrawSecondaryAmmo(x, y)
		return
	end

	local x2, y2 = self:DrawSecondaryAmmo(x, y)
	self:DrawPrimaryAmmo(x2, y2)
end

function BOREAL_ALYPH_HUD:DrawSecondaryAmmo(x, y)
	surface.SetFont(self.AmmoCounterReady.REGULAR)
	local clip2, ammo2 = self:GetDisplayClip2(), self:GetDisplayAmmo2()
	local col = self.AmmoColor:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or self.AmmoColor.a)

	surface.SetTextColor(col)
	local barWidth
	local onlyOne1 = not self:ShouldDisplayAmmoReady2() and self:ShouldDisplayAmmoStored2()
	local onlyOne2 = self:ShouldDisplayAmmoReady2() and not self:ShouldDisplayAmmoStored2()

	if onlyOne1 or onlyOne2 then
		barWidth = ScreenSize(40)

		if onlyOne2 then
			ammo2 = clip2
		end

		local w1, h1 = surface.GetTextSize(ammo2)
		local totalWidth = w1

		surface.SetTextPos(x - w1, y)

		surface.DrawText(ammo2)

		barWidth = barWidth:max(totalWidth)

		surface.SetDrawColor(ammo2 > 0 and col or (col * 50):SetAlpha(self.AmmoColor.a))
		surface.DrawRect(x - barWidth, y + h1, barWidth, ScreenSize(self.BAR_DEF_HEIGHT))

		return x - barWidth - ScreenSize(self.DEF_PADDING_ELEM), y
	end

	barWidth = ScreenSize(self:GetDisplayMaxClip2() > 10 and 80 or 40)

	ammo2 = '/' .. ammo2

	local w1, h1 = surface.GetTextSize(clip2)
	local totalWidth = w1
	surface.SetFont(self.AmmoCounterStored.REGULAR)
	local w2, h2 = surface.GetTextSize(ammo2)

	totalWidth = totalWidth + w2

	surface.SetTextPos(x - totalWidth + w1, y + h1 - h2)
	surface.DrawText(ammo2)

	surface.SetFont(self.AmmoCounterReady.REGULAR)
	surface.SetTextPos(x - totalWidth, y)
	surface.DrawText(clip2)

	barWidth = barWidth:max(totalWidth)

	surface.SetDrawColor((col * 50):SetAlpha(self.AmmoColor.a))
	surface.DrawRect(x - barWidth, y + h1, barWidth, ScreenSize(self.BAR_DEF_HEIGHT))
	surface.SetDrawColor(col)
	surface.DrawRect(x - barWidth, y + h1, barWidth * self:GetAmmoFillage2(), ScreenSize(self.BAR_DEF_HEIGHT))

	return x - barWidth - ScreenSize(self.DEF_PADDING_ELEM), y
end

function BOREAL_ALYPH_HUD:DrawPrimaryAmmo(x, y)
	local totalWidth = 0
	local barWidth = ScreenSize(self.BAR_AMMO_WIDTH:GetFloat())
	local clip1, ammo1 = self:GetDisplayClip1(), self:GetDisplayAmmo1()
	local w2, h2 = 0, 0

	local col = self.AmmoColor:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or self.AmmoColor.a)

	if self:ShouldDisplayAmmoStored() then
		surface.SetFont(self.AmmoCounterStored.REGULAR)
		w2, h2 = surface.GetTextSize('/' .. ammo1)
		totalWidth = totalWidth + w2
	elseif not self:ShouldDisplayAmmoReady() then
		clip1 = ammo1
	end

	surface.SetFont(self.AmmoCounterReady.REGULAR)
	local w1, h1 = surface.GetTextSize(clip1)
	totalWidth = totalWidth + w1

	barWidth = barWidth:max(totalWidth)

	surface.SetFont(self.AmmoCounterReady.REGULAR)
	surface.SetTextColor(col)
	surface.SetTextPos(x - totalWidth, y)
	surface.DrawText(clip1)

	if self:ShouldDisplayAmmoStored() then
		surface.SetFont(self.AmmoCounterStored.REGULAR)
		surface.SetTextPos(x - totalWidth + w1, y + h1 - h2)
		surface.DrawText('/' .. ammo1)
	end

	surface.SetFont(self.HEVCounterText.REGULAR)

	local text = DLib.i18n.localize('gui.bahud.generic.ammo')
	local w3, h3 = surface.GetTextSize(text)

	surface.SetTextPos(x - w2 - w1 - w3 * 2, y + ScreenSize(29) - h3)
	surface.DrawText(text)

	totalWidth = totalWidth + w3 * 2
	barWidth = barWidth:max(totalWidth)

	surface.SetDrawColor((col * 50):SetAlpha(self.AmmoColor.a))
	surface.DrawRect(x - barWidth, y + h1, barWidth, ScreenSize(self.BAR_DEF_HEIGHT))
	surface.SetDrawColor(col)
	surface.DrawRect(x - barWidth, y + h1, barWidth * self:GetAmmoFillage1(), ScreenSize(self.BAR_DEF_HEIGHT))
end

BOREAL_ALYPH_HUD:AddFXPaintHook('PaintAmmo')
