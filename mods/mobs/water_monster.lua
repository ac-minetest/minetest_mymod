
--= Water monster experiment - rnd

-- Water Monster
mobs:register_mob("mobs:water_monster", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	mesh = "zmobs_mese_monster.x",
	textures = {"zmobs_mese_monster.png"},
	visual_size = {x=0.5, y=0.5},
	makes_footstep_sound = false,
	view_range = 16,
	walk_velocity = 1,
	run_velocity = 5,
	gravity = 0.1, -- rnd
	damage = 8,
	drops = {
		{name = "default:water_source",
		chance = 5,
		min = 1,
		max = 1,},
	},
	light_resistant = true,
	armor = 70,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	attack_type = "dogfight",
	animation = {
		speed_normal = 5,
		speed_run = 8,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 15, -- 40
		punch_end = 38, -- 63
	},
	jump = true,
	step = 0.5,
		blood_texture = "default_mese_crystal_fragment.png",
})
mobs:register_spawn_water("mobs:water_monster", {"default:water_source"}, 15, -1, 300, 10, 0) -- 2nd last number = max count, 3rd last = chance