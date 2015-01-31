-- code borrowed from carbone mod by Calinou

minetest.register_node("mymod:acid_flowing_active", {
	description = "Flowing Acid",
	inventory_image = minetest.inventorycube("mymod_acid.png"),
	drawtype = "flowingliquid",
	tiles = {"mymod_acid.png"},
	special_tiles = {
		{
			image = "mymod_acid_flowing_animated.png",
			backface_culling=false,
			animation={type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.6}
		},
		{
			image = "mymod_acid_flowing_animated.png",
			backface_culling=true,
			animation={type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.6}
		},
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	param1 = 3,
	light_source = 8,
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false, -- now you cant build over it, only the source..
	drop = "",
	drowning = 2,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mymod:acid_flowing_active",
	liquid_alternative_source = "mymod:acid_source_active",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 2,
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
})


minetest.register_node("mymod:acid_source_active", {
	description = "Acid Source",
	inventory_image = minetest.inventorycube("mymod_acid.png"),
	drawtype = "liquid",
	tiles = {
		{name = "mymod_acid_source_animated.png", animation={type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5}}
	},
	special_tiles = {
		-- New-style acid source material (mostly unused)
		{
			name = "mymod_acid_source_animated.png",
			animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.5},
			backface_culling = false,
		}
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	param1 = 3,
	light_source = 8,
	walkable = false,
	pointable = false,
	diggable = true,
	buildable_to = true,
	drop = "",
	drowning = 2,
	liquidtype = "source",
	liquid_alternative_flowing = "mymod:acid_flowing_active",
	liquid_alternative_source = "mymod:acid_source_active",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 2, 
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1},
})

--  duplicate active source/flowing but make it passive

-- minetest.register_node("mymod:acid_source_passive", minetest.registered_nodes["mymod:acid_source_active"])
-- minetest.register_node("mymod:acid_flowing_passive", minetest.registered_nodes["mymod:acid_flowing_active"])


-- minetest.register_abm({ -- water polution
	-- nodenames = {"mymod:acid_source_active"},
	-- neighbors = {""},
	-- interval = 20,
	-- chance = 1,
	-- action = function(pos, node, active_object_count, active_object_count_wider)
		
		-- local meta = minetest.get_meta(pos);--if meta == nil then return end
		-- local life_count = node.param1;
		-- if life_count <= 0  then  minetest.set_node(pos, {name="mymod:acid_source_passive"})  return end -- spreads 3 around
		-- local meta_new,p,neighbor
		
		-- minetest.chat_send_all("debug count "..life_count)
		
		-- -- check neighbors
		-- local dir = {
		-- {x=-1,y=0,z=0},
		-- {x=1,y=0,z=0},
		-- {x=0,y=-1,z=0},
		-- {x=0,y=1,z=0},
		-- {x=0,y=0,z=-1},
		-- {x=0,y=0,z=1}		
		-- }; 
		
		-- for i=1,6 do
			-- p ={x=pos.x+dir[i].x,y=pos.y+dir[i].y,z=pos.z+dir[i].z};
			-- neighbor = minetest.get_node(p);
			
			-- if neighbor.name == "default:water_source" then
				-- minetest.set_node(p, {name="mymod:acid_source_active", param1 = life_count-1 })
			-- end
		-- end

	-- end,
-- }) 


-- DIGGING MAKES ACID WITH SMALL PROBABILITY

-- when stones digged under -10 they turn to acid source with small probability
local function overwrite(name)
	local table = minetest.registered_nodes[name]
	local table2 = {}
	for i,v in pairs(table) do
		table2[i] = v
	end
	
	table2.on_dig = function(pos, node, digger)
		
		 minetest.node_dig(pos, node, digger) -- this code handles dig itself
				
		local name = digger:get_player_name(); if name == nil then return end
		if pos.y>0 then return end -- only underground
		--math.randomseed(pos.y)
		local i = math.random(100) -- probability if spawns acid
		if i == 1 then
			minetest.set_node(pos, {name="mymod:acid_source_active"})
		end
	end
	
	
	minetest.register_node(":"..name, table2)
end 
overwrite("default:stone")
