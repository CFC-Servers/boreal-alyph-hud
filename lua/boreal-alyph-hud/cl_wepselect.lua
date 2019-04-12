
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
local draw = draw
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

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

local function getPrintName(self)
	local class = self:GetClass()
	local phrase = language.GetPhrase(class)
	return phrase ~= class and phrase or self:GetPrintName()
end

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
			local yo = y

			for i2 = scrollStart, scrollEnd do
				local weapon = self.WeaponListInSlot[i2]

				if self:GetActiveWeaponPos() == i2 then
					surface.SetDrawColor(active)
					surface.DrawRect(x, y, aSquareW, aSquareH)

					weapon:DLibDrawWeaponSelection(x + inpadding, y + inpadding, aSquareW - inpadding * 2, aSquareH - inpadding * 2, alpha)
					y = y + ypadding + aSquareH
				else
					surface.SetDrawColor(inactive)
					surface.DrawRect(x, y, aSquareW, inaSquareH)

					--surface.SetTextColor(active)
					surface.SetFont(self.SelectorWeaponName.REGULAR)
					local text = getPrintName(weapon)
					local tw, th = surface.GetTextSize(text)

					--surface.SetTextPos(x + aSquareW / 2 - tw / 2, y + inaSquareH / 2 - th / 2)

					--surface.DrawText(text)
					draw.DrawText(text, self.SelectorWeaponName.REGULAR, x + aSquareW / 2, y + inaSquareH / 2 - th / 2, active, TEXT_ALIGN_CENTER)

					y = y + ypadding + inaSquareH
				end

				-- Note to Boreal Alyph Developers: as for me, this number looks good here
				if i2 == scrollStart and self:GetActiveWeaponPos() ~= i2 then
					surface.SetFont(self.SelectorSmallNumbers.REGULAR)
					surface.SetTextColor(active)
					surface.SetTextPos(x + inpadding, yo + inpadding)
					surface.DrawText(i)
				end
			end

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