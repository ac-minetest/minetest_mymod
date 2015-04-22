-- ICE/WATER

-- rnd freezing still water to snow if not bright enough

-- minetest.register_abm({ -- water freeze
	-- nodenames = {"default:water_source"},
	-- neighbors = {""},
	-- interval = 20,
	-- chance = 5,
	-- action = function(pos, node, active_object_count, active_object_count_wider)
		-- local p = {x=pos.x, y=pos.y+1, z=pos.z}
		-- local above = minetest.get_node(p) 
		
		-- if above.name == "default:ice" then -- depth freezing
			-- p.y=p.y+4;above = minetest.get_node(p) 
			-- if above.name == "air" then -- only freeze to depth 4
				-- minetest.set_node(pos, {name="default:ice"})
			-- end
			-- return
		-- end
	
		-- if above.name == "air" and minetest.get_node_light(p)<=LIGHT_MAX*0.7 then -- check if above not too bright
			-- minetest.set_node(pos, {name="default:ice"})
		-- end 
	-- end,
-- })


minetest.register_abm({
	nodenames = {"default:ice"},
	neighbors = {""},
	interval = 20,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		local above = minetest.get_node(p) 
		if above.name =="air" and minetest.get_node_light(p)>LIGHT_MAX*0.7 then -- snow melts -- minetest.get_node_light(p)>LIGHT_MAX-3
			minetest.set_node(pos, {name="default:water_source"})
		end
	end,
})


minetest.register_abm({ -- water freezes in contact with ice if dark and air above
	nodenames = {"default:ice"},
	neighbors = {"default:water_source"},
	interval = 20,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		local above = minetest.get_node(p) 
		if above.name =="air" and minetest.get_node_light(p)<LIGHT_MAX*0.7 then -- freeze water around
			local ngb = {{-1,0,0},{1,0,0},{0,-1,0},{0,1,0},{0,0,-1},{0,0,1}};
			for _,v in pairs(ngb) do
			p = {x=pos.x+v[1],y=pos.y+v[2],z=pos.z+v[3]};
				if minetest.get_node(p).name == "default:water_source" then minetest.set_node(pos, {name="default:ice"}) end
			end
		end
	end,
})