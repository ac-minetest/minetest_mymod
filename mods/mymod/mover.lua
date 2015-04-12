-- rnd mod

-- MOVER: universal moving machine, requires coal in nearby chest to operate
-- can take item from chest and place it in chest or as a node outside at ranges -5,+5
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

		local form  = 
		"size[3,3]" ..  -- width, height
		"field[0,0.5;1,1;x1;x1;0] field[1,0.5;1,1;y1;y1;-1] field[2,0.5;1,1;z1;z1;0]"..
		"field[0,1.5;1,1;x2;x2;0] field[1,1.5;1,1;y2;y2;1] field[2,1.5;1,1;z2;z2;0]"..
		"button[0,2.;1,1;OK;OK]"
		meta:set_string("formspec", form)
	end,
	
	
	on_receive_fields = function(pos, formname, fields, sender) 
		local name = sender:get_player_name(); if name==nil then return end
		local meta = minetest.get_meta(pos)
		if name ~= meta:get_string("owner") or not fields then return end -- only owner can interact
		--minetest.chat_send_all("formname " .. formname .. " fields " .. dump(fields))
		
		if fields.OK == "OK" then
			local x1,y1,z1,x2,y2,z2;
			x1=tonumber(fields.x1);y1=tonumber(fields.y1);z1=tonumber(fields.z1)
			x2=tonumber(fields.x2);y2=tonumber(fields.y2);z2=tonumber(fields.z2);
			if math.abs(x1)>5 or math.abs(y1)>5 or math.abs(z1)>5 or math.abs(x2)>5 or math.abs(y2)>5 or math.abs(z2)>5 then
				minetest.chat_send_player(name,"all coordinates must be between -5 and 5"); return
			end
			meta:set_int("x1",x1);meta:set_int("y1",y1);meta:set_int("z1",z1);			
			meta:set_int("x2",x2);meta:set_int("y2",y2);meta:set_int("z2",z2);
			meta:set_string("infotext", "Mover block. Set up with source coords ".. x1 ..","..y1..","..z1.. " and target coord ".. x2 ..","..y2..",".. z2 .. ". Put chest with coal next to it and start with mese signal.");
		end
	end,
		
	mesecons = {effector = {
		action_on = function (pos, node) 
		local meta = minetest.get_meta(pos);
		local fuel = meta:get_float("fuel");
		if fuel < 0 then return end -- deactivated
		if fuel==0 then -- needs fuel to operate
			--minetest.chat_send_all(" no fuel ")
			local fpos = minetest.find_node_near(pos, 1, {"default:chest"}) -- furnace position
			if not fpos then return end -- no chest with fuel found
			local cmeta = minetest.get_meta(fpos);
			local inv = cmeta:get_inventory();
			local stack = ItemStack({name="default:coal_lump"})
			if inv:contains_item("main", stack) then
				--minetest.chat_send_all(" refueled ")
				inv:remove_item("main", stack)
				meta:set_float("fuel", MOVER_FUEL_STORAGE_CAPACITY);
				meta:set_string("infotext", "Mover block. Fuel "..MOVER_FUEL_STORAGE_CAPACITY);
			else meta:set_string("infotext", "Mover block. Out of fuel.");return
			end
			--check fuel
			return 
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
	
	local node1 = minetest.get_node(pos1);
	if node1.name == "air" then return end -- nothing to move
	
	local node2 = minetest.get_node(pos2);
	local meta1 = minetest.get_meta(pos1);local table1=meta1:to_table(); -- copy meta
	
	--minetest.chat_send_all(" moving ")
	meta:set_float("fuel", fuel - 1);
	meta:set_string("infotext", "Mover block. Fuel "..fuel-1);
	minetest.set_node(pos2, {name = node1.name});
	minetest.set_node(pos1, {name = "air"});
	local meta2 = minetest.get_meta(pos2);meta2:from_table(table1); 
	end
	}
	},
})

minetest.register_craft({
	output = "mymod:mover",
	recipe = {
		{"bones:bones", "bones:bones", "bones:bones"},
		{"bones:bones", "default:diamondblock","bones:bones"},
		{"bones:bones", "bones:bones", "bones:bones"}
	}
})