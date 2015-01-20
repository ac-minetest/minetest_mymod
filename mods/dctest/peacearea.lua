-- PvP-FREE AREA
-- purpose: revoke interact privilege from players within effect area
-- except admins

-- pros: lets players read signs and chat peacefully as long
--       as they are confined to the spawn cage
--       (is this a + to you?)
-- cons: needs a solution to monsters coming into spawn
--       maybe just disappear them
--       players can be sniped from outside (there is a hill though)

-- checked on each server step
minetest.register_globalstep(function(dtime)
-- ugly hardcoded values of spawn area
	location1 = { x=-13, y=20, z=57 }
	location2 = { x=3, y=13, z=67 }

	-- first we grant interact to all, this can't cost much, i hope?
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		privs["interact"] = true;
		minetest.set_player_privs(name, privs)
	end

	-- then we revoke from people in box, who aren't admins
	for _,player in ipairs(minetest.get_connected_players()) do
		if (vector_is_in(location1, location2, player:getpos())) then
			local name = player:get_player_name()
			local privs = minetest.get_player_privs(name)
			if privs["privs"] == false then
				privs["interact"] = false;
				minetest.set_player_privs(name, privs)
			end
		end
	end
		
	end,
}) 


function vector_is_in(hay,box,needle)
	if (needle.x > hay.x and needle.x < box.x) then
		if (needle.y > hay.y and needle.y < box.y) then
			if (needle.z > hay.z and needle.z <box.z) then
				return true
			end
		end
	end
	return false
end

-- i suppose we don't have to remove effect on death, logout
