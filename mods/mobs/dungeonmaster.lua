
-- Dungeon Master (This one spits out fireballs at you)

mobs:register_mob("mobs:dungeon_master", {
	type = "monster",
	hp_min = 100,
	hp_max = 100,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 2.6, 0.7},
	visual = "mesh",
	mesh = "mobs_dungeon_master.x",
	textures = {"mobs_dungeon_master.png"},
	visual_size = {x=8, y=8},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 15,
	drops = {
		{name = "default:sapling",
		chance = 5,
		min = 1,
		max = 2,},
		{name = "default:mese_crystal_fragment",
		chance = 1,
		min = 1,
		max = 10,},
		{name = "default:diamond",
		chance = 4,
		min = 1,
		max = 8,},
		{name = "default:mese_crystal",
		chance = 5,
		min = 1,
		max = 8,},
		{name = "default:diamond_block",
		chance = 5,
		min = 1,
		max = 1,},
	},
	armor = 20,
	drawtype = "front",
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "shoot",
	arrow = "mobs:fireball",
	shoot_interval = 2.0,
	sounds = {
		attack = "mobs_fireball",
	},
	animation = {
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
	blood_texture = "mobs_blood.png",
})
mobs:register_spawn("mobs:dungeon_master", {"default:stone"}, 20, -1, 2000, 2, -100) -- rnd: last number max height for spawn..

-- Fireball (weapon)

mobs:register_arrow("mobs:fireball", {
	visual = "sprite",
	visual_size = {x=1, y=1},
	textures = {"mobs_fireball.png"},
	velocity = 10,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		local s = self.object:getpos()
		local p = player:getpos()
		local vec = {x=s.x-p.x, y=s.y-p.y, z=s.z-p.z}
		player:punch(self.object, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=10},
		}, vec)
	end,

	-- node hit, bursts into flame (cannot blast through obsidian)
	hit_node = function(self, pos, node)

		for dx=-1,1 do
			for dy=-1,1 do
				for dz=-1,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if n ~= "default:obsidian" and n ~= "ethereal:obsidian_brick" then	
					if minetest.registered_nodes[n].groups.flammable then --or math.random(1, 100) <= 30 then
						minetest.env:set_node(p, {name="fire:basic_flame"}) -- fire damage!
					else
						--minetest.env:set_node(p, {name="air"}) -- disable destruction
					end
					end
				end
			end
		end
		
		--rnd : attack does splash damage
		
		local objects = minetest.get_objects_inside_radius(pos, 8) -- radius
		for _,obj in ipairs(objects) do
			if (obj:is_player()) then
				local obj_pos = obj:getpos()
				local dist = vector.distance(obj_pos, pos)
				local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
				local damage = 8 *(1+vector.distance(obj_pos, static_spawnpoint)/500)*(1-dist/16);
				if dist > 0 then -- and obj:get_hp()>1 then -- no damage if hp<=1
					--obj:set_physics_override({speed =  0.5}); --slows player
					obj:punch(obj, 1.0, {
							 full_punch_interval = 1.0,
							 damage_groups = {fleshy=damage},
						})
					
				end
			end
		end 
		
		
	end
})
