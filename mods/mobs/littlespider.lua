
-- Glowtest Spider

mobs:register_mob("mobs:littlespider", {
	type = "warpet",
	attacks_monsters = true,
	hp_min = 20,
	hp_max = 40,
	owner = "",
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.4, 0.4},
	textures = {"mobs_warspider.png"},
	visual_size = {x=3,y=3},
	visual = "mesh",
	mesh = "mobs_warspider.x",
	makes_footstep_sound = true,
	view_range = 1000,
	monsterrange = 30,
	monsterdetect = false,
	walk_velocity = 4,
	run_velocity = 4,
    armor = 200,
	damage = 3,
	drops = {
		{name = "farming:string",
		chance = 1,
		min = 1,
		max = 5,},
		{name = "ethereal:crystal_spike",
		chance = 15,
		min = 1,
		max = 2,},
	},
    light_resistant = false,
	drawtype = "front",
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "dogfight",
	
	
	on_rightclick = function(self, clicker)
		tool = clicker:get_wielded_item()
		if tool:get_name() == "default:sign_wall" then
			self.owner = clicker:get_player_name()
		else
			minetest.add_entity(self.object:getpos(), "mobs:littlespider")
			self.object:remove()
		end
	end,
	
	animation = {
		speed_normal = 20,
		speed_run = 30,
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		punch_start = 50,
		punch_end = 90,
	},
	jump = true,
	sounds = {},
	step = 1,
})

-- Cobweb

minetest.register_node("mobs:cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	visual_scale = 1.1,
	tiles = {"mobs_cobweb.png"},
	inventory_image = "mobs_cobweb.png",
	paramtype = "light",
	sunlight_propagates = true,
	liquid_viscosity = 11,
	liquidtype = "source",
	liquid_alternative_flowing = "mobs:cobweb",
	liquid_alternative_source = "mobs:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	groups = {snappy=1,liquid=3},
	drop = "farming:cotton",
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craft({
	output = "mobs:cobweb",
	recipe = {
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
	}
})
 
 
