mobs:register_mob("mobs:wolf", {
	type = "animal",
	hp_max = 25,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {"mobs_wolf.png"},
	visual = "mesh",
	mesh = "mobs_wolf.x",
	makes_footstep_sound = true,
	view_range = 7,
	walk_velocity = 2,
	run_velocity = 3,
	damage = 10,
	armor = 50,
	attack_type = "dogfight",
	drops = {
		{name = "mobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function(self, clicker)
		tool = clicker:get_wielded_item()
		if tool:get_name() == "mobs:meat_raw" then
			clicker:get_inventory():remove_item("main", "mobs:meat_raw")
			minetest.add_entity(self.object:getpos(), "mobs:wardog")
			self.object:remove()
		end
	end,
	animation = {
		speed_normal = 20,
		speed_run = 30,
		stand_start = 10,
		stand_end = 20,
		walk_start = 75,
		walk_end = 100,
		run_start = 100,
		run_end = 130,
		punch_start = 135,
		punch_end = 155,
	},
	jump = true,
	step = 0.5,
	blood_texture = "mobs_blood.png",
})
mobs:register_spawn("mobs:wolf", {"default:dirt_with_grass","default:dirt","default:snow", "default:snowblock"}, 20, -1, 700, 1, 31000)
