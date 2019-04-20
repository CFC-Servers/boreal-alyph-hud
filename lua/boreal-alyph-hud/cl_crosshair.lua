
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
local ScreenSize = ScreenSize
local DLib = DLib
local HUDCommons = DLib.HUDCommons
local surface = surface
local ProtectedCall = ProtectedCall
local draw = draw
local color_black = color_black

BOREAL_ALYPH_HUD:RegisterCrosshairHandle()
local SHADOW_PADDING = 1

function BOREAL_ALYPH_HUD:DrawCrosshairGeneric(x, y, accuracy, noheight)
	x = x:floor()
	y = y:floor()

	local width = ScreenSize(1):max(3):ceil()
	local height = (ScreenSize(6) * (0.7 + accuracy * 0.3):max(1)):round():max(6)

	if noheight then
		height = width
	end

	local padding = (accuracy * ScreenSize(4)):round()
	local shadowPadding = ScreenSize(SHADOW_PADDING):max(2):round()

	local accurateW = width % 2 + (width / 3):floor() - 1

	local centerX, centerY = x - accurateW + shadowPadding, y - accurateW + shadowPadding

	surface.SetDrawColor(color_black)
	surface.DrawRect(centerX, centerY, width, width)

	surface.DrawRect(centerX, centerY - height - padding, width, height)
	surface.DrawRect(centerX, centerY + padding + width, width, height)

	surface.DrawRect(centerX - height - padding, centerY, height, width)
	surface.DrawRect(centerX + padding + width, centerY, height, width)

	centerX, centerY = centerX - shadowPadding, centerY - shadowPadding

	surface.SetDrawColor(self.CrosshairColor)
	surface.DrawRect(centerX, centerY, width, width)

	surface.DrawRect(centerX, centerY - height - padding, width, height)
	surface.DrawRect(centerX, centerY + padding + width, width, height)

	surface.DrawRect(centerX - height - padding, centerY, height, width)
	surface.DrawRect(centerX + padding + width, centerY, height, width)
end

function BOREAL_ALYPH_HUD:DrawCrosshairRifle(x, y, accuracy)
	self:DrawCrosshairGeneric(x, y, accuracy, true)
end

function BOREAL_ALYPH_HUD:DrawCrosshairRevolver(x, y, accuracy)
	self:DrawCrosshairGeneric(x, y, accuracy, true)
end

function BOREAL_ALYPH_HUD:DrawCrosshairShotgun(x, y, accuracy)
	local width = ScreenSize(1):ceil()
	local height = ScreenSize(6):ceil():max(6) * (0.7 + accuracy * 0.3):max(1)
	local size = (accuracy * ScreenSize(38))
	--size = size - size % 7
	local inLen = (size * 0.05):max(2)
	local shadowPadding = ScreenSize(SHADOW_PADDING):max(2)

	draw.NoTexture()
	--HUDCommons.DrawArcHollow(x, y, radius, segments, inLen, arc1, color)
	HUDCommons.DrawCircleHollow(x - size / 2 + shadowPadding, y - size / 2 + shadowPadding, size, size / 2, inLen, color_black)
	HUDCommons.DrawCircleHollow(x - size / 2, y - size / 2, size, size / 2, inLen, self.CrosshairColor)
end
