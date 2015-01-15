-- give playes stuff
minetest.register_on_newplayer(
function(player)
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		player:get_inventory():add_item('main', 'default:torch 1')
		player:get_inventory():add_item('main', 'default:sword_wood')
		
		minetest.log("action", "Moving to spawn location : "..player:get_player_name())
		local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
		player:setpos(static_spawnpoint)
end)





minetest.register_chatcommand("spawn", {
    description = "Teleport you to spawn",
    privs = {},
    func = function(name)
        local player = minetest.env:get_player_by_name(name)
		
		if player == nil then
            -- just a check to prevent the server crashing
            return false
        end

		local pos=player:getpos()
		local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
		if math.abs(pos.x-static_spawnpoint.x)<20 and math.abs(pos.y-static_spawnpoint.y)<20 and math.abs(pos.z-static_spawnpoint.z) < 20 then 
			minetest.chat_send_player(name, "can only teleport to spawn outside spawn area!")
			return 
		false end -- no goto spawn inside spawn area

		player:setpos(static_spawnpoint)
        minetest.chat_send_player(name, "Teleported to spawn")
end,	
})


minetest.register_chatcommand("kill", {
    description = "Suicide, only works inside jail",
    privs = {},
    func = function(name)
        local player = minetest.env:get_player_by_name(name)
		
		if player == nil then
            -- just a check to prevent the server crashing
            return false
        end
		
		local pos=player:getpos()
		local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
		if math.abs(pos.x-static_spawnpoint.x)<20 and pos.y<static_spawnpoint.y and pos.y>static_spawnpoint.y-20 and math.abs(pos.z-static_spawnpoint.z) < 20 then 
			player:set_hp(0)
			else minetest.chat_send_player(name, "kill only works inside jail");return false
		end -- no goto spawn inside spawn area
		
		
end,	
})




-- ICE/WATER

-- rnd freezing still water to snow if not bright enough

minetest.register_abm({ -- water freeze
	nodenames = {"default:water_source"},
	neighbors = {""},
	interval = 20,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		local above = minetest.get_node(p) 
		if above.name == "air" and minetest.get_node_light(p)<=LIGHT_MAX*0.7  then -- check if above air and if not too bright
			minetest.set_node(pos, {name="default:ice"})
		end 
	end,
})


minetest.register_abm({
	nodenames = {"default:ice"},
	neighbors = {""},
	interval = 20,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		local above = minetest.get_node(p) 
		if above.name =="air" and minetest.get_node_light(p)>LIGHT_MAX*0.7 then -- snow melts -- minetest.get_node_light(p)>LIGHT_MAX-3
			minetest.set_node(pos, {name="default:water_source"})
		end
	end,
})


minetest.register_abm({ -- lava destroyes bones (every?) after 5 minutes
	nodenames = {"bones:bones"},
	neighbors = {"default:lava_flowing","default:lava_source"},
	interval = 300,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name="default:lava_source"})
	end,
})



-- rnd : CRAFTING DIRT FROM BONES

minetest.register_craft({
	output = "default:dirt",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})

minetest.register_craft({
	output = "default:sand",
	recipe = {
		{"bones:bones", "bones:bones"},
		{"bones:bones", "bones:bones"}
	}
})

minetest.register_craft({
	output = "bones:bones",
	recipe = {
		{"default:stone", "default:tree","default:stone"},
	}
})

minetest.register_craft({
	output = "default:desert_cobble",
	recipe = {
		{"default:stone", "default:sandstone","default:stone"},
	}
})

minetest.register_craft({
	output = "default:clay",
	recipe = {
		{"bones:bones 4"},
	}
})



minetest.register_craft({
	output = "default:sapling",
	recipe = {
		{"default:dirt", "bones:bones"}
	}
})


minetest.register_craft({
	output = "default:papyrus",
	recipe = {
		{"default:dirt","default:leaves"},
		}
})

minetest.register_craft({
	output = "default:cactus",
	recipe = {
		{"default:sand","default:leaves"},
		}
})


minetest.register_craft({
	output = "farming:seed_wheat",
	recipe = {
		{"default:dirt", "papyrus"}
	}
})

minetest.register_craft({
	output = "farming:seed_cotton",
	recipe = {
		{"default:dirt", "farming:seed_wheat"}
	}
})

minetest.register_craft({
	output = "default:gravel",
	recipe = {
		{"default:stone"},
	}
})

minetest.register_craft({
	output = "default:pine_sapling",
	recipe = {
		{"default:dirt","default:cactus"},
	}
})

minetest.register_craft({
	output = "default:junglesapling",
	recipe = {
		{"default:dirt","default:pine_sapling"},
	}
})

--flowers
minetest.register_craft({
	output = "flowers:dandelion_white",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","default:diamond","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"},
	}
})

minetest.register_craft({
	output = "flowers:dandelion_yellow",
	recipe = {
		{"default:dirt","flowers:dandelion_white","default:gold_ingot"},
	}
})

minetest.register_craft({
	output = "flowers:geranium",
	recipe = {
		{"default:dirt","flowers:dandelion_white","moreores:mithril_ingot"},
	}
})


minetest.register_craft({
	output = "flowers:flower_rose",
	recipe = {
		{"default:dirt","flowers:dandelion_white","default:brick"},
	}
})

minetest.register_craft({
	output = "flowers:tulip",
	recipe = {
		{"default:dirt","flowers:dandelion_yellow","flowers:flower_rose"},
	}
})


minetest.register_craft({
	output = "flowers:tulip",
	recipe = {
		{"default:dirt","flowers:geranium","flowers:	rose"},
	}
})


-- here various player stats are saved
local playerdata = {};

-- players walk slower away from spawn
local time = 0
MYMOD_UPDATE_TIME = 1

minetest.register_globalstep(function(dtime)
	time = time + dtime
	local spawnpoint = core.setting_get_pos("static_spawnpoint")
	local mult
	local pos
	local player
	local t
	if time > MYMOD_UPDATE_TIME then
		for _,player in ipairs(minetest.get_connected_players()) do 
			pos = player:getpos()
			-- SPEED ADJUSTMENT
			mult = math.sqrt((pos.x-spawnpoint.x)^2+(pos.z-spawnpoint.z)^2)
			if mult>200 and pos.y> 0 then -- only on "surface"
				mult = (7./5)/(mult/500.+1.)  -- starts linearly falling from 200
			else
				mult = 1.
			end
			-- check whether speed was already affected
			if playerdata[player:get_player_name()]==nil or playerdata[player:get_player_name()] == false then 
				player:set_physics_override({speed =  mult});
			end
			--minetest.chat_send_player(player:get_player_name(), "speed factor "..mult) --debug only
				
			--GRAVITY ADJUSTMENT above y = 50
			
			if pos.y > 50 then mult = 2/((pos.y/50)^2+1.)
			else 
				mult = 1. 
			end
			player:set_physics_override({gravity =  mult});
			
		
		time = 0
		
		
		end
		
	end
end)



-- cripple land mine, activated by mese

LANDMINE_RANGE = 4

minetest.register_abm(
	{nodenames = {"mymod:landmine_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos)

	local objects = minetest.get_objects_inside_radius(pos, LANDMINE_RANGE) -- radius
	for _,obj in ipairs(objects) do
		if (obj:is_player()) then
			local obj_pos = obj:getpos()
			local dist = vector.distance(obj_pos, pos)
			local damage = 1
			if dist > 0 and obj:get_hp()>1 then -- no damage if hp<=1
				if playerdata[obj:get_player_name()] == nil then
					playerdata[obj:get_player_name()] = {speed=false}
				end
				if playerdata[obj:get_player_name()].speed==false then -- player not yet affected
					minetest.chat_send_player(obj:get_player_name(), "<EFFECT> slowed by mine")
				end
				obj:set_physics_override({speed =  0.1});
				playerdata[obj:get_player_name()] = {speed = true}; -- remember that speed was changed
				obj:punch(obj, 1.0, {
						 full_punch_interval = 1.0,
						 damage_groups = {fleshy=damage},
					})
				
			end
		end
	end 
	end,
}) 



minetest.register_node("mymod:landmine_on", {
	description = "landmine on",
	inventory_image = "side_on.png",
	wield_image = "side_on.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"side_on.png","side_on.png","side_on.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:landmine_off"})
		end
	}}
	}
)



minetest.register_node("mymod:landmine_off", {
	description = "landmine off",
	inventory_image = "side_off.png",
	wield_image = "side_off.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"side_off.png","side_off.png","side_off.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:landmine_on"})
			local objects = minetest.get_objects_inside_radius(pos, LANDMINE_RANGE) -- radius
			for _,obj in ipairs(objects) do
				if (obj:is_player()) then
					local obj_pos = obj:getpos()
					local dist = vector.distance(obj_pos, pos)
					if dist > 0 then -- restore movement speed, whatever....
						obj:set_physics_override({speed =  0.1});
					end
				end
			end		
		end
	}}
	}
)

 
 minetest.register_on_dieplayer(function(player) -- restore ill effects with death
	player:set_physics_override({speed =  1.0})
	playerdata[player:get_player_name()] = {speed = false}; 
 end)
 
 
 minetest.register_craft({
	output = "mymod:landmine_off",
	recipe = {
		{"","default:mese_crystal",""},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})



-- EXTRACTOR: extract stuff from bones with small probability

function bone_extractor(pos)
	
	local above  = {x=pos.x,y=pos.y+1,z=pos.z};
	minetest.set_node(above, {name="air"})
	local  i = math.random(1000);
	local out;
	
	if i>=500 and i<1000 then out = "default:tree" end
	if i>=200 and i<500 then out = "default:stone_with_iron" end
	if i>=100 and i< 200 then out = "default:stone_with_iron" end
	if i<50 then out = "default:stone_with_mese" end
	local below  = {x=pos.x,y=pos.y-1,z=pos.z};
	minetest.set_node(below, {name=out})
		
end

-- here i see a for looping over a list and defining spawners for specific mob types
-- animal spawners named "barn", monster spawners named "cursed stone" like on just test
minetest.register_node("mymod:bone_extractor", {
	description = "Bone extractor",
	tiles = {"extractor.png"},
	groups = {oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_abm({
	nodenames = {"mymod:bone_extractor"},
	interval = 10.0,
	chance = 1,
	action = function(pos)		
		local pos_above = {x=pos.x,y=pos.y+1,z=pos.z}
		local above = minetest.get_node(pos_above)
		if above.name == "bones:bones" then 
			bone_extractor(pos)
		end
	end,
})


minetest.register_craft({
	output = "mymod:bone_extractor",
	recipe = {
		{"bones:bones", "bones:bones", "bones:bones"},
		{"bones:bones", "default:mese_block","bones:bones"},
		{"bones:bones", "bones:bones", "bones:bones"}
	}
})
