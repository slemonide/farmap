farmap = {}

farmap.top = "sky_top.png"
farmap.water = "sky_water.png"
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
--]]
minetest.register_node("farmap:stone", {
	description = "Farmap Debug Stone",
	tiles = {farmap.top .. "^[lowpart:".. "50" ..":" .. farmap.water},
	groups = {cracky=3, stone=1},
})

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
	local pos = player:getpos()

	local y = pos.y
	local l = 200 -- skybox length
	local r = 200 -- distance to skybox
	local R = 5000 -- distance to horizon (how far can you see?)

	local n = 100*(0.5*l - y*r/R)/l -- % of sea on the skybox

	local side_texture = farmap.top .. "^[lowpart:".. n ..":" .. farmap.water

	local skytextures = {
		farmap.top, -- +y
		farmap.water, -- -y
		side_texture, -- +z
		side_texture, -- -z
		side_texture, -- -x
		side_texture, -- +x
	}
	player:set_sky({}, "skybox", skytextures)
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.5 then
		set_skybox()
	end
end)
