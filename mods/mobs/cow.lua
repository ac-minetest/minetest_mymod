
-- Cow by Krupnovpavel

mobs:register_mob("mobs:cow", {
	type = "animal",
	hp_min = 5,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {"mobs_cow.png"},
	visual = "mesh",
	mesh = "mobs_cow.x",
	makes_footstep_sound = true,
	view_range = 7,
	monsterdetect = false,
	walk_velocity = 1,
	run_velocity = 2,
	damage = 10,
	armor = 200,
	drops = {
		{name = "mobs:meat_raw",
		chance = 1,
		min = 5,
		max = 10,},
		{name = "default:grass_1",
		chance = 2,
		min = 1,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	follow = "farming:wheat",
	sounds = {
		random = "mobs_cow",
	},
	-- right-click cow with empty bucket to get milk, then feed 8 wheat to replenish milk
	on_rightclick = function(self, clicker)
		tool = clicker:get_wielded_item()
		if tool:get_name() == "bucket:bucket_empty" then
			if self.milked then
				do return end
			end
			clicker:get_inventory():remove_item("main", "bucket:bucket_empty")
			clicker:get_inventory():add_item("main", "mobs:bucket_milk")
			self.milked = true
		end
		
		if tool:get_name() == "farming:wheat" then
			if self.milked then
				if not minetest.setting_getbool("creative_mode") then
					tool:take_item(1)
					clicker:set_wielded_item(tool)
				end
				self.food = (self.food or 0) + 1
				if self.food >= 8 then
					self.food = 0
					self.milked = false
					self.tamed = true
					minetest.sound_play("mobs_cow", {object = self.object,gain = 1.0,max_hear_distance = 32,loop = false,})
				end
			end
			return tool
		end
		
	end,

	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 30,
		walk_start = 35,
		walk_end = 65,
		run_start = 105,
		run_end = 135,
		punch_start = 70,
		punch_end = 100,
	},
	jump = true,
	step = 1,
	blood_texture = "mobs_blood.png",
	passive = true,
})
mobs:register_spawn("mobs:cow", {"default:dirt_with_grass", "ethereal:green_dirt_top", "ethereal:prairie_dirt"}, 20, 0, 1000, 10, 31000)

-- Bucket of Milk

minetest.register_craftitem("mobs:bucket_milk", {
	description = "Bucket of Milk",
	inventory_image = "mobs_bucket_milk.png",
	stack_max = 1,
	on_use = minetest.item_eat(8, 'bucket:bucket_empty'),
})

-- Cheese Wedge

minetest.register_craftitem("mobs:cheese", {
	description = "Cheese",
	inventory_image = "mobs_cheese.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cheese",
	recipe = "mobs:bucket_milk",
	cooktime = 5,
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Cheese Block

minetest.register_node("mobs:cheeseblock", {
	description = "Cheese Block",
	tiles = {"mobs_cheeseblock.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "mobs:cheeseblock",
	recipe = {
		{'mobs:cheese', 'mobs:cheese', 'mobs:cheese'},
		{'mobs:cheese', 'mobs:cheese', 'mobs:cheese'},
		{'mobs:cheese', 'mobs:cheese', 'mobs:cheese'},
	}
})

minetest.register_craft({
	output = "mobs:cheese 9",
	recipe = {
		{'mobs:cheeseblock'},
	}
})
