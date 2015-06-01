-- code borrowed from carbone mod by Calinou

minetest.register_node("mymod:acid_flowing_active", {
	description = "Flowing Acid",
	inventory_image = minetest.inventorycube("mymod_acid.png"),
	drawtype = "flowingliquid",
	tiles = {"mymod_acid.png"},
	special_tiles = {
		{
			image = "mymod_acid_flowing_animated.png",
			backface_culling=false,
			animation={type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.6}
		},
		{
			image = "mymod_acid_flowing_animated.png",
			backface_culling=true,
			animation={type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.6}
		},
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	param1 = 0,
	light_source = 0,
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false, -- now you cant build over it, only the source..
	drop = "",
	drowning = 2,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mymod:acid_flowing_active",
	liquid_alternative_source = "mymod:acid_source_active",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 5,
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
})


minetest.register_node("mymod:acid_source_active", {
	description = "Acid Source",
	inventory_image = minetest.inventorycube("mymod_acid.png"),
	drawtype = "liquid",
	tiles = {
		{name = "mymod_acid_source_animated.png", animation={type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.5}}
	},
	special_tiles = {
		-- New-style acid source material (mostly unused)
		{
			name = "mymod_acid_source_animated.png",
			animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.5},
			backface_culling = false,
		}
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	param1 = 0,
	light_source = 0,
	walkable = false,
	pointable = false,
	diggable = true,
	buildable_to = false, -- only fireball destroys it
	drop = "",
	drowning = 2,
	liquidtype = "source",
	liquid_alternative_flowing = "mymod:acid_flowing_active",
	liquid_alternative_source = "mymod:acid_source_active",
	liquid_viscosity = WATER_VISC,
	damage_per_second = 8, 
	post_effect_color = {a = 120, r = 50, g = 90, b = 30},
	groups = {water = 3, acid = 3, liquid = 3, puts_out_fire = 1},
})

--  duplicate active source/flowing but make it passive

-- minetest.register_node("mymod:acid_source_passive", minetest.registered_nodes["mymod:acid_source_active"])
-- minetest.register_node("mymod:acid_flowing_passive", minetest.registered_nodes["mymod:acid_flowing_active"])


-- minetest.register_abm({ -- water polution
	-- nodenames = {"mymod:acid_source_active"},
	-- neighbors = {""},
	-- interval = 20,
	-- chance = 1,
	-- action = function(pos, node, active_object_count, active_object_count_wider)
		
		-- local meta = minetest.get_meta(pos);--if meta == nil then return end
		-- local life_count = node.param1;
		-- if life_count <= 0  then  minetest.set_node(pos, {name="mymod:acid_source_passive"})  return end -- spreads 3 around
		-- local meta_new,p,neighbor
		
		-- minetest.chat_send_all("debug count "..life_count)
		
		-- -- check neighbors
		-- local dir = {
		-- {x=-1,y=0,z=0},
		-- {x=1,y=0,z=0},
		-- {x=0,y=-1,z=0},
		-- {x=0,y=1,z=0},
		-- {x=0,y=0,z=-1},
		-- {x=0,y=0,z=1}		
		-- }; 
		
		-- for i=1,6 do
			-- p ={x=pos.x+dir[i].x,y=pos.y+dir[i].y,z=pos.z+dir[i].z};
			-- neighbor = minetest.get_node(p);
			
			-- if neighbor.name == "default:water_source" then
				-- minetest.set_node(p, {name="mymod:acid_source_active", param1 = life_count-1 })
			-- end
		-- end

	-- end,
-- }) 


-- DIGGING MAKES ACID WITH SMALL PROBABILITY

-- when stones digged under -10 they turn to acid source with small probability
local function overwrite(name)
	local table = minetest.registered_nodes[name]
	local table2 = {}
	for i,v in pairs(table) do
		table2[i] = v
	end
	table2.drop = '';
	
	-- table2.on_destruct = function(pos) -- for some reason this works even worse ( more blink) than on_dig
		-- --math.randomseed(pos.y)
		-- local i = math.random(100) -- probability if spawns acid
		-- if i == 1 and pos.y<0 then -- only underground
			-- minetest.set_node(pos, {name="mymod:acid_source_active"})
			-- else minetest.set_node(pos, {name="mymod:stone1"}) -- progressive stone digging
		-- end
	-- end;
	
	table2.on_dig = function(pos, node, digger)
		
		 if not protector.can_dig(5,pos,digger) then return end
		local name = digger:get_player_name(); if name == nil then return end
		if playerdata then
			if playerdata[name] then
				local dig  = playerdata[name].dig/5+200 
			end
			if pos.y<-dig then
				minetest.set_node(pos, {name="default:stone"})
				minetest.chat_send_player(name,"With current dig skill you can only dig up to depth "..dig);
				return
			end
		end

		minetest.node_dig(pos, node, digger) -- this code handles dig itself, after this experience is added
		
		local i,j,k
		i = math.random(100) -- probability if spawns acid
		local node;
		if i == 2 and pos.y < 0 then -- cave in
			-- find closest nearby ceiling block and collapse it by spawning 3x3x3 gravel
			--minetest.chat_send_all("CAVEIN")
			local p = {x=pos.x,y=pos.y,z=pos.z};
			local found = false;
			local r = 2;
			for i = -r,r do
				p.x =  pos.x+i
				for j = -r,r do
					p.z =  pos.z+j
					for k = 0,2 do
						p.y=pos.y+k
						node = (minetest.get_node(p)).name;
						if node == "default:stone" or node == "default:cobble" then
							p.y=p.y-1
							if (minetest.get_node(p)).name == "air" then
								found = true; p.y=p.y+1;goto continue;
							end
						end
					end
				end
			end
			
			::continue::
			if found then 
				minetest.sound_play("default_break_glass.1", {pos=pos, gain=1})
				--minetest.chat_send_all("COLLAPSING")
				pos.x=p.x;pos.y=p.y;pos.z=p.z
				for i = -r,r do
					p.x =  pos.x+i
					for j = -r,r do
						p.z=pos.z+j
						local h = math.random(2)-1
						for k = -1,h-1 do
							p.y=pos.y+k
							if (minetest.get_node(p)).name ~= "air" then
								minetest.set_node(p,{name="default:gravel"});
							end
						end
					end
				end
			end
			
			return
		end
		
		local wielded = (digger:get_wielded_item()):get_name()
		-- better picks dig in one step
		if wielded == "default:pick_diamond" or wielded == "moreores:pick_mithril" then 
			local player_inv = digger:get_inventory()
			local stk = ItemStack({name="default:cobble"})
			if player_inv:room_for_item("main", stk) then 
				player_inv:add_item("main", stk) 
				if i == 1 and pos.y<0 then -- only underground
					minetest.set_node(pos, {name="mymod:acid_source_active"})
					else minetest.set_node(pos, {name="air"})
				end
			end
			
		return
		end
		--math.randomseed(pos.y)
		
		if i == 1 and pos.y<0 then -- only underground
			minetest.set_node(pos, {name="mymod:acid_source_active"})
			else -- progressive stone digging
				minetest.set_node(pos, {name="mymod:stone1"}) 
		end
	end;
	minetest.register_node(":"..name, table2)
end 
overwrite("default:stone")


-- 3 phase stone digging

minetest.register_node("mymod:stone1", {
	description = "Stone 1",
	tiles = {"stone1.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = '',
	on_dig = function(pos, node, digger)
		minetest.set_node(pos, {name="mymod:stone2"}) -- progressive stone digging
	end,
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mymod:stone2", {
	description = "Stone 2",
	tiles = {"stone2.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})
