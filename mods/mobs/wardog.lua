mobs:register_mob("mobs:wardog", {
	type = "warpet",
	hp_max = 50,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {"mobs_wardog.png"},
	visual = "mesh",
	mesh = "mobs_wardog.x",
	makes_footstep_sound = true,
	view_range = 1000,
	monsterrange = 30,
	owner = "",
	monsterdetect = false,
	walk_velocity = 4,
	run_velocity = 4,
	damage = 20,
	armor = 50,
	attacks_monsters = true,
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
		if tool:get_name() == "default:sign_wall" then
			self.owner = clicker:get_player_name()
		else
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
	step = 1,
	blood_texture = "mobs_blood.png",
})
 
