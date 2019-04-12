
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

local POS_HEALTH = BOREAL_ALYPH_HUD:DefineStaticPosition('health', 0.04, 0.87)

function BOREAL_ALYPH_HUD:PaintHealth()
	local x, y = POS_HEALTH()

	surface.SetFont(self.HealthCounterIcon.REGULAR)

	local padding = ScreenSize(self.DEF_PADDING)
	local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)
	local barWidth = ScreenSize(self.BAR_DEF_WIDTH):max(surface.GetTextSize(self:GetVarHealth()) + padding * 2)

	local w, h = surface.GetTextSize('+')

	local col = self:GetHealthFillage() > 0.3 and self.HealthColor or self.CriticalHealthColor
	surface.SetTextColor(col)

	surface.SetTextPos(x, y)
	surface.DrawText('+')

	surface.SetFont(self.HealthCounter.REGULAR)

	surface.SetTextPos(x + padding + w, y + ScreenSize(2))
	surface.DrawText(self:GetVarHealth())

	surface.SetDrawColor(col * 50)
	surface.DrawRect(x, y + h + padding, barWidth, barHeight)

	surface.SetDrawColor(col)
	surface.DrawRect(x, y + h + padding, barWidth * self:GetHealthFillage(), barHeight)

	if self:GetVarArmor() > 0 then
		self:PaintArmor(x + barWidth + ScreenSize(self.DEF_PADDING_ELEM), y)
	end
end

function BOREAL_ALYPH_HUD:PaintArmor(x, y)
	if not x or not y then
		x, y = POS_HEALTH()
	end

	surface.SetFont(self.ArmorCounterIcon.REGULAR)

	local padding = ScreenSize(self.DEF_PADDING)
	local barHeight = ScreenSize(self.BAR_DEF_HEIGHT)
	local barWidth = ScreenSize(self.BAR_DEF_WIDTH):max(surface.GetTextSize(self:GetVarHealth()) + padding * 2)

	local w, h = surface.GetTextSize('*')

	surface.SetTextColor(self.ArmorColor)

	surface.SetTextPos(x, y)
	surface.DrawText('*')

	surface.SetFont(self.HealthCounter.REGULAR)

	surface.SetTextPos(x + padding + w, y + ScreenSize(2))
	surface.DrawText(self:GetVarArmor())

	surface.SetDrawColor(self.ArmorColor * 50)
	surface.DrawRect(x, y + h + padding, barWidth, barHeight)

	surface.SetDrawColor(self.ArmorColor)
	surface.DrawRect(x, y + h + padding, barWidth * self:GetArmorFillage(), barHeight)
end

BOREAL_ALYPH_HUD:AddPaintHook('PaintHealth')