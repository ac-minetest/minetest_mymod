-- sokoban push mechanics by rnd
local push_time = 0
minetest.register_node("mymod:crate", {
	description = "sokoban crate",
	tiles = {"crate.png"},
	is_ground_content = false,
	groups = {immortal = 1},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, player)
		local time = push_time; local t = minetest.get_gametime();
		if t-time<1 then return end;push_time = t
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
		if minetest.get_node(q).name=="air" then
			minetest.set_node(pos,{name="air"})
			minetest.set_node(q,{name="mymod:crate"})
			minetest.sound_play("default_dig_dig_immediate", {pos=q,gain=1.0,max_hear_distance = 24,})
		end
	end,
})

minetest.register_node("mymod:sokoban", {
description = "sokoban crate",
	tiles = {"default_brick.png","crate.png","crate.png","crate.png","crate.png","crate.png"},
	groups = {oddly_breakable_by_hand=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local form  = 
		"size[1,1]" ..  -- width, height
		"field[0,0.5;1,1;level;enter level 1-90;1]"
		meta:set_string("formspec", form)
		meta:set_string("infotext","sokoban level loader, right click to select level")
	end, 
	on_receive_fields = function(pos, formname, fields, sender) 
		local name = sender:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); if not privs.ban then return end
		if fields.level == nil then return end
		local lvl = tonumber(fields.level)-1;
		if lvl <0 or lvl >89 then return end
		
		file = io.open(minetest.get_modpath("mymod").."/sokoban.txt","r")
		if not file then minetest.chat_send_player(name,"failed to open sokoban.txt") return end
		local str = ""; local s; local p = {x=pos.x,y=pos.y,z=pos.z}; local i,j;i=0;
		while str~= nil do
			str = file:read("*line"); 
			if str~=nil and str =="; "..lvl then lvl_found=true break end
		end
		if not lvl_found then file:close();return end
		
		while str~= nil do
			str = file:read("*line"); 
			if str~=nil then 
				if string.sub(str,1,1)==";" then file:close(); return end
				i=i+1;
				for j = 1,string.len(str) do
					p.x=pos.x+i;p.z=pos.z+j; s=string.sub(str,j,j);
					p.y=p.y-1; minetest.set_node(p,{name="default:stone"}); p.y=p.y+1 -- clear floor
					if s==" " then minetest.set_node(p,{name="air"}) end
					if s=="#" then minetest.set_node(p,{name="default:wood"}) end
					if s=="$" then minetest.set_node(p,{name="mymod:crate"}) end
					if s=="." then p.y=p.y-1;minetest.set_node(p,{name="default:tree"}); p.y=p.y+1;minetest.set_node(p,{name="air"}) end
				end
			end
		end
		file:close();
	end,
})