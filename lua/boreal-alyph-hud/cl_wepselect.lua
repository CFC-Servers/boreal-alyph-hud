
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

BOREAL_ALYPH_HUD:InitializeWeaponSelector(true)

BOREAL_ALYPH_HUD.SELECTOR_SQUARE_SPACE = 9
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_SPACE_H = 5
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_PADDING = 3
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_INACTIVE_W = 50
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_INACTIVE_H = 30
BOREAL_ALYPH_HUD.SELECTOR_BAR_HEIGHT = 4
BOREAL_ALYPH_HUD.SELECTOR_CIRCLE_SIZE = 8

BOREAL_ALYPH_HUD.SELECTOR_SQUARE_ACTIVE_W = 120
BOREAL_ALYPH_HUD.SELECTOR_SQUARE_ACTIVE_H = 70
BOREAL_ALYPH_HUD.SELECTOR_DENY_FADEOUT = 0
BOREAL_ALYPH_HUD.SELECTOR_DENY_FADEOUTS = 0

local POS_SELECTOR = BOREAL_ALYPH_HUD:DefineStaticPosition('wepselect', 0.5, 0.06)

local function getPrintName(self)
	local class = self:GetClass()
	local phrase = language.GetPhrase(class)
	return phrase ~= class and phrase or self:GetPrintName()
end

function BOREAL_ALYPH_HUD:CallWeaponSelectorDeny()
	self.SELECTOR_DENY_FADEOUTS = RealTimeL()
	self.SELECTOR_DENY_FADEOUT = RealTimeL() + 1.2
end

function BOREAL_ALYPH_HUD:DrawWeaponSelector(ply)
	if not self:ShouldDrawWeaponSelection() and self.SELECTOR_DENY_FADEOUT < RealTimeL() then return end

	if self.HUD_REV:GetBool() then
		self:DrawWeaponSelectorRev1(ply)
	else
		self:DrawWeaponSelectorRev0(ply)
	end
end

function BOREAL_ALYPH_HUD:DrawWeaponSelectorRev1(ply)
	local deny = #self.WeaponListInSlot == 0

	local width = ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) * (not deny and 5 or 6) + ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W) * (not deny and 1 or 0)
	local x, y = POS_SELECTOR()

	if self.ENABLE_FX:GetBool() and self.ENABLE_FX_DISTORT:GetBool() then
		y = y - ScreenSize(self.FX_AUTO_PADDING)
	end

	local SELECTOR_BAR_HEIGHT = ScreenSize(self.SELECTOR_BAR_HEIGHT)
	local padding = ScreenSize(self.SELECTOR_SQUARE_SPACE)
	local inpadding = ScreenSize(self.SELECTOR_SQUARE_PADDING)
	local ypadding = ScreenSize(self.SELECTOR_SQUARE_SPACE_H)
	local alpha = self:GetSelectorAlpha():max(255 - RealTimeL():progression(self.SELECTOR_DENY_FADEOUTS, self.SELECTOR_DENY_FADEOUT) * 255)
	x = x - width / 2

	local scrollStart, scrollEnd = 1, #self.WeaponListInSlot

	local active = self.SelectorColorActive2:ModifyAlpha(self.SelectorColorActive2.a / (self.ENABLE_FX:GetBool() and 140 or 255) * alpha)
	local active2 = active * 200
	local active3 = self.SelectorColorBar:ModifyAlpha(self.SelectorColorBar.a / (self.ENABLE_FX:GetBool() and 200 or 255) * alpha)
	local active4 = active * 400
	local empty = self.SelectorColorEmpty:ModifyAlpha(self.SelectorColorBar.a / (self.ENABLE_FX:GetBool() and 200 or 255) * alpha)
	local empty2 = empty * 200
	local empty3 = empty:ModifyAlpha(empty.a / (self.ENABLE_FX:GetBool() and 350 or 500) * alpha) * 200
	local empty4 = empty:ModifyAlpha(empty.a / (self.ENABLE_FX:GetBool() and 700 or 1000) * alpha) * 120
	local inactive = self.SelectorColorInactive2:ModifyAlpha((self.SelectorColorInactive2.a / 255) * alpha)
	local inactive2 = inactive:ModifyAlpha(inactive.a * 0.4) * 170
	local inactive3 = inactive:ModifyAlpha(self.SelectorColorActive2.a / (self.ENABLE_FX:GetBool() and 140 or 255) * alpha) * 500

	if #self.WeaponListInSlot > 4 then
		scrollEnd = math.min(#self.WeaponListInSlot, math.max(self:GetActiveWeaponPos() + 2, 5))
		scrollStart = math.max(1, scrollEnd - 4)
	end

	local aSquareW, aSquareH, inaSquareW, inaSquareH = ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_ACTIVE_H), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_H)

	for i = 1, 6 do
		if self:GetActiveSlot() == i and not deny then
			local y = y
			local yo = y

			for i2 = scrollStart, scrollEnd do
				local weapon = self.WeaponListInSlot[i2]
				local isactive = self:GetActiveWeaponPos() == i2

				local clip1, clip2, mclip1, mclip2 = weapon:GetClip1(), weapon:GetClip2(), weapon:GetMaxClip1(), weapon:GetMaxClip2()
				local atype1 = weapon:GetPrimaryAmmoType()
				local atype2 = weapon:GetSecondaryAmmoType()
				local isempty = true

				if atype1 < 0 and atype2 < 0 and mclip1 <= 0 and mclip2 <= 0 then
					isempty = false
				else
					if clip1 > 0 or atype1 > 0 and ply:GetAmmoCount(atype1) > 0 then
						isempty = false
					end

					if isempty and (clip2 > 0 or atype2 > 0 and ply:GetAmmoCount(atype2) > 0) then
						isempty = false
					end
				end

				local textcol = isactive and (isempty and active or active3) or isempty and empty or active

				surface.SetDrawColor(isactive and (isempty and empty3 or (active * 220):SetAlpha(alpha * .5)) or (isempty and empty4 or inactive))
				surface.DrawRect(x, y, aSquareW, aSquareH)

				weapon:DLibDrawWeaponSelection(x + inpadding, y + inpadding, aSquareW - inpadding * 2, aSquareH - inpadding * 2,
					isactive and (isempty and empty or active3) or (isempty and empty2 or active2))

				surface.SetFont(self.SelectorSmallNumbers.REGULAR)
				local text = getPrintName(weapon)
				local tw, th = surface.GetTextSize(text)

				draw.DrawText(text, self.SelectorSmallNumbers.REGULAR, x + inpadding, y + aSquareH - th - inpadding, textcol, TEXT_ALIGN_LEFT)

				local ammotext

				if atype1 >= 0 then
					local clip = weapon:GetClip1()
					local ammo = ply:GetAmmoCount(atype1)

					if clip >= 0 then
						ammotext = string.format('%d / %d', clip, ammo)
					else
						ammotext = string.format('%d', ammo)
					end
				end

				if atype2 >= 0 then
					local clip = weapon:GetClip2()
					local ammo = ply:GetAmmoCount(atype2)

					if clip >= 0 then
						if ammotext then
							ammotext = string.format('%s | %d / %d', ammotext, clip, ammo)
						else
							ammotext = string.format('- / - | %d / %d', clip, ammo)
						end
					else
						if ammotext then
							ammotext = string.format('%s | %d', ammotext, ammo)
						else
							ammotext = string.format('- / - | %d', ammo)
						end
					end
				end

				if ammotext then
					draw.DrawText(ammotext, self.SelectorSmallNumbers.REGULAR, x + inpadding, y + inpadding, textcol, TEXT_ALIGN_LEFT)
				end

				if weapon == self:GetWeapon() then
					surface.SetDrawColor(textcol)
					draw.NoTexture()
					local size = ScreenSize(self.SELECTOR_CIRCLE_SIZE)
					DLib.HUDCommons.DrawCircle(x - inpadding + aSquareW - size, y + inpadding, size, 16)
				end

				y = y + ypadding + aSquareH

				if isempty then
					if mclip1 > 0 then
						surface.SetDrawColor(empty3 * 300)
						surface.DrawRect(x, y - ypadding - 1, aSquareW, SELECTOR_BAR_HEIGHT)

						y = y + SELECTOR_BAR_HEIGHT
					end

					if mclip2 > 0 then
						surface.SetDrawColor(empty3 * 300)
						surface.DrawRect(x, y - ypadding - 1, aSquareW, SELECTOR_BAR_HEIGHT)

						y = y + SELECTOR_BAR_HEIGHT
					end
				else
					if mclip1 > 0 then
						surface.SetDrawColor(inactive3)
						surface.DrawRect(x, y - ypadding - 1, aSquareW, SELECTOR_BAR_HEIGHT)

						surface.SetDrawColor(active3)
						surface.DrawRect(x, y - ypadding - 1, aSquareW * (clip1 / mclip1):clamp(0, 1), SELECTOR_BAR_HEIGHT)

						y = y + SELECTOR_BAR_HEIGHT
					end

					if mclip2 > 0 then
						surface.SetDrawColor(inactive3)
						surface.DrawRect(x, y - ypadding - 1, aSquareW, SELECTOR_BAR_HEIGHT)

						surface.SetDrawColor(active3)
						surface.DrawRect(x, y - ypadding - 1, aSquareW * (clip2 / mclip2):clamp(0, 1), SELECTOR_BAR_HEIGHT)

						y = y + SELECTOR_BAR_HEIGHT
					end
				end
			end

			x = x + ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W) + padding
		else
			surface.SetDrawColor((#self:GetWeaponsInSlot(i) ~= 0) and inactive or inactive2)
			surface.DrawRect(x, y, inaSquareW, inaSquareH)

			surface.SetFont(self.SelectorSmallNumbers.REGULAR)
			surface.SetTextColor((#self:GetWeaponsInSlot(i) ~= 0) and active or active2)
			surface.SetTextPos(x + inpadding, y + inpadding)
			surface.DrawText(i)

			x = x + ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) + padding
		end
	end
end

function BOREAL_ALYPH_HUD:DrawWeaponSelectorRev0()
	local deny = #self.WeaponListInSlot == 0

	local width = ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) * (not deny and 5 or 6) + ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W) * (not deny and 1 or 0)
	local x, y = POS_SELECTOR()

	if self.ENABLE_FX:GetBool() and self.ENABLE_FX_DISTORT:GetBool() then
		y = y - ScreenSize(self.FX_AUTO_PADDING)
	end

	local padding = ScreenSize(self.SELECTOR_SQUARE_SPACE)
	local inpadding = ScreenSize(self.SELECTOR_SQUARE_PADDING)
	local ypadding = ScreenSize(self.SELECTOR_SQUARE_SPACE_H)
	local alpha = self:GetSelectorAlpha():max(255 - RealTimeL():progression(self.SELECTOR_DENY_FADEOUTS, self.SELECTOR_DENY_FADEOUT) * 255)
	x = x - width / 2

	local scrollStart, scrollEnd = 1, #self.WeaponListInSlot

	local active = self.SelectorColorActive:ModifyAlpha(self.ENABLE_FX:GetBool() and alpha or (self.SelectorColorActive.a / 255) * alpha)
	local inactive = self.SelectorColorInactive:ModifyAlpha((self.SelectorColorInactive.a / 255) * alpha)

	if #self.WeaponListInSlot > 6 then
		scrollEnd = math.min(#self.WeaponListInSlot, math.max(self:GetActiveWeaponPos() + 3, 7))
		scrollStart = math.max(1, scrollEnd - 6)
	end

	local aSquareW, aSquareH, inaSquareW, inaSquareH = ScreenSize(self.SELECTOR_SQUARE_ACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_ACTIVE_H), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W), ScreenSize(self.SELECTOR_SQUARE_INACTIVE_H)

	for i = 1, 6 do
		if self:GetActiveSlot() == i and not deny then
			local y = y
			local yo = y

			for i2 = scrollStart, scrollEnd do
				local weapon = self.WeaponListInSlot[i2]

				if self:GetActiveWeaponPos() == i2 then
					surface.SetDrawColor(active * 220)
					surface.DrawRect(x, y, aSquareW, aSquareH)

					weapon:DLibDrawWeaponSelection(x + inpadding, y + inpadding, aSquareW - inpadding * 2, aSquareH - inpadding * 2, active)

					surface.SetFont(self.SelectorSmallNumbers.REGULAR)
					local text = getPrintName(weapon)
					local tw, th = surface.GetTextSize(text)

					draw.DrawText(text, self.SelectorSmallNumbers.REGULAR, x + inpadding, y + aSquareH - th - inpadding, (inactive * 140):SetAlpha(alpha), TEXT_ALIGN_LEFT)

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
			if #self:GetWeaponsInSlot(i) ~= 0 then
				surface.SetDrawColor(inactive)
				surface.DrawRect(x, y, inaSquareW, inaSquareH)
			end

			surface.SetFont(self.SelectorSmallNumbers.REGULAR)
			surface.SetTextColor(active)
			surface.SetTextPos(x + inpadding, y + inpadding)
			surface.DrawText(i)

			x = x + ScreenSize(self.SELECTOR_SQUARE_INACTIVE_W) + padding
		end
	end
end

BOREAL_ALYPH_HUD:AddFXPaintHook('DrawWeaponSelector')
