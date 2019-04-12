
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

local HUDRT, ScanlinesRT, HUDRTMat, HUDRTMat1, HUDRTMat2, HUDRTMat3, ScanlinesRTMat
local RTW, RTH

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
	textureFlags = textureFlags + 16 -- anisotropic
	textureFlags = textureFlags + 256 -- no mipmaps
	textureFlags = textureFlags + 2048 -- Texture is procedural
	textureFlags = textureFlags + 32768 -- Texture is a render target
	-- textureFlags = textureFlags + 67108864 -- Usable as a vertex texture

	HUDRT = GetRenderTargetEx('boreal-alyph-hud-hudrt1111', RTW, RTH, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, textureFlags, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
	ScanlinesRT = GetRenderTargetEx('boreal-alyph-hud-scanlines', RTW, RTH, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, textureFlags, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)

	render.PushRenderTarget(ScanlinesRT)

	render.OverrideColorWriteEnable(true, true)
	render.OverrideAlphaWriteEnable(true, true)

	render.Clear(0, 0, 0, 255, true, true)

	cam.Start2D()

	surface.SetDrawColor(255, 255, 255)

	for i = 1, ScrH(), 2 do
		surface.DrawLine(0, i, ScrW(), i)
	end

	cam.End2D()

	render.OverrideColorWriteEnable(false)
	render.OverrideAlphaWriteEnable(false)

	render.PopRenderTarget()

	ScanlinesRTMat = CreateMaterial('boreal-alyph-hud-scanlines', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '1 1 1',
		['$color2'] = '1 1 1',
		['$alpha'] = '1',
		['$additive'] = '0',
	})

	HUDRTMat = CreateMaterial('boreal-alyph-hud-hudrt', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '1 1 1',
		['$color2'] = '1 1 1',
		['$alpha'] = '1',
		['$additive'] = '0',
	})

	HUDRTMat1 = CreateMaterial('boreal-alyph-hud-hudrt' .. math.random(), 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '1 0 1',
		['$alpha'] = '0.75',
		['$additive'] = '1',
	})

	HUDRTMat2 = CreateMaterial('boreal-alyph-hud-hudrt' .. math.random(), 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 1 0',
		['$alpha'] = '0.75',
		['$additive'] = '1',
	})

	HUDRTMat3 = CreateMaterial('boreal-alyph-hud-hudrt' .. math.random(), 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 0 1',
		['$alpha'] = '0.75',
		['$additive'] = '1',
	})

	HUDRTMat4 = CreateMaterial('boreal-alyph-hud-hudrt' .. math.random(), 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 0 0',
		['$alpha'] = '0.6',
		['$additive'] = '0',
	})

	HUDRTMat:SetTexture('$basetexture', HUDRT)
	HUDRTMat1:SetTexture('$basetexture', HUDRT)
	HUDRTMat2:SetTexture('$basetexture', HUDRT)
	HUDRTMat3:SetTexture('$basetexture', HUDRT)
	HUDRTMat4:SetTexture('$basetexture', HUDRT)
	ScanlinesRTMat:SetTexture('$basetexture', ScanlinesRT)

	HUDRTMat1:SetVector('$color', Color(255, 0, 0):ToVector())
	HUDRTMat2:SetVector('$color', Color(0, 255, 0):ToVector())
	HUDRTMat3:SetVector('$color', Color(0, 0, 255):ToVector())
	HUDRTMat4:SetVector('$color', Color(0, 0, 0):ToVector())
end

timer.Simple(0, refreshRT)

local scanlines = Material('sprops/trans/misc/tracks_wood')

function BOREAL_ALYPH_HUD:PreHUDPaint()
	if not HUDRT then return end

	render.PushRenderTarget(HUDRT)
	render.OverrideColorWriteEnable(true, true)
	render.OverrideAlphaWriteEnable(true, true)

	render.Clear(75, 75, 75, 0, true, true)

	surface.DisableClipping(true)
	cam.Start2D()
end

function BOREAL_ALYPH_HUD:PostHUDPaint()
	if not HUDRT then return end

	cam.End2D()
	surface.DisableClipping(false)
	render.PopRenderTarget()

	render.OverrideColorWriteEnable(false)
	render.OverrideAlphaWriteEnable(false)

	render.SetStencilEnable(true)
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)

	surface.SetMaterial(ScanlinesRTMat)
	surface.SetDrawColor(255, 255, 255)
	--surface.DrawTexturedRect(0, 0, ScrW() - 400, ScrH())

	for i = 1, ScrH(), 2 do
		surface.DrawLine(0, i, ScrW(), i)
	end

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCIL_KEEP)

	surface.SetDrawColor(255, 255, 255)
	HUDRTMat:SetFloat('$alpha', 1)
	surface.SetMaterial(HUDRTMat)
	surface.DrawTexturedRect(0, 0, RTW, RTH)

	render.ClearStencil()

	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)

	for i = 2, ScrH(), 2 do
		surface.DrawLine(0, i, ScrW(), i)
	end

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCIL_KEEP)

	surface.SetMaterial(HUDRTMat)
	HUDRTMat:SetFloat('$alpha', 0.3)
	surface.DrawTexturedRect(0, 0, RTW, RTH)

	render.SetStencilEnable(false)

	--[[
	render.SetMaterial(HUDRTMat3)
	render.DrawScreenQuadEx(0, 0, RTW, RTH)

	render.SetMaterial(HUDRTMat1)
	render.DrawScreenQuadEx(-1, 0, RTW - 1, RTH)

	render.SetMaterial(HUDRTMat2)
	render.DrawScreenQuadEx(1, 0, RTW + 1, RTH)
	]]

	surface.SetDrawColor(255, 255, 255)

	--surface.SetMaterial(HUDRTMat)
	--surface.DrawTexturedRect(0, 0, RTW, RTH)
	--[[surface.SetMaterial(HUDRTMat4)
	surface.DrawTexturedRect(0, 0, RTW, RTH)

	for i = 1, 2 do
		surface.SetMaterial(HUDRTMat1)
		surface.DrawTexturedRectUV(0, 0, RTW, RTH, 0.0005, 0, 1.0005, 1)

		surface.SetMaterial(HUDRTMat2)
		surface.DrawTexturedRectUV(0, 0, RTW, RTH, -0.0001, 0, 0.9999, 1)

		surface.SetMaterial(HUDRTMat3)
		surface.DrawTexturedRectUV(0, 0, RTW, RTH, 0, 0, 1, 1)
	end]]
end
