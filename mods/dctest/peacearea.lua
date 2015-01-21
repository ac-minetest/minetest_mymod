-- PvP-FREE AREA
-- purpose: revoke interact privilege from players within effect area
-- except admins

-- pros: lets players read signs and chat peacefully as long
--       as they are confined to the spawn cage
--       (is this a + to you?)
-- cons: needs a solution to monsters coming into spawn #rnd: this is no con, let them get scared early :)
--       maybe just disappear them
--       players can be sniped from outside (there is a hill though) #again no con: little fear is good, lets cover inside spawn and plan escape

-- checked on each server step

-- BTW: on viking's craft server they dont do it with privs it seems, i still had interact when inside /shop

-- #rnd : optimised version with safety checks, with as little of privs writing as possible, also just one for loop and careful if checks
-- using is_in_spawn to check

local time;
local PEACE_UPDATE_TIME = 2;
local PEACE_RADIUS = 16

minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time< PEACE_UPDATE_TIME then return end -- to prevent too fast unnecessary
	
	time = 0
	
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if name~=nil then -- safety to prevent crash
			local privs = minetest.get_player_privs(name)
			privs["interact"] = true;
			local pos = player:getpos();
			if is_inside_spawn(pos) then
				if privs["privs"] == false then -- inside spawn and not admin
					privs["interact"] = false;minetest.set_player_privs(name, privs)
				end
			else 
				-- if not inside spawn and no interact give it back:
				if privs["interact"] == false then privs["interact"] = true;minetest.set_player_privs(name, privs) end
			end
		end
		end

	end,
}) 


function is_inside_spawn(pos) -- rnd
	local spawnpoint = core.setting_get_pos("static_spawnpoint")
	local dist = math.abs(pos.x-spawnpoint.x)+math.abs(pos.z-spawnpoint.z)+math.abs(pos.z-spawnpoint.z) -- 1-metric for distance
	if dist< PEACE_RADIUS then return true else return false end
end




-- disablecloud's code:

-- i suppose we don't have to remove effect on death, logout: # no need
-- minetest.register_globalstep(function(dtime)
	-- time = time + dtime
	-- if time< PEACE_UPDATE_TIME then return end
	
	-- time = 0
	
-- -- ugly hardcoded values of spawn area
	
	-- location1 = { x=-13, y=20, z=57 }
	-- location2 = { x=3, y=13, z=67 }

	-- -- first we grant interact to all, this can't cost much, i hope?
	-- for _,player in ipairs(minetest.get_connected_players()) do
		-- local name = player:get_player_name()
		-- local privs = minetest.get_player_privs(name)
		-- privs["interact"] = true;
		-- minetest.set_player_privs(name, privs)
	-- end

	-- -- then we revoke from people in box, who aren't admins
	-- for _,player in ipairs(minetest.get_connected_players()) do
		-- if (vector_is_in(location1, location2, player:getpos())) then
			-- local name = player:get_player_name()
			-- local privs = minetest.get_player_privs(name)
			-- if privs["privs"] == false then
				-- privs["interact"] = false;
				-- minetest.set_player_privs(name, privs)
			-- end
		-- end
	-- end
		
	-- end,
-- }) 


-- function is_inside_spawn(pos) -- rnd
	-- local spawnpoint = core.setting_get_pos("static_spawnpoint")
	-- local dist = math.sqrt((pos.x-spawnpoint.x)^2+(pos.z-spawnpoint.z)^2+(pos.z-spawnpoint.z)^2)
	-- if dist< 16 then return true else return false end
-- end

-- function vector_is_in(hay,box,needle)
	-- if (needle.x > hay.x and needle.x < box.x) then
		-- if (needle.y > hay.y and needle.y < box.y) then
			-- if (needle.z > hay.z and needle.z <box.z) then
				-- return true
			-- end
		-- end
	-- end
	-- return false
-- end

-- -- i suppose we don't have to remove effect on death, logout



