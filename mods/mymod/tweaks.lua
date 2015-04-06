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


-- local function shared_chests()
	-- local name = "default:chest";
	-- local table = minetest.registered_nodes[name];
	-- local table2 = {};
	-- for i,v in pairs(table) do table2[i] = v end
	-- table2.allow_metadata_inventory_take = function(pos, listname, index, stack, player) -- rnd: make chests inside protection zone protected against take
		
		-- if not protector.can_dig(5,pos,player) then
			-- return 0
		-- end
		-- return stack:get_count()
	-- end
	-- minetest.register_node(":"..name, table2)	
-- end
-- shared_chests();


minetest.register_craft({
	type = "cooking",
	output = "default:coal_lump",
	recipe = "default:tree",
})

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



