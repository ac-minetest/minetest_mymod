-- rnd mod

-- MOVER: universal moving machine, requires coal in nearby chest to operate
-- can take item from chest and place it in chest or as a node outside at ranges -5,+5
-- it can be used for filtering by setting "prefered block". if set to "object" it will teleport all objects.

-- input is: where to take and where to put
-- to operate mese power is needed

MOVER_FUEL_STORAGE_CAPACITY =  5;

minetest.register_node("mymod:mover", {
	description = "Mover",
	tiles = {"default_furnace_top.png"},
	groups = {oddly_breakable_by_hand=2,mesecon_effector_on = 1},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Mover block. Right click to set it up.")
		meta:set_string("owner", placer:get_player_name());
		meta:set_int("x1",0);meta:set_int("y1",-1);meta:set_int("z1",0);
		meta:set_int("x2",0);meta:set_int("y2",1);meta:set_int("z2",0);
		meta:set_float("fuel",0)
		meta:set_string("prefer", "");

		
	end,
		
	-- on_receive_fields = function(pos, formname, fields, sender) 
		-- local name = sender:get_player_name(); if name==nil then return end
		-- local meta = minetest.get_meta(pos)
		-- if name ~= meta:get_string("owner") or not fields then return end -- only owner can interact
		----minetest.chat_send_all("formname " .. formname .. " fields " .. dump(fields))
		
		-- if fields.OK == "OK" then
			-- local x1,y1,z1,x2,y2,z2;
			-- x1=tonumber(fields.x1) or 0;y1=tonumber(fields.y1) or -1;z1=tonumber(fields.z1) or 0
			-- x2=tonumber(fields.x2) or 0;y2=tonumber(fields.y2) or 1;z2=tonumber(fields.z2) or 0;
			-- if math.abs(x1)>5 or math.abs(y1)>5 or math.abs(z1)>5 or math.abs(x2)>5 or math.abs(y2)>5 or math.abs(z2)>5 then
				-- minetest.chat_send_player(name,"all coordinates must be between -5 and 5"); return
			-- end
			-- meta:set_int("x1",x1);meta:set_int("y1",y1);meta:set_int("z1",z1);			
			-- meta:set_int("x2",x2);meta:set_int("y2",y2);meta:set_int("z2",z2);
			-- meta:set_string("infotext", "Mover block. Set up with source coords ".. x1 ..","..y1..","..z1.. " and target coord ".. x2 ..","..y2..",".. z2 .. ". Put chest with coal next to it and start with mese signal.");
		-- end
	-- end,
		
	mesecons = {effector = {
		action_on = function (pos, node) 
		local meta = minetest.get_meta(pos);
		local fuel = meta:get_float("fuel");
		if fuel < 0 then return end -- deactivated
		if fuel==0 then -- needs fuel to operate, find nearby open chest with fuel within radius 1
			local r = 1;
			local pos1 = {x=meta:get_int("x1")+pos.x,y=meta:get_int("y1")+pos.y,z=meta:get_int("z1")+pos.z};
			local pos2 = {x=meta:get_int("x2")+pos.x,y=meta:get_int("y2")+pos.y,z=meta:get_int("z2")+pos.z};
			local positions = minetest.find_nodes_in_area( --find furnace with fuel
			{x=pos.x-r, y=pos.y-r, z=pos.z-r},
			{x=pos.x+r, y=pos.y+r, z=pos.z+r},
			"default:chest")
			local fpos = nil;
			for _, p in ipairs(positions) do
				-- dont take coal from source or target location
				if (p.x ~= pos1.x or p.y~=pos1.y or p.z ~= pos1.z) and (p.x ~= pos2.x or p.y~=pos2.y or p.z ~= pos2.z) then
					fpos = p;
				end
			end
			
			if not fpos then return end -- no chest with fuel found
			local cmeta = minetest.get_meta(fpos);
			local inv = cmeta:get_inventory();
			local stack = ItemStack({name="default:coal_lump"})
			if inv:contains_item("main", stack) then
				--minetest.chat_send_all(" refueled ")
				inv:remove_item("main", stack)
				meta:set_float("fuel", MOVER_FUEL_STORAGE_CAPACITY);
				fuel = MOVER_FUEL_STORAGE_CAPACITY;
				meta:set_string("infotext", "Mover block. Fuel "..MOVER_FUEL_STORAGE_CAPACITY);
			else meta:set_string("infotext", "Mover block. Out of fuel.");return
			end
			--check fuel
			if fuel == 0 then return  end
		end 
	
	local pos1 = {x=meta:get_int("x1")+pos.x,y=meta:get_int("y1")+pos.y,z=meta:get_int("z1")+pos.z};
	local pos2 = {x=meta:get_int("x2")+pos.x,y=meta:get_int("y2")+pos.y,z=meta:get_int("z2")+pos.z};
	
	local owner = meta:get_string("owner");
	-- check protections
	
	--minetest.chat_send_all(" checking protection for owner ".. owner)
	if minetest.is_protected(pos1, owner) or minetest.is_protected(pos2, owner) then
		meta:set_float("fuel", -1);
		meta:set_string("infotext", "Mover block. Protection fail. Deactivated.")
	return end
	
	local prefer = meta:get_string("prefer"); local mode = meta:get_string("mode");
	
	if mode == "object" then -- teleport objects, for free
		for _,obj in pairs(minetest.get_objects_inside_radius(pos1, 2)) do
			obj:moveto(pos2, false) 	
		end
		minetest.sound_play("transporter", {pos=pos2,gain=1.0,max_hear_distance = 32,})
		--meta:set_float("fuel", fuel - 1);
		return 
	end
	
	
	local dig=false; if mode == "dig" then dig = true; end -- digs at target location
	local place=false; if mode == "place" then place = true; end -- places node at target location
	local drop = false; if mode == "drop" then drop = true; end -- drops node instead of placing it
	
	
	
	local node1 = minetest.get_node(pos1);
	local source_chest;	if string.find(node1.name,"default:chest") then source_chest=true end
	if node1.name == "air" then return end -- nothing to move
	
	if prefer~="" then -- prefered node set
		if prefer~=node1.name and not source_chest  then return end -- only take prefered node or from chests
		if source_chest then -- take stuff from chest
			--minetest.chat_send_all(" source chest detected")
			local cmeta = minetest.get_meta(pos1);
			local inv = cmeta:get_inventory();
			local stack = ItemStack({name=prefer})
			if inv:contains_item("main", stack) then
				inv:remove_item("main", stack);
				else return
			end
		end
		node1 = {}; node1.name = prefer; 
	end
	
	if source_chest and prefer == "" then return end
	
	local node2 = minetest.get_node(pos2);
	--minetest.chat_send_all(" moving ")
	fuel = fuel -1;	meta:set_float("fuel", fuel); -- burn fuel
	meta:set_string("infotext", "Mover block. Fuel "..fuel);
	
	-- if target chest put in chest
	local target_chest = false
	if node2.name == "default:chest" or node2.name == "default:chest_locked" then
		target_chest = true
		local cmeta = minetest.get_meta(pos2);
		local inv = cmeta:get_inventory();
		local stack = ItemStack({name=node1.name})
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack);
		end
	end	
	
	minetest.sound_play("transporter", {pos=pos2,gain=1.0,max_hear_distance = 32,})
	
	if not target_chest then
		if not place and not drop then minetest.set_node(pos2, {name = node1.name}); end
		if drop then 
			local stack = ItemStack(node1.name);minetest.add_item(pos2,stack) -- drops it
		end
		if dig then 
			--minetest.node_dig(pos1, node1, digger) -- maybe this fix?
			minetest.dig_node(pos2);minetest.dig_node(pos1) 
		end -- DOESNT WORK!
		if place and not source_chest then minetest.place_node(pos2,node1) end -- DOESNT WORK!
	end
	if not source_chest then
		minetest.set_node(pos1, {name = "air"});
	end
	end
	}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos);
		local x1,y1,z1,x2,y2,z2,prefer,mode;
		x1=meta:get_int("x1");y1=meta:get_int("y1");z1=meta:get_int("z1");
		x2=meta:get_int("x2");y2=meta:get_int("y2");z2=meta:get_int("z2");
		prefer = meta:get_string("prefer");mode = meta:get_string("mode");
		local form  = 
		"size[2.75,4]" ..  -- width, height
		"field[0.25,0.5;1,1;x1;x1;"..x1.."] field[1.25,0.5;1,1;y1;y1;"..y1.."] field[2.25,0.5;1,1;z1;z1;"..z1.."]"..
		"field[0.25,1.5;1,1;x2;x2;"..x2.."] field[1.25,1.5;1,1;y2;y2;"..y2.."] field[2.25,1.5;1,1;z2;z2;"..z2.."]"..
		"button[2,3.25.;1,1;OK;OK] field[0.25,2.5;2,1;prefer;prefered block;"..prefer.."]"..
		"field[0.25,3.5;2,1;mode;mode;"..mode.."]";
		
		minetest.show_formspec(player:get_player_name(), "mymod:mover_"..minetest.pos_to_string(pos), form)
	end
})

minetest.register_on_player_receive_fields(function(player,formname,fields)
	
	local fname = "mymod:mover_"
	if string.sub(formname,0,string.len(fname)) == fname then
		local pos_s = string.sub(formname,string.len(fname)+1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name==nil then return end
		local meta = minetest.get_meta(pos)
		if name ~= meta:get_string("owner") or not fields then return end -- only owner can interact
		--minetest.chat_send_all("formname " .. formname .. " fields " .. dump(fields))
		
		if fields.OK == "OK" then
			local x1,y1,z1,x2,y2,z2;
			x1=tonumber(fields.x1) or 0;y1=tonumber(fields.y1) or -1;z1=tonumber(fields.z1) or 0
			x2=tonumber(fields.x2) or 0;y2=tonumber(fields.y2) or 1;z2=tonumber(fields.z2) or 0;
			if math.abs(x1)>5 or math.abs(y1)>5 or math.abs(z1)>5 or math.abs(x2)>5 or math.abs(y2)>5 or math.abs(z2)>5 then
				minetest.chat_send_player(name,"all coordinates must be between -5 and 5"); return
			end
			meta:set_int("x1",x1);meta:set_int("y1",y1);meta:set_int("z1",z1);			
			meta:set_int("x2",x2);meta:set_int("y2",y2);meta:set_int("z2",z2);
			meta:set_string("prefer",fields.prefer or "");
			meta:set_string("mode",fields.mode or "");
			meta:set_string("infotext", "Mover block. Set up with source coords ".. x1 ..","..y1..","..z1.. " and target coord ".. x2 ..","..y2..",".. z2 .. ". Put chest with coal next to it and start with mese signal.");
			if meta:get_float("fuel")<0 then meta:set_float("fuel",0) end -- reset block
		end
	end
end)

minetest.register_craft({
	output = "mymod:mover",
	recipe = {
		{"bones:bones", "bones:bones", "bones:bones"},
		{"bones:bones", "default:diamondblock","bones:bones"},
		{"bones:bones", "bones:bones", "bones:bones"}
	}
})


minetest.register_chatcommand("test", {
    description = "test dig",
    privs = {kick=true},
    func = function(name,param)
		
	end
	}
)