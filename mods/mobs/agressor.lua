--dofile(minetest.get_modpath("aggressormob").."/api.lua")
--
mobs:register_mob("mobs:aggressormob", {
	type = "monster",
	hp_min = 50,
	hp_max = 50,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "aggressormob.x",
	textures = {"aggressormob.png"},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 30,
	walk_velocity = 5.8,
	run_velocity = 9,
	damage = 4,

	drops = {
		{name = "default:steel_ingot",
		chance = 1,
		min = 1,
		max = 4,},
		{name = "farming:bread",
		chance = 2,
		min = 1,
		max = 1,},
	},
	light_resistant = true,
	armor = 100,
	drawtype = "front",
	water_damage = 10,
	lava_damage = 10,
	light_damage = 0,sounds = {
		attack = "mobs_bullet",
	},
	attack_type = "shoot",
	arrow = "mobs:bullet",
	shoot_interval = 0.13,
	sounds = {
		attack = "mmobs_bullet",
	},
	animation = {
		speed_normal = 17,
		speed_run = 35,
		stand_start = 0,
		stand_end = 40,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 198,
	}
})
mobs:register_spawn("mobs:aggressormob", {"default:dirt_with_grass","default:sand", "default:desert_stone", "default:stone", "default:mossycobble"}, 10, -1, 7000, 11, 30000)

mobs:register_arrow("mobs:bullet", {
	visual = "sprite",
	visual_size = {x = 0.275, y = 0.275},
	textures = {"aggressormob_bullet.png"},
	velocity = 23,
	hit_player = function(self, player)
		local s = self.object:getpos()
		local p = player:getpos()
		local vec = {x =s.x-p.x, y =s.y-p.y, z =s.z-p.z}
		player:punch(self.object, 1.0,  {
			full_punch_interval= 1.0,
			damage_groups = {fleshy = 2},
		}, vec)
		local pos = self.object:getpos()
		for dx = -1, 1 do
			for dy = -1, 1 do
				for dz = -1, 1 do
					local p = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
					local n = minetest.get_node(pos).name
				end
			end
		end
	end,
	hit_node = function(self, pos, node)
		for dx = -1, 1 do
			for dy = -2, 1 do
				for dz = -1, 1 do
					local p = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
					local n = minetest.get_node(pos).name
				end
			end
		end
	end
})
mobs:register_mob("mobs:applmons", {
	type = "monster",
	hp_max = 15,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.0, 0.4},
	visual = "mesh",
	mesh = "applmons.x",
	textures = {"applmons.png"},
	visual_size = {x=3.6, y=2.6},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 5,
	damage = 2,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 3,
		max = 50,},
	},
	armor = 100,
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 2,
	on_rightclick = nil,
	attack_type = "dogfight",
	animation = {
		speed_normal = 15,
		speed_run = 35,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 40,
		punch_end = 63,
	}
})
mobs:register_spawn("mobs:applmons", {"default:dirt_with_grass" , "default:stone", "default:desert_stone", "default:cobble", "default:mossycobble"}, 3, -1, 7000, 8, 30000)


--if minetest.setting_get("log_mods") then
--	minetest.log("action", "aggressormob loaded")
--end
