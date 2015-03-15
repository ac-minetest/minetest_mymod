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

