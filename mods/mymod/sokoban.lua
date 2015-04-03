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
			if playerdata~=nil then
				playerdata[name].xp = playerdata[name].xp + (sokoban.level-0.5)*100
			end
			sokoban.playername = ""; sokoban.level = 1
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
		"size[3,2]" ..  -- width, height
		"field[0,0.5;3,2.5;level;enter level 1-90;1]"
		meta:set_string("formspec", form)
		meta:set_string("infotext","sokoban level loader, right click to select level")
		meta:set_int("time", minetest.get_gametime());
	end, 
	on_punch = function(pos, node, player) -- make timer ready to enter
		local name = player:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); 
		if not privs.ban then return end
		local meta = minetest.get_meta(pos)
		local t = minetest.get_gametime(); meta:set_int("time", t-130)		
		minetest.chat_send_all("Sokoban loader reset. Load level now.")
	end,
	on_receive_fields = function(pos, formname, fields, sender) 
		local name = sender:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); 
		
		local meta = minetest.get_meta(pos)
		local t = minetest.get_gametime();local t_old = meta:get_int("time");
		if not privs.ban then 
			if t-t_old<300 and name~=sokoban.playername then 
				minetest.chat_send_player(name,"Wait at least 5 minutes to load next level. "..300-(t-t_old) .. " seconds left.");
				return 
			end
			if t-t_old<60 and name==sokoban.playername then 
				minetest.chat_send_player(name,"Wait at least 1 minute to load next level. "..60-(t-t_old) .. " seconds left.");
				return 
			end
		end
		
		if fields.level == nil then return end 
		sokoban.playername = name
		meta:set_int("time", t);
		local lvl = tonumber(fields.level)-1;
		if lvl <0 or lvl >89 then return end
		
		local file = io.open(minetest.get_modpath("mymod").."/sokoban.txt","r")
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
					file:close(); minetest.chat_send_all("Sokoban level "..sokoban.level .." loaded by ".. name .. ". It has " .. sokoban.blocks  .. " to push. "); return 
				end
				i=i+1;
				for j = 1,string.len(str) do
					p.x=pos.x+i;p.y=pos.y; p.z=pos.z+j; s=string.sub(str,j,j);
					p.y=p.y-1; 
					if minetest.get_node(p).name~=SOKOBAN_FLOOR then minetest.set_node(p,{name=SOKOBAN_FLOOR}); end -- clear floor
					p.y=p.y+1;
					if s==" " and minetest.get_node(p).name~="air" then minetest.set_node(p,{name="air"}) end
					if s=="#" and minetest.get_node(p).name~=SOKOBAN_WALL then minetest.set_node(p,{name=SOKOBAN_WALL}) end
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

-- CHECKERS GAME
local checkers ={};
checkers.piece = "";checkers.time = 0;
checkers.pos = {} -- bottom left position of 8x8 checkerboard piece
checkers.piece_pos = {} -- position of pick up piece

--game pieces

local function draw_board() -- pos is bottom left position of checkerboard
	
	local pos = checkers.pos;
	local node;
	for i = 1,8 do
		for j =1,8 do
			node = minetest.get_node({x=pos.x+i-1,y=pos.y,z=pos.z-1}).name;
			if (i+j) % 2 == 1 then 
				if node~="mymod:board_black" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z+j-1},{name = "mymod:board_black"}) end
				else
				if node~="mymod:board_white" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z+j-1},{name = "mymod:board_white"}) end
			end
			node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+j-1}).name;
			if node~="air" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+j-1},{name = "air"}) end
		end
	end

	for i = 1,4 do -- place pieces
		minetest.set_node({x=pos.x+2*i-1,y=pos.y+1,z=pos.z},{name = "mymod:checkers_red"})
		minetest.set_node({x=pos.x+2*i-2,y=pos.y+1,z=pos.z+1},{name = "mymod:checkers_red"})
		
		minetest.set_node({x=pos.x+2*i-1,y=pos.y+1,z=pos.z+6},{name = "mymod:checkers_blue"})
		minetest.set_node({x=pos.x+2*i-2,y=pos.y+1,z=pos.z+7},{name = "mymod:checkers_blue"})
	end
	
	for i = 1,8 do -- place kings
		node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z-2}).name;
		if node~="mymod:checkers_red_queen" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z-2},{name = "mymod:checkers_red_queen"}) end
		node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+9}).name;
		if node~="mymod:checkers_blue_queen" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+9},{name = "mymod:checkers_blue_queen"}) end
	end
	
end

minetest.register_node("mymod:checkers", {
description = "checkers crate",
	tiles = {"moreblocks_iron_checker.png","crate.png","crate.png","crate.png","crate.png","crate.png"},
	groups = {oddly_breakable_by_hand=1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 14,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local form  = 
		"size[3,2]" ..  -- width, height
		"field[0,0.5;3,2.5;level;enter level 1-90;1]"
		meta:set_string("formspec", form)
		meta:set_string("infotext","checkers game block, admin only")
		meta:set_int("time", minetest.get_gametime());
		checkers.pos = {x = pos.x+1, y=pos.y-1, z=pos.z+1}
	end, 
	on_punch = function(pos, node, player)
		local name = player:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); 
		if not privs.kick then return end -- only admin
		checkers.pos = {x = pos.x+1, y=pos.y-1, z=pos.z+1}
		draw_board()
	end
	}
	)


minetest.register_chatcommand("checkers", {
    description = "Start a game of checkers and refresh board display",
    privs = {kick=true},
    func = function(name,param)
		draw_board();checkers.piece = ""
	end
	}
)


function register_piece(name, desc, tiles, punch)
	minetest.register_node(name, {
		description = desc,
		drawtype = "nodebox",
		paramtype = "light",
		tiles = tiles,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3},
		sounds = default.node_sound_defaults(),
		node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
					
		},
		on_punch= punch,
	}) 
end
function register_board(name,desc,tiles)
	minetest.register_node(name, {
			description = desc,
			tiles = tiles,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3},
			sounds = default.node_sound_defaults(),
			on_punch = function(pos, node, player) -- place piece on board
					local name = player:get_player_name(); if name == nil then return end
					if checkers.pos.x == nil then minetest.chat_send_all("punch checkers game block before playing.") return end
					if checkers.piece == "" then return end
					local t = minetest.get_gametime(); if t-checkers.time <1 then return end; checkers.time = t;
					local above = {x=pos.x,y=pos.y+1;z=pos.z};
					local x,y; x= above.z-checkers.pos.z+1; y=above.x-checkers.pos.x+1;
					if x<1 or x>8 or y<1 or y>8 then
						minetest.chat_send_all(name .." captured piece at ".. checkers.piece_pos.z-checkers.pos.z+1 .. ","..checkers.piece_pos.x-checkers.pos.x+1)
						checkers.piece = "" return 
					end -- drop piece if put down outside checkerboard
					minetest.set_node(above, {name = checkers.piece});
					
					minetest.chat_send_all(
					name .." moved: ".. checkers.piece_pos.z-checkers.pos.z+1 .. "," .. checkers.piece_pos.x-checkers.pos.x+1 .. " to " ..
					x .. "," .. y )
					checkers.piece = ""
			end,
	}) 
end

local piece_punch  = function(pos, node, player) -- pick up piece
	if checkers.pos.x == nil then minetest.chat_send_all("punch checkers game block before playing (need kick priv).") return end
	if checkers.piece~="" then return end -- dont pick up another piece before last one was put down
	local t = minetest.get_gametime(); if t-checkers.time <1 then return end; checkers.time = t;
	checkers.piece = node.name; minetest.set_node(pos, {name="air"});
	checkers.piece_pos = {x=pos.x,y=pos.y,z=pos.z};
end

register_board("mymod:board_white","white board",{"wool_white.png"})
register_board("mymod:board_black","black board",{"wool_black.png"})

register_piece("mymod:checkers_blue","blue piece",{"wool_blue.png"},piece_punch)
register_piece("mymod:checkers_blue_queen","blue queen piece",{"queen_blue.png"},piece_punch)

register_piece("mymod:checkers_red","red piece",{"wool_red.png"},piece_punch)
register_piece("mymod:checkers_red_queen","red piece",{"queen_red.png"},piece_punch)
