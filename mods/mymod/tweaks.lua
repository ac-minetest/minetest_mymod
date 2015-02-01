-- redefine node definitions

local function overwrite(name)
	local table = minetest.registered_nodes[name]
	local table2 = {}
	for i,v in pairs(table) do
		table2[i] = v
	end
	table2.groups.falling_node=1 -- makes stuff fall under gravity and plant on floor, could be problem with protection?
	minetest.register_node(":"..name, table2)
end 

overwrite("default:junglesapling")
overwrite("default:sapling")
overwrite("default:torch")
