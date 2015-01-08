
--= Mese Monster by Zeg9

-- 9 mese crystal fragments = 1 mese crystal
minetest.register_craft({
	output = "default:mese_crystal",
	recipe = {
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
	}
})

-- Mese Monster
mobs:register_mob("mobs:mese_monster", {
	type = "monster",
	hp_min = 100,
	hp_max = 100,
	collisionbox = {-0.5, -1.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	mesh = "zmobs_mese_monster.x",
	textures = {"zmobs_mese_monster.png"},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 10,
	walk_velocity = 0.5,
	run_velocity = 6,
	damage = 10,
	drops = {
		{name = "default:mese_crystal",
		chance = 1,
		min = 1,
		max = 6,},
		{name = "default:mese_crystal_fragment",
		chance = 1,
		min = 1,
		max = 18,},
	},
	light_resistant = true,
	armor = 70,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	attack_type = "shoot",
	arrow = "mobs:mese_arrow",
	shoot_interval = .5,
	animation = {
		speed_normal = 15,
		speed_run = 15,
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
mobs:register_spawn("mobs:mese_monster", {"default:stone"}, 6, -1, 2000, 1, -100)

-- Mese Monster Crystal Shards (weapon)

mobs:register_arrow("mobs:mese_arrow", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"default_mese_crystal_fragment.png"},
	velocity = 5,
	
	hit_player = function(self, player)
		local s = self.object:getpos()
		local p = player:getpos()

		player:punch(self.object, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=1},
		}, {x=s.x-p.x, y=s.y-p.y, z=s.z-p.z})
	end,
	
	hit_node = function(self, pos, node)
	end
})
