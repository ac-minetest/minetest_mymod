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
		if math.abs(pos.x-static_spawnpoint.x)<32 and math.abs(pos.z-static_spawnpoint.z)<32 and math.abs(pos.y-static_spawnpoint.y)<20 then 
				minetest.chat_send_player(name, "can only teleport to spawn outside spawn area/jail!")
				return
		else
			player:setpos(static_spawnpoint)
			minetest.chat_send_player(name, "Teleported to spawn")
		end -- no goto spawn inside spawn area
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

minetest.register_chatcommand("t", {
    description = "localised chat",
    privs = {},
    func = function(name,param)
		local sender = minetest.env:get_player_by_name(name); if sender==nil then return end
		local pos1 = sender:getpos();
		for _,player in pairs(minetest.get_connected_players()) do
			if player:get_player_name()~=name then
				local pos2 = player:getpos();
				local dist = math.sqrt((pos1.x-pos2.x)^2+(pos1.y-pos2.y)^2+(pos1.z-pos2.z)^2);
				if dist < 32 then minetest.chat_send_player(player:get_player_name(),name .." : ".. param) end
			end
		end
	end
	})

minetest.register_abm({ -- lava destroyes bones (every?) after 10 minutes
	nodenames = {"bones:bones"},
	neighbors = {"default:lava_flowing","default:lava_source"},
	interval = 600,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name="default:lava_source"})
	end,
})

-- here various player stats are saved (experience, skills, effects)
playerdata = {};
votingpoll = {}; 

minetest.register_on_joinplayer(function(player) -- init stuff on player join

	
	local name = player:get_player_name();
	if name == nil then return end -- ERROR!!!
		
	--jail check
	if playerdata[name]~= nil then
		if playerdata[name].jail~= nil then
			if playerdata[name].jail>1 then return end -- dont let player out of jail if in jail :)
		end
	end
	
	playerdata[name] = {}
	playerdata[name] = {xp=0,dig=0,speed=false,gravity=false, jail = 0}; -- jail >0 means player is in jail
	playerdata[name].warning = 0
	playerdata[name].manahud = init_mana_hud(player)
	end
)

minetest.register_on_newplayer(
function(player)
	local name = player:get_player_name();
	playerdata[name] = {}
	playerdata[name].manahud = init_mana_hud(player)
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
		
		if playerdata[param].jail== nil then return end --ERROR!
		
		local privs = minetest.get_player_privs(name);
		
		if name==param and playerdata[param].jail>1 and not privs.ban then
			minetest.chat_send_all("Prisoner " .. name .. " wishes to get out of jail. You can help him with /free")
			return
		end
		
		if playerdata[name].xp < 100 and not privs.kick then
			minetest.chat_send_player(name, "You dont have enough (100) experience or dont have kick privilege to do that."); return
		end
		
		if playerdata[param].jail<1 then 
			minetest.chat_send_player(name, param.. " is not in jail."); return
		end
		
		if not privs.kick then
			playerdata[name].xp = playerdata[name].xp-100;
		end
		
		playerdata[param].jail = playerdata[param].jail -1;
		minetest.chat_send_all(param .. " was given pardon by " .. name .. ". ".. playerdata[param].jail .. " jail points left. " )
		
		if playerdata[param].jail<=0 then 
			playerdata[param].jail = 0;
			minetest.chat_send_player(name, param.. " freed from jail.")
			local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
			prisoner:setpos(static_spawnpoint)
			return
		end
	
		
		
end,	
})

minetest.register_chatcommand("jail", {
    description = "/jail NAME adds +1 to jail sentence for NAME",
    privs = {privs = true},
    func = function(name, param)
        local player = minetest.env:get_player_by_name(name)
		local prisoner = minetest.env:get_player_by_name(param)
	
		if player == nil or prisoner == nil or playerdata[param].jail == nil then
            return
        end
		playerdata[param].jail = playerdata[param].jail + 1
		minetest.chat_send_all(name .. " gives extra jail sentence to " .. param .. ", now at " .. playerdata[param].jail)
end,	
})


minetest.register_chatcommand("y", {
    description = "vote yes in poll",
    privs = {},
    func = function(name)
		if votingpoll.state ==1 then 
			if votingpoll.votes[name] == nil and votingpoll.name~=name then 
				votingpoll.result = votingpoll.result -1
				votingpoll.votes[name] = true;
			end
		else return
		end
	end
	})
	
minetest.register_chatcommand("n", {
    description = "vote no in poll",
    privs = {},
    func = function(name)
		if votingpoll.state ==1 then 
			if votingpoll.votes[name] == nil and votingpoll.name~=name then 
				votingpoll.result = votingpoll.result +1
				votingpoll.votes[name] = true;
			end
		else return
		end
	end
	})

dofile(minetest.get_modpath("mymod").."/experience.lua")
dofile(minetest.get_modpath("mymod").."/landmine.lua")
dofile(minetest.get_modpath("mymod").."/extractor.lua")
dofile(minetest.get_modpath("mymod").."/freezing.lua")
dofile(minetest.get_modpath("mymod").."/acid.lua")
dofile(minetest.get_modpath("mymod").."/recipes.lua")
dofile(minetest.get_modpath("mymod").."/tweaks.lua")
dofile(minetest.get_modpath("mymod").."/life.lua")
dofile(minetest.get_modpath("mymod").."/maze.lua")
dofile(minetest.get_modpath("mymod").."/sokoban.lua")
dofile(minetest.get_modpath("mymod").."/admin.lua")
dofile(minetest.get_modpath("mymod").."/roadgen.lua")
dofile(minetest.get_modpath("mymod").."/mover.lua")

-- MAIN PROCESSING STEP:
-- players walk slower away from spawn, mana regenerates, application of various effects

local time = 0
MYMOD_UPDATE_TIME = 2


minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time < MYMOD_UPDATE_TIME then return end
	time = 0
	
	local spawnpoint = core.setting_get_pos("static_spawnpoint")
	local mult
	local pos,dist
	local player
	local t
	
	-- jail voting
	if votingpoll.state == 2 then -- new vote 
		minetest.chat_send_all("VOTE (" .. votingpoll.time .. "s): do we punish " .. votingpoll.name .. " for: " .. votingpoll.reason .. "? say /y or /n ");
		votingpoll.state = 1 -- voting countdown
		votingpoll.result = 0;votingpoll.votes = {};
		elseif votingpoll.state == 1 then
			votingpoll.time = votingpoll.time-MYMOD_UPDATE_TIME
		if votingpoll.time<0 then 
			votingpoll.time =0; votingpoll.state = 0; 
			if votingpoll.result<0 then
				minetest.chat_send_all("Vote ends. Player ".. votingpoll.name .." receives punishment with voting result " .. votingpoll.result );
				playerdata[votingpoll.name].jail= math.max(playerdata[votingpoll.name].jail+votingpoll.jail,1.25)
				else minetest.chat_send_all("Vote ends. Player ".. votingpoll.name .." is excused with voting result " .. votingpoll.result);
			end
		end -- voting ended
	end
	
		for _,player in ipairs(minetest.get_connected_players()) do 
			pos = player:getpos()
			local name = player:get_player_name();
			local privs = minetest.get_player_privs(name)
			
			
			-- SPEED ADJUSTMENT
			
			dist = math.sqrt((pos.x-spawnpoint.x)^2+(pos.z-spawnpoint.z)^2)
			mult = dist
			if mult>200 and pos.y> 0 and not privs.privs then -- only on "surface" and if not admin
				mult = (7./5)/(mult/500.+1.)  -- starts linearly falling from 200
				t  = 1-1/(playerdata[name].xp/10000+1); mult = 1*t+(1-t)*mult -- adjust factor with experience
			else
				mult = 1.
			end
			
			-- slow effect:
			
			if playerdata[name].speed == true then -- active speed effects

				if playerdata[name].slow~=nil then
					if playerdata[name].slow.time>0 then
						playerdata[name].slow.time = playerdata[name].slow.time - MYMOD_UPDATE_TIME -- error reading table entry
						player:set_physics_override({speed =  playerdata[name].slow.mag});
						else 
						minetest.chat_send_player(name,"[EFFECT] normal speed restored.")
						playerdata[name].slow.time = 0
						playerdata[name].speed = false;
					end
				end
				else player:set_physics_override({speed =  mult});-- if speed was not already affected by something else do enviroment change
			end
			
			-- poison effect

			if playerdata[name].poison~=nil then
				if playerdata[name].poison.time>0 then
					playerdata[name].poison.time = playerdata[name].poison.time - MYMOD_UPDATE_TIME
					player:set_hp(player:get_hp()-playerdata[name].poison.mag);
					if player:get_hp()<=0 then playerdata[name].poison.time = 0 end
					else 
					playerdata[name].poison.time = 0;
				end
			end
			

			--minetest.chat_send_player(player:get_player_name(), "speed factor "..mult) --debug only
				
			--GRAVITY ADJUSTMENT above y = 50
			
			if pos.y > 50 then mult = 2/((pos.y/50)^2+1.)
			else 
				mult = 1. 
			end
			
			if playerdata[name].gravity == false then -- active speed effects
				player:set_physics_override({gravity =  mult,sneak_glitch = false});
				else 
				if playerdata[name].float.time >0 then
					playerdata[name].float.time = playerdata[name].float.time - MYMOD_UPDATE_TIME
					if playerdata[name].float.time<=0 then playerdata[name].float.time = 0; playerdata[name].gravity = false end
				end
			end
			
			--JAIL CHECK
			
			if playerdata[name].jail > 0 then 
				
				
				if playerdata[name].jail > 1 and (dist>32 or (pos.y > spawnpoint.y-3 or pos.y < spawnpoint.y-10)) then -- what you doing out of jail? go back :P
					player:setpos( {x=spawnpoint.x, y=spawnpoint.y-5, z=spawnpoint.z} )
					minetest.chat_send_player(name,"Prisoner transported to jail, remaining jail sentence ".. math.ceil(MYMOD_UPDATE_TIME*(playerdata[name].jail - 1)/0.01) .. " seconds ");
				end
				
				if playerdata[name].jail <=1 then
					playerdata[name].jail = playerdata[name].jail - 0.1; -- minor transgression
					if playerdata[name].jail<0 then playerdata[name].jail = 0  end
				else
					playerdata[name].jail = playerdata[name].jail - 0.01; -- jail time slowly decreases
				end
			end
			
			-- SURVIVABILITY CHECK
			
			local totalxp = playerdata[name].xp+playerdata[name].magic;
			if pos.y>0 and dist>500+totalxp/10 and not privs.privs then
				if player:get_hp()<=0 then playerdata[name].warning = 0 return end -- when player is dead do nothing
				if minetest.get_node_light(pos) ~= nil then -- crashed once, safety
				if minetest.get_node_light(pos)>LIGHT_MAX*0.9 then
					playerdata[name].warning = playerdata[name].warning+1
					minetest.chat_send_player(name,"Desert heat is too much to bear. Find shadow, get more experience or return closer to spawn." .. playerdata[name].warning .. "/5")
					if playerdata[name].warning>=5 then 
						
						player:set_hp(player:get_hp()-0.25-dist/200) 
					end
				end
				end
				elseif playerdata[name].warning>0 then playerdata[name].warning = playerdata[name].warning -1
			end
			
			-- MANA REGENERATION
			if playerdata[name].mana ~= nil then
				if playerdata[name].mana < playerdata[name].max_mana then -- every 100 magic skill extra level, 0.1 mana regen
					playerdata[name].mana = playerdata[name].mana + (math.floor(playerdata[name].magic/200)+1)*0.1; -- at 4000 you get 2 regen per tick
					if playerdata[name].mana>playerdata[name].max_mana then playerdata[name].mana = playerdata[name].max_mana end
				end
			end
			
			-- HUD UPDATE
			t = playerdata[name].max_mana;
			if t~=nil then
				if t~=0 then t = 20*playerdata[name].mana/playerdata[name].max_mana else t = 0 end
				player:hud_change(playerdata[name].manahud, "number", t)
			end
			
			-- READ NODE NAME AT CURRENT POS
				local p = pos;
				local node1 = minetest.get_node(p).name;
				p.y=p.y+1;local node2 = minetest.get_node(p).name;
			
			-- CHECK WHEN PLAYER ENTERS/LEAVES WATER
				if playerdata[name].water ~= nil then 
						if playerdata[name].water.state==0 and node2=="default:water_source" then -- enter water
							--minetest.chat_send_all("entered water") 
							playerdata[name].water.depth = 0.5*(p.y+playerdata[name].water.lastheight);
							playerdata[name].water.state = 1;
						elseif playerdata[name].water.state==1 and node2=="default:water_source" then -- still in water
							local depth = playerdata[name].water.depth-p.y; depth = math.ceil(depth)
							--minetest.chat_send_all("current water depth: " .. depth)
							if depth > 10 then
								minetest.chat_send_player(name,"warning: water depth ".. depth)
								player:set_hp(player:get_hp()-depth/5);
							elseif depth>5 
								then playerdata[name].slow.mag = math.max(0.5-depth/30,0.1);
								playerdata[name].speed = true
								playerdata[name].slow.time = playerdata[name].slow.time + MYMOD_UPDATE_TIME
							end
						elseif playerdata[name].water.state==1 and node2=="air" and node1=="air" then -- leave water
							--minetest.chat_send_all("left water")
							-- additionaly check if water really cleared? is water nearby?
							playerdata[name].water.state = 0
							playerdata[name].water.lastheight = p.y
						else 
							playerdata[name].water.lastheight = p.y -- not quite cleared of water, but not completely inside
						end
					else -- init
					playerdata[name].water = {}
					if node2~="default:water_source" then playerdata[name].water.state = 0; else playerdata[name].water.state = 1; end -- not in water
					playerdata[name].water.depth = 0;playerdata[name].water.lastheight = p.y
				end
			
			-- CHEAT CHECK: simple noclip check
		

				if not privs.noclip then
				
				if (node1=="default:stone" or node1=="default:cobble") and (node2=="default:stone" or node2=="default:cobble") then
					minetest.chat_send_all(name.. " was caught walking inside walls at " .. pos.x .. " " .. pos.y .. " " .. pos.z)
					minetest.log("action", name.. " was caught walking inside walls at " .. pos.x .. " " .. pos.y .. " " .. pos.z)
					--playerdata[name].jail = playerdata[name].jail+1.5
					if votingpoll.state ~=1 then
						votingpoll.name = name; votingpoll.jail = 1.5; votingpoll.time = 10; votingpoll.state = 2;
						votingpoll.reason = name.. " was caught walking inside walls at " .. pos.x .. " " .. pos.y .. " " .. pos.z;
					end
				end
			end
			
			-- skins check : requires simple_skins mod inside depends.txt
			
			if skins.skins~=nil then
				local skin = tonumber(string.sub(skins.skins[name],11));
				--minetest.chat_send_all(name.." has skin number " .. skin)
				if skin == 0 then -- kirby the little dude gets stepped on
					for _,suspect in pairs(minetest.get_objects_inside_radius(pos, 2)) do
						if suspect:is_player() and suspect:get_player_name()~=player:get_player_name() then
							local crusher = suspect:get_player_name();
							minetest.chat_send_all(crusher .. " couldnt see " .. name .. " so he stepped on him by accident ")
							player:set_hp(player:get_hp()-5);
						end
					end
				end
			end
			
		
			-- local here = minetest.get_node(pos);
			-- if here.name=="default:stone" then 
				-- minetest.chat_send_player("rnd", " CHEAT pos : name: ".. player:get_player_name() .. " pos: "..pos.x .. " " .. pos.y .. " " .. pos.z)
			-- end
		end
end)

 -- MY HUD INTRODUCTORY EXAMPLE:

function init_mana_hud(player)
local name = player:get_player_name();
	return player:hud_add({
    hud_elem_type = "statbar",
    position = {x=0.305,y=0.88},
    size = "",
    text = "mana.png",
    number = 0,
    alignment = {x=0,y=1},
    offset = {x=0, y=0},
	size = { x=24, y=24 },
	}
	)
end

print ("MYMOD (experience, tweaks, sokoban, checkers...) has loaded")