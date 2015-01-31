-- code borrowed from carbone mod by Calinou

minetest.register_node("mymod:acid_flowing", {
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
	light_source = 8,
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false, -- now you cant build over it, only the source..
	drop = "",
	drowning = 2,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mymod:acid_flowing",
	liquid_alternative_source = "mymod:acid_source",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 2,
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
})

minetest.register_node("mymod:acid_source", {
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
	light_source = 8,
	walkable = false,
	pointable = false,
	diggable = true,
	buildable_to = true,
	drop = "",
	drowning = 2,
	liquidtype = "source",
	liquid_alternative_flowing = "mymod:acid_flowing",
	liquid_alternative_source = "mymod:acid_source",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 2, 
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1},
})

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
			minetest.set_node(pos, {name="mymod:acid_source"})
		end
	end
	
	
	minetest.register_node(":"..name, table2)
end 

overwrite("default:stone")
