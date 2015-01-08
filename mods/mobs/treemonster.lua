
-- Tree Monster (or Tree Gollum as I like to call it)

mobs:register_mob("mobs:tree_monster", {
	type = "monster",
	hp_min = 15,
	hp_max = 33,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	visual = "mesh",
	mesh = "mobs_tree_monster.x",
	textures = {"mobs_tree_monster.png"},
	visual_size = {x=4.5,y=4.5},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 2,
	drops = {
		{name = "ethereal:tree_sapling",
		chance = 3,
		min = 1,
		max = 2,},
		{name = "ethereal:jungle_tree_sapling",
		chance = 3,
		min = 1,
		max = 2,},
		{name = "default:apple",
			chance = 2,
			min = 1,
			max=3,
		},
	},
	light_resistant = true,
	armor = 100,
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 2,
	disable_fall_damage = true,
	attack_type = "dogfight",
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 24,
		walk_start = 25,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		punch_start = 48,
		punch_end = 62,
	},
	step = 0.5,
	jump = true,
	blood_texture = "default_wood.png",
})
mobs:register_spawn("mobs:tree_monster", {"default:leaves", "default:jungleleaves"}, 3, -1, 7000, 1, 31000)

-- Ethereal sapling compatibility

if not minetest.get_modpath("ethereal") then
	minetest.register_alias("ethereal:tree_sapling", "default:sapling")
	minetest.register_alias("ethereal:jungle_tree_sapling", "default:junglesapling")
end
