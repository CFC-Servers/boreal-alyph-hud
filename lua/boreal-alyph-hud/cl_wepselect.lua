
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

BOREAL_ALYPH_HUD.SelectorColorActive = Color(255, 176, 0, 160)
BOREAL_ALYPH_HUD.SelectorColorInactive = Color(255, 176, 0, 160) * 160

BOREAL_ALYPH_HUD:InitializeWeaponSelector(true)

BOREAL_ALYPH_HUD.SELECTOR_SQUARE_SPACE = 9
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_SPACE_H = 5
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_PADDING = 3
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_INACTIVE_W = 50
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_INACTIVE_H = 30

BOREAL_ALYPH_HUD.SELECTOR_SQUARE_ACTIVE_W = 120
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_ACTIVE_H = 70

local POS_SELECTOR = BOREAL_ALYPH_HUD:DefineStaticPosition('wepselect', 0.5, 0.06)

function BOREAL_ALYPH_HUD:DrawWeaponSelector()
	if not self:ShouldDrawWeaponSelection() then return end

	local deny = #self.WeaponListInSlot == 0

	local width = ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) * (not deny and 5 or 6) + ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W) * (not deny and 1 or 0)
	local x, y = POS_SELECTOR()
	local padding = ScreenSize(self.SELECTOR_SQUARE_SPACE)
	local inpadding = ScreenSize(self.SELECTOR_SQUARE_PADDING)
	local ypadding = ScreenSize(self.SELECTOR_SQUARE_SPACE_H)
	local alpha = self:GetSelectorAlpha()
	x = x - width / 2

	local scrollStart, scrollEnd = 1, #self.WeaponListInSlot

	local active = self.SelectorColorActive:ModifyAlpha((self.SelectorColorActive.a / 255) * alpha)
	local inactive = self.SelectorColorInactive:ModifyAlpha((self.SelectorColorInactive.a / 255) * alpha)

	if #self.WeaponListInSlot > 10 then
		scrollEnd = math.min(#self.WeaponListInSlot, math.max(weaponPoint + 5, 11))
		scrollStart = math.max(1, scrollEnd - 10)
	end

	local aSquareW, aSquareH, inaSquareW, inaSquareH = ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_ACTIVE_H), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_H)

	for i = 1, 6 do
		if self:GetActiveSlot() == i and not deny then
			local y = y

			for i2 = scrollStart, scrollEnd do
				local weapon = self.WeaponListInSlot[i2]

				surface.SetDrawColor(self:GetActiveWeaponPos() == i2 and active or inactive)
				surface.DrawRect(x, y, aSquareW, aSquareH)

				if weapon.DrawWeaponSelection then
					weapon:DLibDrawWeaponSelection(x + inpadding, y + inpadding, aSquareW - inpadding * 3, aSquareH - inpadding * 3, alpha)
				end

				y = y + ypadding + aSquareH
			end

			-- Note to Boreal Alyph Developers: this number looks good when it is there
			-- but oh well
			--[[surface.SetTextColor(self.SelectorColorInactive)
			surface.SetTextPos(x + inpadding, y + inpadding)
			surface.DrawText(i)]]

			x = x + ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W) + padding
		else
			surface.SetDrawColor(inactive)
			surface.DrawRect(x, y, inaSquareW, inaSquareH)

			surface.SetFont(self.SelectorSmallNumbers.REGULAR)
			surface.SetTextColor(active)
			surface.SetTextPos(x + inpadding, y + inpadding)
			surface.DrawText(i)

			x = x + ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) + padding
		end
	end
end

BOREAL_ALYPH_HUD:AddPaintHook('DrawWeaponSelector')
