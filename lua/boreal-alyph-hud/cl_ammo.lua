
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

function BOREAL_ALYPH_HUD:PaintAmmo()
	local x, y = POS_AMMO()

	local def = Matrix()
	def:Translate(Vector(x, y))

	if self.ENABLE_FX:GetBool() then
		--def:Scale(Vector(1.1, 1))
		def:Rotate(Angle(0, 3))
		def:SetField(1, 2, 0.1)
	end

	surface.DisableClipping(true)

	if not self:ShouldDisplaySecondaryAmmo() then
		if not self:ShouldDisplayAmmo() then
			surface.DisableClipping(false)
			return
		end

		self:PreDrawFX(def)
		self:DrawPrimaryAmmo(0, 0)
		self:PostDrawFX(true)

		return
	end

	if not self:ShouldDisplayAmmo() then
		self:PreDrawFX(def)
		self:DrawSecondaryAmmo(0, 0)
		self:PostDrawFX(true)

		return
	end

	self:PreDrawFX(def)
	local x2, y2 = self:DrawSecondaryAmmo(0, 0)
	self:DrawPrimaryAmmo(x2, y2 + ScreenSize(1))
	self:PostDrawFX(true)
end

function BOREAL_ALYPH_HUD:DrawSecondaryAmmo(x, y)
	surface.SetFont(self.AmmoCounterReady.REGULAR)
	local clip2, ammo2 = self:GetDisplayClip2(), self:GetDisplayAmmo2()
	local col = self.AmmoColor:ModifyAlpha(self.ENABLE_FX:GetBool() and 255 or self.AmmoColor.a)

	surface.SetTextColor(col)
	local barWidth = ScreenSize(40) -- Althrough there is no bar in gmod, we still use this for padding
	-- scratch that, we got clip

	if not self:ShouldDisplayAmmoReady2() and self:ShouldDisplayAmmoStored2() then
		local w1, h1 = surface.GetTextSize(ammo2)
		local totalWidth = w1

		surface.SetTextPos(x - w1, y)
		surface.DrawText(ammo2)

		barWidth = barWidth:max(totalWidth)

		surface.SetDrawColor(ammo2 > 0 and col or (col * 50):SetAlpha(self.AmmoColor.a))
		surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth, ScreenSize(self.BAR_DEF_HEIGHT))

		return x - barWidth - ScreenSize(self.DEF_PADDING_ELEM), y
	end

	ammo2 = '/' .. ammo2

	local barWidth = ScreenSize(40)
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
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth, ScreenSize(self.BAR_DEF_HEIGHT))
	surface.SetDrawColor(col)
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth * self:GetAmmoFillage2(), ScreenSize(self.BAR_DEF_HEIGHT))

	return x - barWidth - ScreenSize(self.DEF_PADDING_ELEM), y
end

function BOREAL_ALYPH_HUD:DrawPrimaryAmmo(x, y)
	local totalWidth = 0
	local barWidth = ScreenSize(self.BAR_AMMO_WIDTH)
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

	surface.SetDrawColor((col * 50):SetAlpha(self.AmmoColor.a))
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth, ScreenSize(self.BAR_DEF_HEIGHT))
	surface.SetDrawColor(col)
	surface.DrawRect(x - barWidth, y + h1 + ScreenSize(self.DEF_PADDING), barWidth * self:GetAmmoFillage1(), ScreenSize(self.BAR_DEF_HEIGHT))
end

BOREAL_ALYPH_HUD:AddPaintHook('PaintAmmo')
