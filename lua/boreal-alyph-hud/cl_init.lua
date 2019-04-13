
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

_G.BOREAL_ALYPH_HUD = DLib.ConsturctClass('HUDCommonsBase', 'bahud', 'Boreal Alyph HUD')

local BOREAL_ALYPH_HUD = BOREAL_ALYPH_HUD

BOREAL_ALYPH_HUD.HealthCounter = BOREAL_ALYPH_HUD:CreateScalableFont('HealthCounter', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.ArmorCounter = BOREAL_ALYPH_HUD:CreateScalableFont('ArmorCounter', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.HealthCounterIcon = BOREAL_ALYPH_HUD:CreateScalableFont('HealthCounterIcon', {
	font = 'HalfLife2',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.ArmorCounterIcon = BOREAL_ALYPH_HUD:CreateScalableFont('ArmorCounterIcon', {
	font = 'HalfLife2',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.AmmoCounterReady = BOREAL_ALYPH_HUD:CreateScalableFont('AmmoCounterReady', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.AmmoCounterStored = BOREAL_ALYPH_HUD:CreateScalableFont('AmmoCounterStored', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 28,
	weight = 500
})

BOREAL_ALYPH_HUD.SelectorSmallNumbers = BOREAL_ALYPH_HUD:CreateScalableFont('SelectorSmallNumbers', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 14,
	weight = 500
})

BOREAL_ALYPH_HUD.SelectorWeaponName = BOREAL_ALYPH_HUD:CreateScalableFont('SelectorWeaponName', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 14,
	weight = 500
})

BOREAL_ALYPH_HUD.SelectorNames = BOREAL_ALYPH_HUD:CreateScalableFont('SelectorNames', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 18,
	weight = 500
})

BOREAL_ALYPH_HUD.HealthColor = Color(255, 176, 0, 160)
BOREAL_ALYPH_HUD.CriticalHealthColor = Color(135, 25, 25)
BOREAL_ALYPH_HUD.ArmorColor = Color(255, 176, 0, 160)
BOREAL_ALYPH_HUD.AmmoColor = Color(255, 176, 0, 160)

BOREAL_ALYPH_HUD.BAR_DEF_WIDTH = 65
BOREAL_ALYPH_HUD.BAR_AMMO_WIDTH = 90
BOREAL_ALYPH_HUD.BAR_DEF_HEIGHT = 6
BOREAL_ALYPH_HUD.DEF_PADDING = 4
BOREAL_ALYPH_HUD.DEF_PADDING_ELEM = 14

function BOREAL_ALYPH_HUD:HUDShouldDraw(str)
	if str == 'CHudAmmo' or str == 'CHudBattery' or str == 'CHudHealth' or str == 'CHudSecondaryAmmo' then return false end
end

BOREAL_ALYPH_HUD:AddHook('HUDShouldDraw')
