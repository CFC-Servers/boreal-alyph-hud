
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
local render = render
local Matrix = Matrix

--[[
	Achieved With
   _____                       _
  / ____|                     ( )
 | |  __  __ _ _ __ _ __ _   _|/ ___
 | | |_ |/ _` | '__| '__| | | | / __|
 | |__| | (_| | |  | |  | |_| | \__ \
  \_____|\__,_|_|  |_|   \__, | |___/
 |  \/  |         | |     __/ |
 | \  / | ___   __| |    |___/
 | |\/| |/ _ \ / _` |
 | |  | | (_) | (_| |
 |_|  |_|\___/ \__,_|
           _____ _____
     /\   |  __ \_   _|
    /  \  | |__) || |
   / /\ \ |  ___/ | |
  / ____ \| |    _| |_
 /_/    \_\_|   |_____|

almost died from aids while creating effects without shader access
]]

local HUDRT, HUDRTComposite, ScanlinesRT, HUDRTMat, HUDRTMat1, HUDRTMat2, HUDRTMat3, ScanlinesRTMat, HUDRTCompositeMat
local RTW, RTH

BOREAL_ALYPH_HUD.ENABLE_FX = BOREAL_ALYPH_HUD:CreateConVar('fx', '1', 'Enable HUD ~~SweetFX~~ FX')
BOREAL_ALYPH_HUD.ENABLE_FX_SCANLINES = BOREAL_ALYPH_HUD:CreateConVar('fx_scanlines', '1', 'Enable scanlines')
BOREAL_ALYPH_HUD.ENABLE_FX_ABBERATION = BOREAL_ALYPH_HUD:CreateConVar('fx_abberation', '1', 'Enable abberation')
BOREAL_ALYPH_HUD.ENABLE_FX_ABBERATION_R = BOREAL_ALYPH_HUD:CreateConVar('fx_abberation_r', '1', 'Enable realistic abberation. Only have effect with distort on')
BOREAL_ALYPH_HUD.ENABLE_FX_DISTORT = BOREAL_ALYPH_HUD:CreateConVar('fx_distort', '1', 'Enable distort')
BOREAL_ALYPH_HUD.FX_DEBUG = BOREAL_ALYPH_HUD:CreateConVar('fx_distort_debug', '0', 'Draw pieces of distortion')

local SCREEN_POLIES = {}
local SCREEN_POLIES1 = {}
local SCREEN_POLIES2 = {}

BOREAL_ALYPH_HUD.FX_AUTO_PADDING = 15

local function refreshRT()
	local w, h = ScrW(), ScrH()
	RTW, RTH = 0, 0

	for i = 4, 12 do
		if math.pow(2, i) >= w then
			RTW = math.pow(2, i)
			break
		end
	end

	for i = 4, 12 do
		if math.pow(2, i) >= h then
			RTH = math.pow(2, i)
			break
		end
	end

	local textureFlags = 0
	--textureFlags = textureFlags + 16 -- anisotropic
	textureFlags = textureFlags + 256 -- no mipmaps
	textureFlags = textureFlags + 2048 -- Texture is procedural
	textureFlags = textureFlags + 32768 -- Texture is a render target
	-- textureFlags = textureFlags + 67108864 -- Usable as a vertex texture

	HUDRT = GetRenderTargetEx('boreal-alyph-hud-hudrt-' .. RTW .. '-' .. RTH, RTW, RTH, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, textureFlags, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)

	HUDRTMat = CreateMaterial('boreal-alyph-hud-hudrt', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '1 1 1',
		['$color2'] = '1 1 1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$additive'] = '0',
	})

	HUDRTMat:SetFloat('$alpha', '1')

	HUDRTMat1 = CreateMaterial('boreal-alyph-hud-hudrt1', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '1 0 1',
		['$alpha'] = '0.75',
		['$nolod'] = '1',
		['$additive'] = '1',
	})

	HUDRTMat2 = CreateMaterial('boreal-alyph-hud-hudrt2', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 1 0',
		['$alpha'] = '0.75',
		['$nolod'] = '1',
		['$additive'] = '0',
	})

	HUDRTMat:SetTexture('$basetexture', HUDRT)
	HUDRTMat1:SetTexture('$basetexture', HUDRT)
	HUDRTMat2:SetTexture('$basetexture', HUDRT)
	HUDRTMat1:SetVector('$color', Color(255, 0, 0):ToVector())
	HUDRTMat2:SetVector('$color', Color(0, 255, 0):ToVector())

	local paddingy = -ScreenSize(1)
	--local distortAmount = ScreenSize(30) * 1000
	local distortAmount = ScreenSize(30)
	local points = {0, h * 0.04, h * 0.07, h * 0.08, h * 0.09, h * 0.08, h * 0.07, h * 0.04, 0}

	for x = 0, w + 10, 10 do
		--local pi1 = -math.pow(math.sin(x:progression(0, w) * math.pi) * distortAmount, 1 / 3) * 1.3
		--local pi2 = -math.pow(math.sin((x + 10):progression(0, w) * math.pi) * distortAmount, 1 / 3) * 1.3

		--local pi1 = -math.sin(x:progression(0, w) * math.pi) * distortAmount
		--local pi2 = -math.sin((x + 10):progression(0, w) * math.pi) * distortAmount

		local pi1 = -math.tbezier(x:progression(0, w), points)
		local pi2 = -math.tbezier((x + 10):progression(0, w), points)

		table.insert(SCREEN_POLIES, {
			{x = x, y = -pi1 + paddingy, u = x / RTW, v = 0},
			{x = x + 10, y = -pi2 + paddingy, u = (x + 10) / RTW, v = 0},
			{x = x + 10, y = pi2 + h - paddingy, u = (x + 10) / RTW, v = h / RTH},
			{x = x, y = pi1 + h - paddingy, u = x / RTW, v = h / RTH},
		})

		local abberation = 0.0003 * 3 * (x < w / 3 and (1 - x:progression(0, w / 3)) or x > w * 0.66 and x:progression(w * 0.66, w) or (1 / 3))

		if not BOREAL_ALYPH_HUD.ENABLE_FX_ABBERATION_R:GetBool() then
			abberation = 0.0003
		end

		table.insert(SCREEN_POLIES1, {
			{x = x, y = -pi1 + paddingy, u = x / RTW + abberation, v = 0},
			{x = x + 10, y = -pi2 + paddingy, u = (x + 10) / RTW + abberation, v = 0},
			{x = x + 10, y = pi2 + h - paddingy, u = (x + 10) / RTW + abberation, v = h / RTH},
			{x = x, y = pi1 + h - paddingy, u = x / RTW + abberation, v = h / RTH},
		})

		table.insert(SCREEN_POLIES2, {
			{x = x, y = -pi1 + paddingy, u = x / RTW - abberation, v = 0},
			{x = x + 10, y = -pi2 + paddingy, u = (x + 10) / RTW - abberation, v = 0},
			{x = x + 10, y = pi2 + h - paddingy, u = (x + 10) / RTW - abberation, v = h / RTH},
			{x = x, y = pi1 + h - paddingy, u = x / RTW - abberation, v = h / RTH},
		})
	end
end

timer.Simple(0, refreshRT)
hook.Add('ScreenResolutionChanged', 'BAHUD.RefreshRT', refreshRT)
cvars.AddChangeCallback(BOREAL_ALYPH_HUD.ENABLE_FX_ABBERATION_R:GetName(), refreshRT, 'BAHUD')

local scanlines = Material('sprops/trans/misc/tracks_wood')

function BOREAL_ALYPH_HUD:GetFXMaterial()
	return HUDRTMat
end

function BOREAL_ALYPH_HUD:GetFXRenderTarget()
	return HUDRT
end

function BOREAL_ALYPH_HUD:PreHUDPaint()
	if not HUDRT or not self.ENABLE_FX:GetBool() then return end

	render.PushRenderTarget(HUDRT)
	render.OverrideColorWriteEnable(true, true)
	render.OverrideAlphaWriteEnable(true, true)

	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	surface.DisableClipping(true)

	if self.ENABLE_FX_SCANLINES:GetBool() then
		render.SetStencilEnable(true)
		render.ClearStencil()

		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_REPLACE)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(1)
	end
end

function BOREAL_ALYPH_HUD:PostHUDPaint()
	if not HUDRT or not self.ENABLE_FX:GetBool() then return end

	if self.ENABLE_FX_SCANLINES:GetBool() then
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilFailOperation(STENCIL_KEEP)

		render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)

		surface.SetDrawColor(70, 70, 70, 140)

		local x1 = ScrW()

		for i = 1, ScrH(), 2 do
			surface.DrawLine(0, i, x1, i)
		end

		render.OverrideBlend(false)
		render.SetStencilEnable(false)
	end

	render.PopFilterMag()
	render.PopFilterMin()

	surface.DisableClipping(false)

	cam.End2D()

	render.OverrideAlphaWriteEnable(false)
	render.OverrideColorWriteEnable(false)

	render.PopRenderTarget()

	surface.SetDrawColor(255, 255, 255)
	HUDRTMat:SetFloat('$alpha', 0.7)

	if self.ENABLE_FX_DISTORT:GetBool() then
		if self.ENABLE_FX_ABBERATION:GetBool() then
			surface.SetMaterial(HUDRTMat1)

			for i, poly in ipairs(SCREEN_POLIES1) do
				surface.DrawPoly(poly)
			end

			surface.SetMaterial(HUDRTMat2)

			for i, poly in ipairs(SCREEN_POLIES2) do
				surface.DrawPoly(poly)
			end
		end

		surface.SetMaterial(HUDRTMat)

		for i, poly in ipairs(SCREEN_POLIES) do
			surface.DrawPoly(poly)
		end

		if self.FX_DEBUG:GetBool() then
			surface.SetDrawColor(127, 127, 127)

			for i, poly in ipairs(SCREEN_POLIES) do
				DLib.HUDCommons.DrawPolyFrame(poly)
			end
		end
	else
		if self.ENABLE_FX_ABBERATION:GetBool() then
			surface.SetMaterial(HUDRTMat2)
			surface.DrawTexturedRectUV(0, 0, RTW, RTH, 0.0005, 0, 1.0005, 1)

			surface.SetMaterial(HUDRTMat1)
			surface.DrawTexturedRectUV(0, 0, RTW, RTH, -0.0005, 0, 0.9995, 1)
		end

		surface.SetMaterial(HUDRTMat)
		surface.DrawTexturedRect(0, 0, RTW, RTH)
	end
end
