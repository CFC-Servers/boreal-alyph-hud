
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
BOREAL_ALYPH_HUD.ENABLE_FX_DISTORT = BOREAL_ALYPH_HUD:CreateConVar('fx_distort', '1', 'Enable distort')

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

	HUDRT = GetRenderTargetEx('boreal-alyph-hud-hudrt1111', RTW, RTH, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, textureFlags, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)

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
end

timer.Simple(0, refreshRT)
hook.Add('ScreenResolutionChanged', 'BAHUD.RefreshRT', refreshRT)

local scanlines = Material('sprops/trans/misc/tracks_wood')

function BOREAL_ALYPH_HUD:PreDrawFX(pushMatrix)
	if not HUDRT or not self.ENABLE_FX:GetBool() then
		if pushMatrix then
			cam.PushModelMatrix(pushMatrix)

			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)

			surface.DisableClipping(true)
		end

		return
	end

	render.PushRenderTarget(HUDRT)
	render.OverrideColorWriteEnable(true, true)
	render.OverrideAlphaWriteEnable(true, true)

	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()

	if pushMatrix then
		cam.PushModelMatrix(pushMatrix)

		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)

		surface.DisableClipping(true)
	end

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

function BOREAL_ALYPH_HUD:PostDrawFX2()
	if not HUDRT or not self.ENABLE_FX:GetBool() then return end

	surface.SetDrawColor(255, 255, 255)

	if self.ENABLE_FX_ABBERATION:GetBool() then
		surface.SetMaterial(HUDRTMat2)
		surface.DrawTexturedRectUV(0, 0, RTW, RTH, 0.0005, 0, 1.0005, 1)

		surface.SetMaterial(HUDRTMat1)
		surface.DrawTexturedRectUV(0, 0, RTW, RTH, -0.0005, 0, 0.9995, 1)
	end

	--HUDRTMat:SetFloat('$alpha', 1)
	HUDRTMat:SetFloat('$alpha', 0.7)
	surface.SetMaterial(HUDRTMat)
	surface.DrawTexturedRect(0, 0, RTW, RTH)
end

function BOREAL_ALYPH_HUD:PostDrawFX(matrixPushed)
	if not HUDRT or not self.ENABLE_FX:GetBool() then
		if matrixPushed then
			render.PopFilterMag()
			render.PopFilterMin()

			cam.PopModelMatrix()
			surface.DisableClipping(false)
		end

		return
	end

	if self.ENABLE_FX_SCANLINES:GetBool() then
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilFailOperation(STENCIL_KEEP)

		render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)

		if matrixPushed then
			surface.SetDrawColor(70, 70, 70, 70)

			local x1 = -ScrW() / 2

			for i = 1, ScrH(), 2 do
				surface.DrawLine(x1, i, -x1, i)
			end
		else
			surface.SetDrawColor(70, 70, 70, 140)

			local x1 = ScrW()

			for i = 1, ScrH(), 2 do
				surface.DrawLine(0, i, x1, i)
			end
		end

		render.OverrideBlend(false)
		render.SetStencilEnable(false)
	end

	if matrixPushed then
		render.PopFilterMag()
		render.PopFilterMin()

		cam.PopModelMatrix()
		surface.DisableClipping(false)
	end

	cam.End2D()

	render.OverrideAlphaWriteEnable(false)
	render.OverrideColorWriteEnable(false)

	render.PopRenderTarget()

	if matrixPushed then
		self:PostDrawFX2()
	end
end
