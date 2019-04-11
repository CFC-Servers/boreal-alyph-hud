
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

local POS_AMMO = BOREAL_ALYPH_HUD:DefineStaticPosition('ammo', 0.96, 0.87)

function BOREAL_ALYPH_HUD:PaintAmmo()
	local x, y = POS_AMMO()

	if not self:ShouldDisplayAmmo() then return end

	if not self:ShouldDisplaySecondaryAmmo() then
		self:DrawPrimaryAmmo(x, y)
		return
	end

	x, y = self:DrawSecondaryAmmo(x, y)
	self:DrawPrimaryAmmo(x, y)
end

function BOREAL_ALYPH_HUD:DrawSecondaryAmmo(x, y)
	return x, y
end

function BOREAL_ALYPH_HUD:DrawPrimaryAmmo(x, y)
	surface.SetFont(self.AmmoCounterReady.REGULAR)
	local totalWidth
	local barWidth = ScreenSize(self.BAR_AMMO_WIDTH)
	local clip1, ammo1 = self:GetDisplayClip1(), self:GetDisplayAmmo1()
	local w1, h1 = surface.GetTextSize(clip1)
	local w2, h2 = 0, 0
	totalWidth = w1

	if self:ShouldDisplayAmmoStored() then
		surface.SetFont(self.AmmoCounterStored.REGULAR)
		w2, h2 = surface.GetTextSize('/' .. ammo1)
		totalWidth = totalWidth + w2
	end

	barWidth = barWidth:max(totalWidth)

	surface.SetFont(self.AmmoCounterReady.REGULAR)
	surface.SetTextColor(self.AmmoColor)
	surface.SetTextPos(x - totalWidth, y)
	surface.DrawText(clip1)

	if self:ShouldDisplayAmmoStored() then
		surface.SetFont(self.AmmoCounterStored.REGULAR)
		surface.SetTextPos(x - totalWidth + w1, y + h1 - h2)
		surface.DrawText('/' .. ammo1)
	end

	surface.SetDrawColor(self.AmmoColor * 50)
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth, ScreenSize(self.BAR_DEF_HEIGHT))
	surface.SetDrawColor(self.AmmoColor)
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth * self:GetAmmoFillage1(), ScreenSize(self.BAR_DEF_HEIGHT))
end

BOREAL_ALYPH_HUD:AddPaintHook('PaintAmmo')
