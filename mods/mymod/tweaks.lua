-- -- redefine node definitions

-- local function overwrite(name)
	-- local table = minetest.registered_nodes[name]
	-- local table2 = {}
	-- for i,v in pairs(table) do
		-- table2[i] = v
	-- end
	-- table2.groups.falling_node=1 -- makes stuff fall under gravity and plant on floor, could be problem with protection?
	-- minetest.register_node(":"..name, table2)
-- end 

-- overwrite("default:junglesapling")
-- overwrite("default:sapling")
-- overwrite("default:torch")



minetest.register_craft({
	type = "cooking",
	output = "default:coal_lump",
	recipe = "default:tree",
})
local function hurt_cactus() -- cactus tweak
	local name = "default:cactus"
	local table = minetest.registered_nodes[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
	table2.groups.disable_jump = 1
	table2.damage_per_second = 5
	minetest.register_node(":"..name, table2)	
end
hurt_cactus();

local function tree_chop(name) -- cactus like tree chopping for breaker
	local table = minetest.registered_nodes[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
	table2.after_dig_node = function(pos, node, metadata, digger)
		local wielded = digger:get_wielded_item();
		tp = wielded:get_name()
		if tp=="default:pick_mese" then
			default.dig_up(pos, node, digger)
		end
	end
	minetest.register_node(":"..name, table2)	
end
tree_chop("default:tree");
tree_chop("default:pinetree");
tree_chop("default:jungletree");

tree_chop("moretrees:beech_trunk");
tree_chop("moretrees:apple_tree_trunk");
tree_chop("moretrees:oak_trunk");
tree_chop("moretrees:sequoia_trunk");
tree_chop("moretrees:birch_trunk");
tree_chop("moretrees:palm_trunk");
tree_chop("moretrees:spruce_trunk");
tree_chop("moretrees:pine_trunk");
tree_chop("moretrees:willow_trunk");
tree_chop("moretrees:acacia_trunk");
tree_chop("moretrees:rubber_tree_trunk");
tree_chop("moretrees:jungletree_trunk");
tree_chop("moretrees:fir_trunk");

-- NO TORCHES UNDERWATER


local function torch_vanish_underwater()
	local name = "default:torch"
	local table = minetest.registered_nodes[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
	table2.after_place_node = function(pos, placer, itemstack, pointed_thing)
		local water = "default:water_source";
		if minetest.find_node_near(pos, 1, {"group:water"})~= nil then
			minetest.sound_play("default_cool_lava", {pos = pos,  gain = 0.25})
			minetest.set_node(pos,{name="air"}); 
		end
		
	end
	minetest.register_node(":"..name, table2)	
end
minetest.after(5,torch_vanish_underwater)

local function stronger_mese_torch()
	local name = "mesecons_torch:mesecon_torch_on"
	local table = minetest.registered_nodes[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
	table2.light_source = LIGHT_MAX-1,
	minetest.register_node(":"..name, table2)	
end
minetest.after(5, stronger_mese_torch)

-- DIGGING SPEEDS FOR PICKAXES

local function adjust_dig_speed(name,factor)
	local table = minetest.registered_items[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
		
	for i,v in pairs(table2.tool_capabilities.groupcaps.cracky.times) do
		table2.tool_capabilities.groupcaps.cracky.times[i] = v*factor
	end	
	minetest.register_tool(":"..name, table2)	
end

local dig_factor = 2.5;
adjust_dig_speed("default:pick_wood",dig_factor)
adjust_dig_speed("default:pick_stone",dig_factor)
adjust_dig_speed("default:pick_steel",dig_factor)
adjust_dig_speed("default:pick_bronze",dig_factor)
adjust_dig_speed("default:pick_mese",dig_factor)
adjust_dig_speed("default:pick_diamond",dig_factor)
adjust_dig_speed("moreores:pick_silver",dig_factor)
adjust_dig_speed("moreores:pick_mithril",dig_factor)



-- ONLY ALLOW TO PLACE LAVA NEAR PROTECTOR WITH HIGH ACTIVITY OR BELOW 0

local function restrict_place_source(name)
	local table = minetest.registered_items[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
		
	table2.on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if pos.y>=0 then return else end -- rnd: unfinished
		
		-- look for nearby protector to read activity
		local activity;
		local r = 5;
		local name = placer:get_player_name(); if name==nil then return end
		local positions = minetest.find_nodes_in_area(
				{x=pos.x-r, y=pos.y-r, z=pos.z-r},
				{x=pos.x+r, y=pos.y+r, z=pos.z+r},
				"protector:protect");
		local protected = false;local ppos;
				for _, p in ipairs(positions) do
					local nmeta = minetest.env:get_meta(p)
					local owner = nmeta:get_string("owner")
					if owner == name then protected = true; ppos = p;end
				end
		local meta
		if ppos then  
			meta = minetest.get_meta(ppos);activity = 0.5*meta:get_int("activity");
			else activity = -1
		end
		
		if activity<1000 then
			return 
		else -- unfinished
		end
	end
	minetest.register_node(name, table2);
			
end

-- restrict_place_source("default:water_source")
-- restrict_place_source("default:lava_source")
-- restrict_place_source("mymod:acid_source_active")


local old_bucket_lava_on_place=minetest.registered_craftitems["bucket:bucket_lava"].on_place

lava_bucket_check = function(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above
	if pos.y<0 then return old_bucket_lava_on_place(itemstack, placer, pointed_thing) end -- rnd
	
	-- look for nearby protector to read activity
	local activity;
	local r = 5;
	local name = placer:get_player_name(); if name==nil then return end
	local positions = minetest.find_nodes_in_area(
			{x=pos.x-r, y=pos.y-r, z=pos.z-r},
			{x=pos.x+r, y=pos.y+r, z=pos.z+r},
			"protector:protect");
	local protected = false;local ppos;
			for _, p in ipairs(positions) do
				local nmeta = minetest.env:get_meta(p)
				local owner = nmeta:get_string("owner")
				if owner == name then protected = true; ppos = p;end
			end
	local meta
	if ppos then  
		meta = minetest.get_meta(ppos);activity = 0.5*meta:get_int("activity");
		else activity = -1
	end
	
	if activity>1000 then
		return old_bucket_lava_on_place(itemstack, placer, pointed_thing)
	else
        if activity>-1 then
			minetest.chat_send_player(placer:get_player_name(), "Only place lava near protector with activity at least 1000. This one has ".. activity)
			else minetest.chat_send_player(placer:get_player_name(), "Only place lava below ground");
		end
		return itemstack
	end
end

minetest.registered_craftitems["bucket:bucket_lava"].on_place=lava_bucket_check


local old_bucket_water_on_place=minetest.registered_craftitems["bucket:bucket_water"].on_place

water_bucket_check = function(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above
	if pos.y<0 then return old_bucket_water_on_place(itemstack, placer, pointed_thing) end -- rnd
	
	-- look for nearby protector to read activity
	local activity;
	local r = 5;
	local name = placer:get_player_name(); if name==nil then return end
	local positions = minetest.find_nodes_in_area(
			{x=pos.x-r, y=pos.y-r, z=pos.z-r},
			{x=pos.x+r, y=pos.y+r, z=pos.z+r},
			"protector:protect");
	local protected = false;local ppos;
			for _, p in ipairs(positions) do
				local nmeta = minetest.env:get_meta(p)
				local owner = nmeta:get_string("owner")
				if owner == name then protected = true; ppos = p;end
			end
	local meta
	if ppos then  
		meta = minetest.get_meta(ppos);activity = 0.5*meta:get_int("activity");
		else activity = -1
	end
	
	if activity>1000 then
		return old_bucket_water_on_place(itemstack, placer, pointed_thing)
	else
        if activity>-1 then
			minetest.chat_send_player(placer:get_player_name(), "Only place water near protector with activity at least 1000. This one has ".. activity)
			else minetest.chat_send_player(placer:get_player_name(), "Only place water below ground");
		end
		return itemstack
	end
end

minetest.registered_craftitems["bucket:bucket_water"].on_place=water_bucket_check

-- FARMING TWEAK
-- when fully grown wheat/cotton is picked it gives extra seeds when farm skill >= 10


local function tweak_seeds(name) -- farming:seed_wheat
	local table = minetest.registered_items["farming:"..name.."_8"];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
		
	table2.after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local pname = digger:get_player_name(); if pname==nil then return end
		if not playerdata then return end; if not playerdata[pname] then return end
		local skill = playerdata[pname].farming; if skill < 50 then return end
		
		local count = math.random(2)+math.random(2);
		local stack = ItemStack("farming:seed_"..name.." " .. count);
		local inv = digger:get_inventory();
		if inv:room_for_item("main",stack) then inv:add_item("main",stack) end
	end
	minetest.register_node(":farming:"..name.."_8", table2);
end

tweak_seeds("cotton");tweak_seeds("wheat");


-- prevent players with low farming to place advanced tree saplings

local function tweak_saplings(name,skill_req) -- farming:seed_wheat
	local table = minetest.registered_items[name];
	local table2 = {};
	for i,v in pairs(table) do table2[i] = v end
		
	table2.after_place_node = function(pos, placer, itemstack, pointed_thing)
		local pname = placer:get_player_name(); if pname==nil then return end
		local skill = playerdata[pname].farming;
		if skill < skill_req then
			local inv = placer:get_inventory();
			inv:remove_item("main", ItemStack(name.. " 90"))
			minetest.set_node(pos,{name = "air"})
			itemstack:clear();
			minetest.chat_send_player(pname,"You need " .. skill_req .. " farming before you can plant this sapling .")
			return
		end
	end
	
	table2.can_dig = function(pos, player)
		local pname = player:get_player_name(); if pname==nil then return false end
		local skill = playerdata[pname].farming;
		if skill < skill_req then
			local inv = player:get_inventory();
			inv:remove_item("main", ItemStack(name.. " 90"))
			minetest.chat_send_player(pname,"You need " .. skill_req .. " farming before you can dig this sapling .")
			return false
		end
		return true
	end
	

	minetest.register_node(":"..name, table2);
	
			
end

minetest.after(1, function()
tweak_saplings("moretrees:apple_tree_sapling",20);
tweak_saplings("moretrees:rubber_tree_sapling",30);
tweak_saplings("moretrees:willow_sapling",45);
tweak_saplings("moretrees:acacia_sapling",67);
tweak_saplings("moretrees:fir_sapling",101);
tweak_saplings("moretrees:pine_sapling",151);
tweak_saplings("moretrees:spruce_sapling",227);
tweak_saplings("moretrees:birch_sapling",341);
tweak_saplings("moretrees:beech_sapling",512);
tweak_saplings("moretrees:oak_sapling",768);
tweak_saplings("moretrees:sequoia_sapling",1153);
tweak_saplings("moretrees:palm_sapling",1729);
end
)