
-- Bee

mobs:register_mob("mobs:bee", {
	type = "monster",
	hp_min = 1,
	hp_max = 2,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.2, 0.2},
	visual = "mesh",
	mesh = "mobs_bee.x",
	textures = {"mobs_bee.png"},
	makes_footstep_sound = false,
	monsterdetect = false,
	walk_velocity = 1,
	run_velocity = 6,
	view_range = 12,
	armor = 100,
	damage = 4,
	attack_type = "dogfight",
	owner = "", -- rnd
	lifetimer = 200, -- rnd
	gravity = 0.2, -- rnd
	drops = {
		{name = "mobs:med_cooked",
		chance = 1,
		min = 1,
		max = 2,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 1,
	light_damage = 0,
	
	animation = {
		speed_normal = 15,
		stand_start = 0,
		stand_end = 30,
		walk_start = 35,
		walk_end = 65,
	},
	on_rightclick = function(self, clicker)
		if clicker:is_player() and clicker:get_inventory() then
			clicker:get_inventory():add_item("main", "mobs:bee")
			self.object:remove()
		end
	end,
jump = true,
step = 1,
passive = false,
})
mobs:register_spawn("mobs:bee", {"group:flower", "default:dirt_with_grass","default:dirt"}, 20, -1, 700, 10, 31000)

minetest.register_craftitem("mobs:bee", {
	description = "bee",
	inventory_image = "mobs_bee_inv.png",
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			local obj = minetest.env:add_entity(pointed_thing.above, "mobs:bee") -- rnd
			local entity = obj:get_luaentity();
			entity.owner = placer:get_player_name();			
			itemstack:take_item()
		end
		return itemstack
	end,
})

-- Honey

minetest.register_craftitem("mobs:honey", {
	description = "Honey",
	inventory_image = "mobs_honey_inv.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:honey", --rnd "mobs:med_cooked",
	recipe = "mobs:bee",
	cooktime = 5,
})

-- Beehive

minetest.register_node("mobs:beehive", {
	description = "Beehive",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles ={"mobs_beehive.png"},
	inventory_image = "mobs_beehive.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	groups = {fleshy=3,dig_immediate=3},
	on_use = minetest.item_eat(4),
	sounds = default.node_sound_defaults(),
	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name="mobs:beehive", param2=1})
			local meta = minetest.get_meta(pos);meta:set_string("owner",placer:get_player_name())
			local obj = minetest.env:add_entity(pos, "mobs:bee")-- rnd
			local entity = obj:get_luaentity();
			entity.owner = placer:get_player_name();			
			
			
		end
	end,
	
})

minetest.register_abm({
		nodenames = "mobs:beehive",
		neighbors = {"air"},
		interval = 20,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider) 
			if active_object_count_wider > 30 then -- no more than 30 bees
				return
			end
		local objs = minetest.env:get_objects_inside_radius(pos,8)
		local meta = minetest.get_meta(pos);local owner = meta:get_string("owner");
		local calm = false
		for _, o in pairs(objs) do
			if (o:is_player()) then
				if o:get_player_name()==owner then calm = true break end
			end
		end
			if not calm then -- spawn bee
				local obj = minetest.env:add_entity(pos, "mobs:bee")
				local entity = obj:get_luaentity();
				entity.owner = owner;
				
				-- EXTRA ACTIONS: find nearby flower, and duplicate another flower with small probability
				
			end
		end
		})



minetest.register_craft({
	output = "mobs:beehive",
	recipe = {
		{"mobs:bee","mobs:bee","mobs:bee"},
	}
})
