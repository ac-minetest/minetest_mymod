-- sokoban push mechanics by rnd


local sokoban = {};
sokoban.push_time = 0
sokoban.blocks = 0;sokoban.level = 0; sokoban.moves=0;
sokoban.load=0;sokoban.playername =""
local SOKOBAN_WALL = "mymod:stone_maze"
local SOKOBAN_FLOOR = "default:stone"
local SOKOBAN_GOAL = "default:tree"


minetest.register_node("mymod:crate", {
	description = "sokoban crate",
	tiles = {"crate.png"},
	paramtype = "light",
	light_source = 10,
	is_ground_content = false,
	groups = {immortal = 1},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, player)
		local name = player:get_player_name(); if name==nil then return end
		if sokoban.playername~=name then 
			if sokoban.playername == "" then 
				minetest.chat_send_player(name,"Please right click level loader block to load and play Sokoban")
				return
			end
			minetest.chat_send_player(name,"Only ".. sokoban.playername .. " can play. To play new level please right click loader block and select level.")
			return
		end
		local time = sokoban.push_time; local t = minetest.get_gametime();
		if t-time<1 then return end;sokoban.push_time = t
		local p=player:getpos();local q={x=pos.x,y=pos.y,z=pos.z}
		p.x=p.x-q.x;p.y=p.y-q.y;p.z=p.z-q.z
		if math.abs(p.y+0.5)>0 then return end
		if math.abs(p.x)>math.abs(p.z) then
			if p.z<-0.5 or p.z>0.5 or math.abs(p.x)>1.5 then return end
			if p.x+q.x>q.x then q.x= q.x-1 
				else q.x = q.x+1
			end
		else
			if p.x<-0.5 or p.x>0.5 or  math.abs(p.z)>1.5 then return end
			if p.z+q.z>q.z then q.z= q.z-1 
				else q.z = q.z+1
			end
		end
		
		
		if minetest.get_node(q).name=="air" then -- push crate
			sokoban.moves = sokoban.moves+1
			local old_infotext = minetest.get_meta(pos):get_string("infotext");
			minetest.set_node(pos,{name="air"})
			minetest.set_node(q,{name="mymod:crate"})
			minetest.sound_play("default_dig_dig_immediate", {pos=q,gain=1.0,max_hear_distance = 24,})
			local meta = minetest.get_meta(q);
			q.y=q.y-1; 
			if minetest.get_node(q).name==SOKOBAN_GOAL then  
				if old_infotext~="GOAL REACHED" then
					sokoban.blocks = sokoban.blocks -1;
				end
				meta:set_string("infotext", "GOAL REACHED") 
			else 
				if old_infotext=="GOAL REACHED" then
					sokoban.blocks = sokoban.blocks +1
				end
				meta:set_string("infotext", "push crate on top of goal block") 
			end
		end
		local name = player:get_player_name(); if name==nil then return end
		if sokoban.blocks~=0 then
			minetest.chat_send_player(name,"move " .. sokoban.moves .. " : " ..sokoban.blocks .. " crates left ");
			else minetest.chat_send_all( name .. " just solved sokoban level ".. sokoban.level .. " in " .. sokoban.moves .. " moves. He gets " .. (sokoban.level-0.5)*100 .. " XP reward.")
			playerdata[name].xp = playerdata[name].xp + (sokoban.level-0.5)*100
			sokoban.playername = ""
		end
	end,
})


minetest.register_node("mymod:sokoban", {
description = "sokoban crate",
	tiles = {"default_brick.png","crate.png","crate.png","crate.png","crate.png","crate.png"},
	groups = {oddly_breakable_by_hand=1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 14,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local form  = 
		"size[2,1]" ..  -- width, height
		"field[0,0.5;2,1;level;enter level 1-90;1]"
		meta:set_string("formspec", form)
		meta:set_string("infotext","sokoban level loader, right click to select level")
		meta:set_int("time", minetest.get_gametime());
	end, 
	on_receive_fields = function(pos, formname, fields, sender) 
		local name = sender:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); 
		
		local meta = minetest.get_meta(pos)
		if not privs.ban then 
			local t = minetest.get_gametime();local t_old = meta:get_int("time");
			if t-t_old<120 then 
				minetest.chat_send_player(name,"Wait at least 2 minutes to load next level. "..120-(t-t_old) .. " seconds left.");
				return 
			end
		end
	
		if fields.level == nil then fields.level = 1 end -- default lvl 1
		meta:set_int("time", t);
		local lvl = tonumber(fields.level)-1;
		if lvl <0 or lvl >89 then return end
		
		file = io.open(minetest.get_modpath("mymod").."/sokoban.txt","r")
		if not file then minetest.chat_send_player(name,"failed to open sokoban.txt") return end
		local str = ""; local s; local p = {x=pos.x,y=pos.y,z=pos.z}; local i,j;i=0;
		local lvl_found = false
		while str~= nil do
			str = file:read("*line"); 
			if str~=nil and str =="; "..lvl then lvl_found=true break end
		end
		if not lvl_found then file:close();return end
		
		sokoban.blocks = 0;sokoban.level = lvl+1; sokoban.moves=0;
		while str~= nil do
			str = file:read("*line"); 
			if str~=nil then 
				if string.sub(str,1,1)==";" then
					sokoban.playername = name
					file:close(); minetest.chat_send_all("Sokoban level "..sokoban.level .." loaded."); return 
				end
				i=i+1;
				for j = 1,string.len(str) do
					p.x=pos.x+i;p.y=pos.y; p.z=pos.z+j; s=string.sub(str,j,j);
					p.y=p.y-1; 
					if minetest.get_node(p).name~=SOKOBAN_FLOOR then minetest.set_node(p,{name=SOKOBAN_FLOOR}); end -- clear floor
					p.y=p.y+1;
					if s==" " and minetest.get_node(p,{name="air"}).name~="air" then minetest.set_node(p,{name="air"}) end
					if s=="#" then minetest.set_node(p,{name=SOKOBAN_WALL}) end
					if s=="$" then minetest.set_node(p,{name="mymod:crate"});sokoban.blocks=sokoban.blocks+1 end
					if s=="." then p.y=p.y-1;minetest.set_node(p,{name=SOKOBAN_GOAL}); p.y=p.y+1;minetest.set_node(p,{name="air"}) end
					--starting position
					if s=="@" then p.y=p.y-1;minetest.set_node(p,{name="default:glass"}); p.y=p.y+1;minetest.set_node(p,{name="air"}) end
					if s~="@" then p.y = pos.y+2;minetest.set_node(p,{name="mymod:glass_maze"});  
						else p.y=pos.y+2;minetest.set_node(p,{name="default:ladder"})
					end -- roof above to block jumps
					
				end
			end
		end
		
		file:close();		
	end,
})