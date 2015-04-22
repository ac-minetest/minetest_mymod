
-- Stone Monster

mobs:register_mob("mobs:stone_monster", {
	type = "monster",
	hp_min = 30,
	hp_max = 40,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	visual = "mesh",
	mesh = "mobs_stone_monster.x",
	textures = {"mobs_stone_monster.png"},
	visual_size = {x=3, y=2.6},
	makes_footstep_sound = true,
	view_range = 10,
	walk_velocity = 0.5,
	run_velocity = 4,
	damage = 5,
	drops = {
		{name = "default:torch",
		chance = 2,
		min = 3,
		max = 5,},
		{name = "default:cobble", -- need this for stone pick
		chance = 2,
		min = 1,
		max = 1,},
		{name = "shooter:pistol",
		chance=50,
		min=1,
		max=2,},
		{name = "default:iron_lump",
		chance=30,
		min=1,
		max=2,},
		{name = "default:coal_lump",
		chance=10,
		min=1,
		max=3,},
		{name = "bones:bones",
		chance=2,
		min=1,
		max=1,},
		{name = "default:apple",
		chance=2,
		min=1,
		max=1,},
	},
	light_resistant = true,
	armor = 100,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 5,
	attack_type = "dogfight",
	animation = {
		speed_normal = 15,
		speed_run = 25,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 40,
		punch_end = 63,
	},
	jump = true,
	step = 0.5,
	blood_texture = "mobs_blood.png",
})
mobs:register_spawn("mobs:stone_monster", {"default:stone"}, 2, -1, 10000, 30, 31000)
