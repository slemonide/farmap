modpath = minetest.get_modpath("farmap")
dofile(modpath .. "/textures.lua") -- Load textures
skybox_data = {} -- Skybox related data

function draw_skybox_tile(dir, pos)

	--pos = {x=0,y=300,z=0} -- for debug
	local D = 0
	if minetest.get_modpath("gridgen") then
		D = 20
	else
		D = 5
	end

	local tiles = "[combine:" .. 2*D + 1 .. "x" .. 2*D + 1
	local tile = ""
	local dpos = {} -- Local pos used to find blocks

	for v = -D, D do
	for h = -D, D do

		--pos = {x=0,y=200,z=0}

		if dir == "px" then
			dpos = {x = pos.x + D, y = pos.y + v, z = pos.z + h}
		elseif dir == "py" then
			dpos = {x = pos.x + v, y = pos.y + D, z = pos.z + h}
		elseif dir == "pz" then
			dpos = {x = pos.x + v, y = pos.y + h, z = pos.z + D}
		elseif dir == "nx" then
			dpos = {x = pos.x - D, y = pos.y + v, z = pos.z + h}
		elseif dir == "ny" then
			dpos = {x = pos.x + v, y = pos.y - D, z = pos.z + h}
		elseif dir == "nz" then
			dpos = {x = pos.x + v, y = pos.y + h, z = pos.z - D}
		end

		local node_name = ""
		if minetest.get_modpath("gridgen") then
			local land_base = gen.landbase(dpos.x, dpos.z)
			local temperature = gen.heat(dpos.x, dpos.y, dpos.z)
			node_name = gen.get_node(dpos.x, dpos.y, dpos.z, land_base, temperature)
		else
			node_name = minetest.get_node(dpos).name
		end
		local texture = textures[node_name]
		if not texture then -- In case of absent texture
			texture = textures["unknown"]
		end

		tiles = tiles .. ":" .. v + D .. "," .. D + h .. "=" .. texture
	end
	end

	if dir == "px" then
		tiles = tiles .. "^[transformR90FX"
	elseif dir == "nx" then
		tiles = tiles .. "^[transformR90"
	elseif dir == "nz" then
		tiles = tiles .. "^[transformR180"
	elseif dir == "pz" then
		tiles = tiles .. "^[transformFY"
	end

	return tiles
end

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = vector.round(player:getpos())
		local player_name = player:get_player_name()
		if not skybox_data[player_name] then
			skybox_data[player_name] = {}
		end

		if not skybox_data[player_name].sky_count then
			skybox_data[player_name].sky_count = 1
		end

		if skybox_data[player_name].sky_count >= 4 then
			skybox_data[player_name].sky_count = 1
		elseif skybox_data[player_name].sky_count < 4 then
			skybox_data[player_name].sky_count = skybox_data[player_name].sky_count + 1
		end

		--local dirs = {"px", "py", "pz", "nx", "ny", "nz"}
		local dirs = {"px", "nx", "nz", "pz"}

		local dir = draw_skybox_tile(dirs[skybox_data[player_name].sky_count], pos)

		skybox_data[player_name].sky[2 + skybox_data[player_name].sky_count] = dir

		player:set_sky({}, "skybox", skybox_data[player_name].sky)

	end
	minetest.after(1, set_skybox)
end
minetest.after(1, set_skybox)

minetest.after(0, function()
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if not skybox_data[player_name] then
		skybox_data[player_name] = {}
	end

	local pos = vector.round(player:getpos())

	--local dirs = {"px", "py", "pz", "nx", "ny", "nz"}
	local dirs = {"px", "pz", "nx", "nz"}
	local dir = {}

	for _,s_dir in pairs(dirs) do -- Prepare dir table
		dir[s_dir] = draw_skybox_tile(s_dir, pos)
	end

	local skytextures = {
		textures["air"],
		textures["default:dirt"],
		dir.px,
		dir.nx,
		dir.nz,
		dir.pz,
	}

--[[
	local skytextures = {
		--dir.py .. "^[transformR270",
		--dir.ny .. "^[transformR90FX",
		textures["air"],
		textures["default:dirt"],
		dir.px .. "^[transformR90FX",
		dir.nx .. "^[transformR90",
		dir.nz .. "^[transformR180",
		dir.pz .. "^[transformFY",
	}
--]]
	skybox_data[player_name].sky = skytextures
	player:set_sky({}, "skybox", skytextures)
	end)
end)
