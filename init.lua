farmap = {}

farmap.top = "sky_top.png"
farmap.water = "sky_water.png"
farmap.bottom = farmap.water

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
	local pos = player:getpos()

	local y = pos.y

	local a_max = 50*4 -- maximum number of angles

	local dir_templ = "[combine:" .. a_max/4 .. "x" .. a_max/4

	local px = dir_templ
	local py = dir_templ
	local pz = dir_templ
	local nx = dir_templ
	local ny = dir_templ
	local nz = dir_templ
--[[

		for dx=0,h-1 do
		for dz=0,w-1 do
			local x = pos.x + pos.y/20*dx
			local z = pos.z + pos.y/20*dz
			local land_base = gen.landbase(x,z)
			local y = land_base
			local temperature = gen.heat(x, y, z)
			local node = gen.get_node(x, y, z, land_base, temperature)
			local tile = "farmap_sea.png"
			if land_base <= 0 then
				tile = "farmap_sea.png"
			elseif node == "default:sand" then
				tile = "farmap_sand.png"
			elseif node == "default:ice" then
					tile = "farmap_ice.png"
			elseif land_base >= 0 then
				tile = "green.png"
			end
			tiles = tiles .. ":" .. dx .. "," .. dz .. "=" .. tile
		end
		end
--]]

	local MIN_R = 10
	local MAX_R = 100

	for dxz=0,a_max do -- dxz - angle in x-z plane
	for dxy=0,a_max do -- dxy - angle in x-y plane
		local pi = math.pi
		local sin = math.sin
		local cos = math.cos
		local a_xz = 2*pi*(dxz/a_max)
		local a_xy = 2*pi*(dxy/a_max)

		--[[ A note about sky textures:
			px - positive x; py - pisitive y; nx - negative x
			Counting of angles always starts counter clockwise
			from the positive direction of the x-axis
		--]]
		local dir = ""
		if a_xy >= pi/4 and a_xy <= 3*pi/4 then
--			dir = "py"
			for R = MIN_R, MAX_R do
				local x = R*sin(a_xz)
				local y = R*sin(a_xy)
				local z = R*cos(a_xz)

				local land_base = gen.landbase(x,z)
				local temperature = gen.heat(x, land_base, z)
				local node = gen.get_node(x, y, z, land_base, temperature)

				if node == "" then
					py = "sky_top.png"
				else
					py = "green.png"
				end
			end
		elseif a_xy >= 5*pi/4 and a_xy <= 7*pi/4 then
--			dir = "ny"
			ny = "ny.png"
		elseif a_xz >= 7*pi/4 or a_xz <= pi/4 then -- Notice "or" here. It is there for a reason.
--			dir = "px"
			px = "px.png"
		elseif a_xz >= pi/4 and a_xz <= 3*pi/4 then
--			dir = "pz"
			pz = "pz.png"
		elseif a_xz >= 3*pi/4 and a_xz <= 5*pi/4 then
--			dir = "nx"
			nx = "nx.png"
		elseif a_xz >= 5*pi/4 and a_xz <= 7*pi/4 then
--			dir = "nz"
			nz = "nz.png"
		end
	end
	end




	local skytextures = {
		py, -- +y
		ny, -- -y
		pz, -- +z
		nz, -- -z
		nx, -- -x
		px, -- +x
	}
	player:set_sky({}, "skybox", skytextures)
	end
	minetest.after(1, set_skybox)
end
minetest.after(1, set_skybox)

minetest.register_node(":default:water_source", { -- Redefine water
	description = "Water Source",
	drawtype = "liquid",
	tiles = {farmap.water},
--	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1},
})

minetest.register_node(":default:water_flowing", {
	description = "Flowing Water",
	drawtype = "flowingliquid",
	tiles = {farmap.water},
--	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1,
		not_in_creative_inventory = 1},
})

minetest.after(0, function() -- Time is not supported for now
	minetest.setting_set("time_speed", 0)
end)

