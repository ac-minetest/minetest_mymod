
-- Sand Monster

mobs:register_mob("mobs:yeti", {
	type = "monster",
	hp_min = 50,
	hp_max = 50,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	visual = "mesh",
	mesh = "mobs_yeti.x",
	textures = {"mobs_yeti.png"},
	visual_size = {x=8,y=8},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1.5,
	run_velocity = 4,
	damage = 5,
	drops = {
		{name = "default:ice",
		chance = 1,
		min = 3,
		max = 5,},
	},
	light_resistant = true,
	armor = 60,
	drawtype = "front",
	water_damage = 3,
	lava_damage = 1,
	light_damage = 0,
	attack_type = "shoot",
	arrow = "mobs:ice_arrow",
	shoot_interval = .5,
	animation = {
		run_start = 40,
		run_end = 63,
		stand_start = 0,
		stand_end = 19,
		walk_start = 20,
		walk_end = 35,
		punch_start = 36,
		punch_end = 48,
		speed_normal = 15,
		speed_run = 15,
	},
	jump = true,
	step = 0.5,
		blood_texture = "mobs_ice_arrow.png",
})
mobs:register_spawn("mobs:yeti", {"default:snow", "default:snowblock", "default:ice"}, 20, -1, 10000, 10, 31000) 
mobs:register_arrow("mobs:ice_arrow", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"mobs_ice_arrow.png"},
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