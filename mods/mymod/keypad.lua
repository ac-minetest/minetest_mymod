-- rnd mod

-- keypad: by punching it and entering password a preset machine is triggered or door opened or closed

minetest.register_node("mymod:keypad", {
	description = "Keypad",
	tiles = {"keypad.png"},
	groups = {oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Keypad. Right click to set it up")
		meta:set_string("owner", placer:get_player_name());
		meta:set_int("x0",0);meta:set_int("y0",-1);meta:set_int("z0",0); -- source1
		meta:set_string("password", ""); meta:set_int("public",0);
	end,
		
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos);
		local mode = meta:get_string("mode")
		x0=meta:get_int("x0");y0=meta:get_int("y0");z0=meta:get_int("z0");
		password = meta:get_string("password");
		local form  = 
		"size[3,5]" ..  -- width, height
		"button[2,4.25.;1,1;OK;OK] field[0.25,3.5;3,1;password;password;".."pass".."]"..
		--minetest.show_formspec("rnd", "test", form)
		
		minetest.show_formspec(player:get_player_name(), "mymod:keypad_"..minetest.pos_to_string(pos), form)
	end
})


local punchset = {}; 




minetest.register_on_player_receive_fields(function(player,formname,fields)
	
	local fname = "mymod:keypad_"
	if string.sub(formname,0,string.len(fname)) == fname then
		local pos_s = string.sub(formname,string.len(fname)+1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name==nil then return end
		local meta = minetest.get_meta(pos)
		if name ~= meta:get_string("owner") or not fields then return end -- only owner can interact
		--minetest.chat_send_all("formname " .. formname .. " fields " .. dump(fields))
		
		if fields.OK == "OK" then
			local x0,y0,z0,x1,y1,z1,x2,y2,z2;
			x0=tonumber(fields.x0) or 0;y0=tonumber(fields.y0) or -1;z0=tonumber(fields.z0) or 0
			x1=tonumber(fields.x1) or 0;y1=tonumber(fields.y1) or -1;z1=tonumber(fields.z1) or 0
			x2=tonumber(fields.x2) or 0;y2=tonumber(fields.y2) or 1;z2=tonumber(fields.z2) or 0;
			if math.abs(x1)>5 or math.abs(y1)>5 or math.abs(z1)>5 or math.abs(x2)>5 or math.abs(y2)>5 or math.abs(z2)>5 then
				minetest.chat_send_player(name,"all coordinates must be between -5 and 5"); return
			end
			if x1<x0 or y1<y0 or z1<z0 then
				minetest.chat_send_player(name,"second source coordinates must all be larger than first source coordinates"); return
			end
			
			meta:set_int("x0",x0);meta:set_int("y0",y0);meta:set_int("z0",z0);
			meta:set_int("x1",x1);meta:set_int("y1",y1);meta:set_int("z1",z1);
			meta:set_int("pc",0); meta:set_int("dim",(x1-x0+1)*(y1-y0+1)*(z1-z0+1))
			meta:set_int("x2",x2);meta:set_int("y2",y2);meta:set_int("z2",z2);
			meta:set_string("prefer",fields.prefer or "");
			meta:set_string("mode",fields.mode or "");
			meta:set_string("infotext", "Mover block. Set up with source coords ".. x0 ..","..y0..","..z0.. " -> ".. x1 ..","..y1..","..z1.. " and target coord ".. x2 ..","..y2..",".. z2 .. ". Put chest with coal next to it and start with mese signal.");
			if meta:get_float("fuel")<0 then meta:set_float("fuel",0) end -- reset block
		end
	end
end)

minetest.register_craft({
	output = "mymod:keypad",
	recipe = {
		{"default:stick"},
		{"default:tree"},
	}
})