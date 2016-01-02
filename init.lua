modpath = minetest.get_modpath("farmap")
dofile(modpath .. "/textures.lua") -- Load textures

function draw_skybox_tile(dir, pos)

	local D = 0
	if minetest.get_modpath("gridgen") then
		D = 21
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
			dir.py .. "^[transformR270",
			dir.ny .. "^[transformR90FX",
			dir.px .. "^[transformR90FX",
			dir.nx .. "^[transformR90",
			dir.nz .. "^[transformR180",
			dir.pz .. "^[transformFY",
		}
		player:set_sky({}, "skybox", skytextures)
	end
	minetest.after(10, set_skybox)
end
minetest.after(2, set_skybox)
