
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

BOREAL_ALYPH_HUD.HealthCounterIcon = BOREAL_ALYPH_HUD:CreateScalableFont('HealthCounterIconRV1', {
	font = 'HalfLife2',
	size = 27,
	weight = 500
})

BOREAL_ALYPH_HUD.HealthCounterIconREV0 = BOREAL_ALYPH_HUD:CreateScalableFont('HealthCounterIconRV0', {
	font = 'HalfLife2',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.HealthCounterText = BOREAL_ALYPH_HUD:CreateScalableFont('HealthCounterText', {
	font = 'Roboto Mono',
	extended = true,
	size = 15,
	weight = 500
})

BOREAL_ALYPH_HUD.ArmorCounterIcon = BOREAL_ALYPH_HUD:CreateScalableFont('ArmorCounterIconRV1', {
	font = 'HalfLife2',
	size = 27,
	weight = 500
})

BOREAL_ALYPH_HUD.ArmorCounterIconREV0 = BOREAL_ALYPH_HUD:CreateScalableFont('ArmorCounterIconRV0', {
	font = 'HalfLife2',
	size = 40,
	weight = 500
})

BOREAL_ALYPH_HUD.ArmorCounterText = BOREAL_ALYPH_HUD:CreateScalableFont('ArmorCounterText', {
	font = 'Roboto Mono',
	extended = true,
	size = 15,
	weight = 500
})

BOREAL_ALYPH_HUD.HEVPowerIcon = BOREAL_ALYPH_HUD:CreateScalableFont('HEVPowerIconRV1', {
	font = 'HalfLife2',
	size = 37,
	weight = 400
})

BOREAL_ALYPH_HUD.HEVPowerIconREV0 = BOREAL_ALYPH_HUD:CreateScalableFont('HEVPowerIconRV0', {
	font = 'HalfLife2',
	size = 50,
	weight = 400
})

BOREAL_ALYPH_HUD.HEVCounterText = BOREAL_ALYPH_HUD:CreateScalableFont('HEVCounterText', {
	font = 'Roboto Mono',
	extended = true,
	size = 15,
	weight = 500
})

BOREAL_ALYPH_HUD.HEVPowerCounter = BOREAL_ALYPH_HUD:CreateScalableFont('HEVPowerCounter', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 32,
	weight = 400
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

BOREAL_ALYPH_HUD.AmmoCounterText = BOREAL_ALYPH_HUD:CreateScalableFont('AmmoCounterText', {
	font = 'Roboto Mono',
	extended = true,
	size = 15,
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
	extended = true,
	weight = 500
})

BOREAL_ALYPH_HUD.SelectorNames = BOREAL_ALYPH_HUD:CreateScalableFont('SelectorNames', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 18,
	extended = true,
	weight = 500
})

BOREAL_ALYPH_HUD.KillfeedFont = BOREAL_ALYPH_HUD:CreateScalableFont('Killfeed', {
	font = 'Alte DIN 1451 Mittelschrift',
	size = 18,
	weight = 500
})

BOREAL_ALYPH_HUD.HealthColor = BOREAL_ALYPH_HUD:CreateColor2('health', 'BAHUD Health Color', 255, 176, 0, 160)
BOREAL_ALYPH_HUD.CriticalHealthColor = BOREAL_ALYPH_HUD:CreateColor2('crit_health', 'BAHUD Critical Health Color', 185, 45, 45)
BOREAL_ALYPH_HUD.ArmorColor = BOREAL_ALYPH_HUD:CreateColor2('armor', 'BAHUD Armor Color', 255, 176, 0, 160)
BOREAL_ALYPH_HUD.AmmoColor = BOREAL_ALYPH_HUD:CreateColor2('ammo', 'BAHUD Ammo Color', 255, 176, 0, 160)
BOREAL_ALYPH_HUD.KillfeedGenericColor = BOREAL_ALYPH_HUD:CreateColor2('killfeed', 'BAHUD Killfeed Generic', 255, 176, 0)
BOREAL_ALYPH_HUD.CrosshairColor = BOREAL_ALYPH_HUD:CreateColor2('crosshair', 'BAHUD Crosshair Color', 255, 176, 0)

BOREAL_ALYPH_HUD.BAR_DEF_WIDTH = BOREAL_ALYPH_HUD:CreateConVar('def_line_width', '65', 'Default line width on HUD', true)
BOREAL_ALYPH_HUD.BAR_AMMO_WIDTH = BOREAL_ALYPH_HUD:CreateConVar('def_ammo_width', '90', 'Default line width of ammo HUD', true)
BOREAL_ALYPH_HUD.HUD_REV = BOREAL_ALYPH_HUD:CreateConVar('rev', '1', 'HUD Revision. 0 for old, 1 for new', false)
BOREAL_ALYPH_HUD.ALWAYS_DRAW_HEV_POWER = BOREAL_ALYPH_HUD:CreateConVar('always_draw_hev', '1', 'Always draw HEV power icon', false)
BOREAL_ALYPH_HUD.AMMO_ICON_SIZE = 12
BOREAL_ALYPH_HUD.BAR_DEF_HEIGHT = 4
BOREAL_ALYPH_HUD.DEF_PADDING = 4
BOREAL_ALYPH_HUD.DEF_PADDING_ELEM = 14

BOREAL_ALYPH_HUD:DefinePaintGroup('FX', false)

function BOREAL_ALYPH_HUD:HUDShouldDraw(str)
	if (str == 'CHudAmmo' or str == 'CHudSecondaryAmmo') and self.ENABLE_AMMO_COUNTER:GetBool() or (str == 'CHudBattery' and self.ENABLE_ARMOR_COUNTER:GetBool()) or (str == 'CHudHealth' and self.ENABLE_HEALTH_COUNTER:GetBool()) then return false end
end

BOREAL_ALYPH_HUD:AddHook('HUDShouldDraw')
