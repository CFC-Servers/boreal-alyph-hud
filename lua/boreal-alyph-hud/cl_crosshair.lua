
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

BOREAL_ALYPH_HUD:RegisterCrosshairHandle()

function BOREAL_ALYPH_HUD:DrawCrosshairGeneric(x, y, accuracy)
	self:InterruptFX()

	x = x:ceil()
	y = y:ceil()
	local width = ScreenSize(1):ceil()
	local height = ScreenSize(6):ceil():max(6)
	local padding = (accuracy * ScreenSize(4)):floor()

	local accurateW = width % 2 + (width / 3):floor() - 1
	local accuratePadding = padding % 2 + (padding / 3):floor() - 1

	surface.SetDrawColor(self.CrosshairColor)
	surface.DrawRect(x - accurateW, y - accurateW, width, width)

	surface.DrawRect(x - accurateW, y - height - padding, width, height)
	surface.DrawRect(x - accurateW, y + padding + 1, width, height)

	surface.DrawRect(x - height - padding, y - accurateW, height, width)
	surface.DrawRect(x + padding + 1, y - accurateW, height, width)

	self:ContinueFX()
end
