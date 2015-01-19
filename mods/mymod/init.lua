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
		if math.abs(pos.x-static_spawnpoint.x)<20 and pos.y<static_spawnpoint.y-3 and pos.y>static_spawnpoint.y-20 and math.abs(pos.z-static_spawnpoint.z) < 20 then 
			player:set_hp(0)
			else minetest.chat_send_player(name, "kill only works inside jail");return false
		end -- no goto spawn inside spawn area
		
		
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
playerdata = {};
minetest.register_on_joinplayer(function(player) -- init stuff on player join
	local name = player:get_player_name();
	if name == nil then return end -- ERROR!!!
	
	--jail check
	if playerdata[name]~= nil then
		if playerdata[name].jail~= nil then
			if playerdata[name].jail>0 then return end -- dont let player out of jail if in jail :)
		end
	end
	
	playerdata[name] = {}
	playerdata[name] = {xp=0,dig=0,speed=false, jail = 0}; -- jail >0 means player is in jail
	
end)


minetest.register_chatcommand("free", {
    description = "/free NAME to attempt to free NAME from jail, it costs 100 experience",
    privs = {},
    func = function(name, param)
        local player = minetest.env:get_player_by_name(name)
		local prisoner = minetest.env:get_player_by_name(param)
		
		if player == nil or prisoner == nil then
            return
        end
		
		if name==param and playerdata[param].jail>0 then
			minetest.chat_send_all("Prisoner " .. name .. " wishes to get out of jail. You can help him with /free")
			return
		end
		
		if playerdata[name].xp < 100 then
			minetest.chat_send_player(name, "You dont have enough experience to do that, need more than 100."); return
		end
		
		if playerdata[param].jail==0 then 
			minetest.chat_send_player(name, param.. " is not in jail."); return
		end
				
		playerdata[name].xp = playerdata[name].xp-100;
		playerdata[param].jail = playerdata[param].jail -1;
		minetest.chat_send_all(param .. " was given pardon by " .. name .. ". ".. playerdata[param].jail " jail points left. " )
		
		if playerdata[param].jail<=0 then 
			minetest.chat_send_player(name, param.. " freed from jail.")
			local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
			playerdata[param].jail = 0
			prisoner:setpos(static_spawnpoint)
			return
		end
	
		
		
end,	
})

dofile(minetest.get_modpath("mymod").."/experience.lua")
dofile(minetest.get_modpath("mymod").."/landmine.lua")
dofile(minetest.get_modpath("mymod").."/extractor.lua")
dofile(minetest.get_modpath("mymod").."/freezing.lua")

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
			if playerdata[player:get_player_name()].speed == false then 
				player:set_physics_override({speed =  mult});
			end
			--minetest.chat_send_player(player:get_player_name(), "speed factor "..mult) --debug only
				
			--GRAVITY ADJUSTMENT above y = 50
			
			if pos.y > 50 then mult = 2/((pos.y/50)^2+1.)
			else 
				mult = 1. 
			end
			player:set_physics_override({gravity =  mult});
			
		
			-- CHEAT CHECK: gets node at player position... works like crap :P
		
			-- local here = minetest.get_node(pos);
			-- if here.name=="default:stone" then 
				-- minetest.chat_send_player("rnd", " CHEAT pos : name: ".. player:get_player_name() .. " pos: "..pos.x .. " " .. pos.y .. " " .. pos.z)
			-- end
	
		end
		time = 0		
	end
end)