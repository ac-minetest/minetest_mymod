-- ICE/WATER

-- rnd freezing still water to snow if not bright enough

minetest.register_abm({ -- water freeze
	nodenames = {"default:water_source"},
	neighbors = {""},
	interval = 20,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		local above = minetest.get_node(p) 
		if above.name == "air" and minetest.get_node_light(p)<=LIGHT_MAX*0.7  then -- check if above air and if not too bright
			minetest.set_node(pos, {name="default:ice"})
		end 
	end,
})


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