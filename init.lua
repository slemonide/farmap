farmap = {}

farmap.top = "sky_top.png"
farmap.water = "sky_water.png"
farmap.bottom = farmap.water
--[[
function stretch_texture(texture,h,w)
	if not w then
		w = h
	end
	local tile = "[combine:" .. h .. "x" .. w
	for x=0,h-1 do
	for y=0,w-1 do
		tile = tile .. ":" .. x .. "," .. y .. "=" .. texture
	end
	end

	return tile
end

farmap = {}

farmap.h = 10
farmap.w = 10
farmap.top = "sky_top.png"
farmap.water = "sky_water.png"

farmap.top_s = stretch_texture(farmap.top, farmap.h, farmap.w)
farmap.water_s = stretch_texture(farmap.water, farmap.h, farmap.w)
--local texture = farmap.top_s .. "^[lowpart:".. "50" .. ":" .. farmap.water
local texture = "default_wood.png^[lowpart:50:[combine:16x32:0,0=default_snow.png:0,16=default_tree.png"

minetest.register_node("farmap:stone", {
	description = "Farmap Debug Stone",
	tiles = {farmap.top .. "^[lowpart:".. "50" ..":" .. farmap.water},
	groups = {cracky=3, stone=1},
})
--]]


if minetest.get_modpath("hud_monitor") then
	function farmap.get_bottom(pos,h,w)
		if pos.y < 10 then
			return
		end
		if not w then
			w = h
		end
		local tiles = "[combine:" .. h .. "x" .. w
		for dx=0,h-1 do
		for dz=0,w-1 do
			local x = pos.x + pos.y/100*dx
			local z = pos.z + pos.y/100*dz
			local land_base = gen.landbase(x,z)
			local tile = "blue.png"
			if land_base >= 0 then
				tile = "green.png"
			end

			tiles = tiles .. ":" .. dx .. "," .. dz .. "=" .. tile
		end
		end

		return tiles
	end
end

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
	local pos = player:getpos()

	local y = pos.y
	local l = 200 -- skybox length
	local r = 200 -- distance to skybox
	local R = 5000 -- distance to horizon (how far can you see?)

	local n = 100*(0.5*l - y*r/R)/l -- % of sea on the skybox

	local side_texture = farmap.top .. "^[lowpart:".. n ..":" .. farmap.water

	farmap.bottom = farmap.get_bottom(pos,60)

	local skytextures = {
		farmap.top, -- +y
		farmap.bottom, -- -y
		side_texture, -- +z
		side_texture, -- -z
		side_texture, -- -x
		side_texture, -- +x
	}
	player:set_sky({}, "skybox", skytextures)
	end
	minetest.after(1, set_skybox)
end
minetest.after(1, set_skybox)
