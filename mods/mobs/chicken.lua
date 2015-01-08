
--= Chicken (thanks to JK Murray for his chicken model)

mobs:register_mob("mobs:chicken", {
	type = "animal",
	hp_min = 5,
	hp_max = 10,
	animaltype = "clucky",
	collisionbox = {-0.3, -0.75, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	mesh = "chicken.x",
	-- textures look repetative but they fix the wrapping bug
	textures = {"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png",
				"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png"},
	makes_footstep_sound = true,
	monsterdetect = false,
	walk_velocity = 1,
	armor = 200,
	drops = {
		{name = "mobs:chicken_raw", chance = 1, min = 2, max = 2,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	jump = false,
	animation = {
		speed_normal = 15,
		stand_start = 0,
		stand_end = 1, -- 20
		walk_start = 20,
		walk_end = 40,
	},
	follow = "farming:wheat",
	view_range = 5,	
		on_rightclick = function(self, clicker)
		if clicker:is_player() and clicker:get_inventory() then
			clicker:get_inventory():add_item("main", "mobs:chicken")
			self.object:remove()
		end
	end,
	jump = true,
	step = 1,
	blood_texture = "mobs_blood.png",
	passive = true,
})

mobs:register_spawn("mobs:chicken", {"default:dirt_with_grass", "ethereal:bamboo_dirt"}, 20, 8, 9000, 1, 31000)

-- Chicken (right-click chicken to place in inventory)

minetest.register_craftitem("mobs:chicken", {
	description = "Chicken",
	inventory_image = "mobs_chicken_inv.png",
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.env:add_entity(pointed_thing.above, "mobs:chicken")
			itemstack:take_item()
		end
		return itemstack
	end,
})

-- Egg (can be fried in furnace)

minetest.register_node("mobs:egg", 
	{
		description = "Chicken Egg",
		tiles = {"mobs_chicken_egg.png"},
		inventory_image  = "mobs_chicken_egg.png",
		visual_scale = 0.7,
		drawtype = "plantlike",
		wield_image = "mobs_chicken_egg.png",
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
		},
		groups = {snappy=2, dig_immediate=3},
		after_place_node = function(pos, placer, itemstack)
			if placer:is_player() then
				minetest.set_node(pos, {name="mobs:egg", param2=1})
			end
		end
})

minetest.register_craftitem("mobs:chicken_egg_fried", {
description = "Fried Egg",
	inventory_image = "mobs_chicken_egg_fried.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:egg",
	output = "mobs:chicken_egg_fried",
})

-- Chicken (raw and cooked)

minetest.register_craftitem("mobs:chicken_raw", {
description = "Raw Chicken",
	inventory_image = "mobs_chicken_raw.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craftitem("mobs:chicken_cooked", {
description = "Cooked Chicken",
	inventory_image = "mobs_chicken_cooked.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:chicken_raw",
	output = "mobs:chicken_cooked",
})
