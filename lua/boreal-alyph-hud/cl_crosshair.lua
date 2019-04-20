
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

function BOREAL_ALYPH_HUD:DrawCrosshairGeneric(x, y, accuracy)
	x = x:ceil()
	y = y:ceil()
	local width = ScreenSize(1):ceil()
	local height = ScreenSize(6):ceil():max(6) * (0.7 + accuracy * 0.3):max(1)
	local padding = (accuracy * ScreenSize(4)):floor()
	local shadowPadding = ScreenSize(SHADOW_PADDING):max(2)

	local accurateW = width % 2 + (width / 3):floor() - 1
	local accuratePadding = padding % 2 + (padding / 3):floor() - 1

	surface.SetDrawColor(color_black)
	surface.DrawRect(x - accurateW + shadowPadding, y - accurateW + shadowPadding, width, width)

	surface.DrawRect(x - accurateW + shadowPadding, y - height - padding + shadowPadding, width, height)
	surface.DrawRect(x - accurateW + shadowPadding, y + padding + 1 + shadowPadding, width, height)

	surface.DrawRect(x - height - padding + shadowPadding, y - accurateW + shadowPadding, height, width)
	surface.DrawRect(x + padding + 1 + shadowPadding, y - accurateW + shadowPadding, height, width)

	surface.SetDrawColor(self.CrosshairColor)
	surface.DrawRect(x - accurateW, y - accurateW, width, width)

	surface.DrawRect(x - accurateW, y - height - padding, width, height)
	surface.DrawRect(x - accurateW, y + padding + 1, width, height)

	surface.DrawRect(x - height - padding, y - accurateW, height, width)
	surface.DrawRect(x + padding + 1, y - accurateW, height, width)
end

function BOREAL_ALYPH_HUD:DrawCrosshairShotgun(x, y, accuracy)
	x = x:ceil()
	y = y:ceil()
	local width = ScreenSize(1):ceil()
	local height = ScreenSize(6):ceil():max(6) * (0.7 + accuracy * 0.3):max(1)
	local size = (accuracy * ScreenSize(32)):floor():max(60)
	size = size - size % 7
	local inLen = (size * 0.05):max(2)
	local shadowPadding = ScreenSize(SHADOW_PADDING):max(2)

	draw.NoTexture()
	--HUDCommons.DrawArcHollow(x, y, radius, segments, inLen, arc1, color)
	HUDCommons.DrawCircleHollow(x - size / 2 + shadowPadding, y - size / 2 + shadowPadding, size, size / 2, inLen, color_black)
	HUDCommons.DrawCircleHollow(x - size / 2, y - size / 2, size, size / 2, inLen, self.CrosshairColor)
end
