-- rnd : CRAFTING DIRT FROM BONES

minetest.register_craft({
	output = "default:dirt",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})

minetest.register_craft({
	output = "default:dirt",
	recipe = {
		{"", "default:coal_lump",""},
		{"bones:bones", "bones:bones","bones:bones"},
		{"default:papyrus", "bones:bones","default:papyrus"}
	}
})


minetest.register_craft({
	output = "default:sand",
	recipe = {
		{"bones:bones", "bones:bones"},
		{"bones:bones", "bones:bones"}
	}
})

minetest.register_craft({
	output = "bones:bones",
	recipe = {
		{"default:stone", "default:tree","default:stone"},
	}
})

minetest.register_craft({
	output = "default:desert_cobble",
	recipe = {
		{"default:stone", "default:sandstone","default:stone"},
	}
})

minetest.register_craft({
	output = "default:clay",
	recipe = {
		{"bones:bones 4"},
	}
})



minetest.register_craft({
	output = "default:sapling",
	recipe = {
		{"default:dirt", "bones:bones"}
	}
})

-- OTHER RECIPES

minetest.register_craft({
	output = "default:papyrus",
	recipe = {
		{"default:dirt","default:leaves"},
		}
})

minetest.register_craft({
	output = "default:cactus",
	recipe = {
		{"default:sand","default:leaves"},
		}
})


minetest.register_craft({
	output = "farming:seed_wheat",
	recipe = {
		{"default:dirt", "papyrus"}
	}
})

minetest.register_craft({
	output = "farming:seed_cotton",
	recipe = {
		{"default:dirt", "farming:seed_wheat"}
	}
})

minetest.register_craft({
	output = "default:gravel",
	recipe = {
		{"default:stone"},
	}
})

minetest.register_craft({
	output = "default:pine_sapling",
	recipe = {
		{"default:dirt","default:cactus"},
	}
})

minetest.register_craft({
	output = "default:junglesapling",
	recipe = {
		{"default:dirt","default:pine_sapling"},
	}
})

-- MORE TREES

minetest.register_craft({
	output = "moretrees:jungletree_sapling",
	recipe = {
		{"default:dirt","default:junglesapling","default:pine_sapling"},
	}
})

minetest.register_craft({
	output = "moretrees:apple_tree_sapling",
	recipe = {
		{"default:apple","flowers:tulip","default:apple"},
		{"flowers:tulip","default:junglesapling","flowers:tulip"},
		{"default:apple","flowers:tulip","default:apple"}
	}
})

minetest.register_craft({
	output = "moretrees:rubber_tree_sapling",
	recipe = {
		{"building_blocks:Tar","building_blocks:Tar","building_blocks:Tar"},
		{"building_blocks:Tar","moretrees:apple_tree_sapling","building_blocks:Tar"},
		{"building_blocks:Tar","building_blocks:Tar","building_blocks:Tar"}
	}
})

minetest.register_craft({
	output = "moretrees:willow_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:rubber_tree_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})


minetest.register_craft({
	output = "moretrees:acacia_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:willow_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:fir_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:acacia_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:pine_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:fir_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:spruce_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:pine_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:birch_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:spruce_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:beech_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:birch_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:oak_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:beech_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:sequoia_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:oak_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})

minetest.register_craft({
	output = "moretrees:palm_sapling",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","moretrees:sequoia_sapling","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"}
	}
})


-- FLOWERS
minetest.register_craft({
	output = "flowers:dandelion_white",
	recipe = {
		{"default:dirt","default:dirt","default:dirt"},
		{"default:dirt","default:diamond","default:dirt"},
		{"default:dirt","default:dirt","default:dirt"},
	}
})

minetest.register_craft({
	output = "flowers:dandelion_yellow",
	recipe = {
		{"default:dirt","flowers:dandelion_white","default:gold_ingot"},
	}
})

minetest.register_craft({
	output = "flowers:geranium",
	recipe = {
		{"default:dirt","flowers:dandelion_white","moreores:mithril_ingot"},
	}
})


minetest.register_craft({
	output = "flowers:flower_rose",
	recipe = {
		{"default:dirt","flowers:dandelion_white","default:brick"},
	}
})

minetest.register_craft({
	output = "flowers:tulip",
	recipe = {
		{"default:dirt","flowers:dandelion_yellow","flowers:rose"},
	}
})


minetest.register_craft({
	output = "travelnet:travelnet",
	recipe = {
		{"default:mese","default:mese","default:mese"},
		{"default:mese","moreores:mithril_block","default:mese"},
		{"default:mese","default:mese","default:mese"},
	}
})

-- ORES

minetest.register_craft({
	output = "default:diamond",
	recipe = {
		{"default:coalblock", "default:coalblock",""},
		{"default:coalblock", "default:coalblock",""}
	}
})
minetest.register_craft({
	output = "default:mese_crystal 2",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot", "default:diamond","default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot","default:steel_ingot"}
	}
})
