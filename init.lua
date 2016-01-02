modpath = minetest.get_modpath("farmap")
dofile(modpath .. "/textures.lua") -- Load textures

function draw_skybox_tile(dir, pos)

	local D = 10

	local tiles = "[combine:" .. 2*D + 1 .. "x" .. 2*D + 1
	local tile = ""

	for v = -D, D do
	for h = -D, D do

		pos = {x=0,y=200,z=0}

		if dir == "px" then
			pos = {x = pos.x + D, y = pos.y + v, z = pos.z + h}
		elseif dir == "py" then
			pos = {x = pos.x + v, y = pos.y + D, z = pos.z + h}
		elseif dir == "pz" then
			pos = {x = pos.x + v, y = pos.y + h, z = pos.z + D}
		elseif dir == "nx" then
			pos = {x = pos.x - D, y = pos.y + v, z = pos.z + h}
		elseif dir == "ny" then
			pos = {x = pos.x + v, y = pos.y - D, z = pos.z + h}
		elseif dir == "nz" then
			pos = {x = pos.x + v, y = pos.y + h, z = pos.z - D}
		end

		local node_name = minetest.get_node(pos).name
		if node_name == "ignore" or node_name == "air" then
			tile = "air"
		else
			tile = "unknown"
		end

		tiles = tiles .. ":" .. v + D .. "," .. h + D .. "=" .. textures[tile]
	end
	end

	return tiles
end

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = vector.round(player:getpos())

		local dirs = {"px", "py", "pz", "nx", "ny", "nz"}
		local dir = {}

		for _,s_dir in pairs(dirs) do -- Prepare dir table
			dir[s_dir] = draw_skybox_tile(s_dir, pos)
		end

		local skytextures = {
			dir.py,
			dir.ny,
			dir.px,
			dir.nx,
			dir.nz,
			dir.pz,
		}
		player:set_sky({}, "skybox", skytextures)
	end
	minetest.after(1, set_skybox)
end
minetest.after(1, set_skybox)
