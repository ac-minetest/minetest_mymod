
-- Sand Monster

mobs:register_mob("mobs:sand_monster", {
	type = "monster",
	hp_min = 10,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	visual = "mesh",
	mesh = "mobs_sand_monster.x",
	textures = {"mobs_sand_monster.png"},
	visual_size = {x=8,y=8},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1.5,
	run_velocity = 4,
	damage = 5,
	drops = {
		{name = "default:desert_sand",
		chance = 1,
		min = 3,
		max = 5,},
		-- {name = "3d_armor:helmet_bronze",
		-- chance = 30,
		-- min = 1,
		-- max = 1,},
		-- {name = "3d_armor:helmet_steel",
		-- chance = 30,
		-- min = 1,
		-- max = 1,},
		-- {name = "3d_armor:leggings_steel",
		-- chance = 30,
		-- min = 1,
		-- max = 1,},
		-- {name = "3d_armor:chestplate_wood",
		-- chance = 10,
		-- min = 1,
		-- max = 1,},
		-- {name = "3d_armor:boots_wood",
		-- chance = 10,
		-- min = 1,
		-- max = 1,},
		-- {name = "shields:shield_steel",
		-- chance = 30,
		-- min = 1,
		-- max = 1,},
		-- {name = "shields:shield_bronze",
		-- chance = 30,
		-- min = 1,
		-- max = 1,},
	},
	light_resistant = true,
	armor = 150,
	drawtype = "front",
	water_damage = 3,
	lava_damage = 1,
	light_damage = 0,
	--attack_type = "dogfight",
	attack_type = "shoot",
	arrow = "mobs:sand_arrow",
	shoot_interval = 2,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
	jump = true,
	step = 0.5,
	blood_texture = "mobs_blood.png",
})
mobs:register_spawn("mobs:sand_monster", {"default:stone","default:desert_sand", "default:sand"}, 15, -1, 1400, 4, 31000)

mobs:register_arrow("mobs:sand_arrow", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"default_mese_crystal_fragment.png"},
	velocity = 15,
	
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
