
-- Rat

mobs:register_mob("mobs:rat", {
	type = "monster",
	hp_min = 1,
	hp_max = 1, -- 1
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.2, 0.2},
	visual = "mesh",
	mesh = "mobs_rat.x",
	textures = {"mobs_rat.png"},
	makes_footstep_sound = false,
	view_range = 20,
	walk_velocity = 2,
	run_velocity = 3,
	armor = 100,
	damage = 2,
	attack_type = "dogfight",
	drops = {
	{name = "default:wood", -- rnd
		chance = 2,
		min = 1,
		max = 1,},
	{name = "farming:seed_wheat",
		chance = 100,
		min = 1,
		max = 3,},
	{name = "farming:seed_cotton",
		chance = 100,
		min = 1,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 1,
	light_damage = 0,
jump = true,
step = 1,
--passive = true,
	
	on_rightclick = function(self, clicker)
		if clicker:is_player() and clicker:get_inventory() then
			clicker:get_inventory():add_item("main", "mobs:rat")
			self.object:remove()
		end
	end,
})
mobs:register_spawn("mobs:rat", {"default:stone"}, 20, -1, 5000, 10, 31000)

-- Can Right-click Rat to Pick Up

minetest.register_craftitem("mobs:rat", {
	description = "Rat",
	inventory_image = "mobs_rat_inventory.png",
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.env:add_entity(pointed_thing.above, "mobs:rat")
			itemstack:take_item()
		end
		return itemstack
	end,
})
	
-- Cooked Rat, yummy!

minetest.register_craftitem("mobs:rat_cooked", {
	description = "Cooked Rat",
	inventory_image = "mobs_cooked_rat.png",
	
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:rat_cooked",
	recipe = "mobs:rat",
	cooktime = 5,
})
