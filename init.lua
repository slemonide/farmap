modpath = minetest.get_modpath("farmap")
dofile(modpath .. "/textures.lua") -- Load textures

local pi = math.pi
local sin = math.sin
local cos = math.cos

local max_size = 10 -- Maximum height and width of one of the sky textures

function draw_skybox_tile(dir, pos)

	local min_R = 0 -- Min viewing range
	local max_R = 3 -- Max viewing range

	local angle = pi/2 -- angle for the skybox tile

	local tiles = "[combine:" .. max_size .. "x" .. max_size
	local tile = ""

	for v = 0, max_size do
		local v_a = angle * (v / max_size) - pi/4
		for h = 0, max_size do
			local h_a = angle * (h / max_size) - pi/4

			local R = min_R
			local tile_done = false
			while R <= max_R and not tile_done do
				local x = R * cos(h_a)
				local y = R * cos(v_a)
				local z = R * sin(h_a)

				if dir == "nx" then
					x = -x
				elseif dir == "ny" then
					y = -y
				elseif dir == "nz" then
					z = -z
				end

				pos = {x = pos.x + x ,y = pos.y + y, z = pos.z + z}
				local node_name = minetest.get_node(pos).name
--				print(node_name)
				if node_name ~= "ignore" and node_name ~= "air" then
					tile = "unknown"
					tile_done = true
				elseif R == max_R then
					tile = "air"
					tile_done = true
				end

				R = R + 1
			end

			tiles = tiles .. ":" .. v - 1 .. "," .. h - 1 .. "=" .. textures[tile]
		end
	end

	return tiles
end

function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = player:getpos()

		local dirs = {"px", "py", "pz", "nx", "ny", "nz"}
		local dir = {}

		for _,s_dir in pairs(dirs) do -- Prepare dir table
			dir[s_dir] = draw_skybox_tile(s_dir, pos)
		end

		--print(minetest.serialize(dir.px))

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
	minetest.after(5, set_skybox)
end
minetest.after(1, set_skybox)
