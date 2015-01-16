-- The BLINKY_PLANT
minetest.register_node("mesecons_blinkyplant:blinky_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tiles = {"jeija_blinky_plant_off.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	walkable = false,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	drop="mesecons_blinkyplant:blinky_plant_off 1",
    description="Deactivated Blinky Plant",
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_rightclick = function(pos, node, clicker)
        minetest.set_node(pos, {name="mesecons_blinkyplant:blinky_plant_off"})
    end	
})

minetest.register_node("mesecons_blinkyplant:blinky_plant_off", {
	drawtype = "plantlike",
	visual_scale = 1,
	tiles = {"jeija_blinky_plant_off.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3, mesecon=2},
    description="Blinky Plant",
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_rightclick = function(pos, node, clicker)
        minetest.set_node(pos, {name="mesecons_blinkyplant:blinky_plant"})
    end
})

minetest.register_node("mesecons_blinkyplant:blinky_plant_on", {
	drawtype = "plantlike",
	visual_scale = 1,
	tiles = {"jeija_blinky_plant_on.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3, not_in_creative_inventory=1, mesecon=2},
	drop="mesecons_blinkyplant:blinky_plant_off 1",
	light_source = LIGHT_MAX-7,
	description = "Blinky Plant",
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_rightclick = function(pos, node, clicker)
		minetest.set_node(pos, {name = "mesecons_blinkyplant:blinky_plant"})
		mesecon:receptor_off(pos)
	end
})

minetest.register_craft({
	output = "mesecons_blinkyplant:blinky_plant_off 1",
	recipe = {
	{"","group:mesecon_conductor_craftable",""},
	{"","group:mesecon_conductor_craftable",""},
	{"default:sapling","default:sapling","default:sapling"},
	}
})

BLINKY_PLANT_TIMEOUT = 5;
minetest.register_abm({
	nodenames = {
		"mesecons_blinkyplant:blinky_plant_off",
		"mesecons_blinkyplant:blinky_plant_on"
	},
	interval = BLINKY_PLANT_INTERVAL,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local param2 = node.param2-- rnd : add timeout to blinky plants, after that they turn off
		minetest.chat_send_player("rnd", "count " .. param2 .. "  " .. 	param2 % 5)
		if (param2 % BLINKY_PLANT_TIMEOUT) == BLINKY_PLANT_TIMEOUT-1 then
				param2 = 0 --reset
				minetest.set_node(pos, {name = "mesecons_blinkyplant:blinky_plant",param2=param2})
				mesecon:receptor_off(pos)
				return
		end
		param2 =  param2+1
		
		
		if node.name == "mesecons_blinkyplant:blinky_plant_off" then
			minetest.add_node(pos, {name="mesecons_blinkyplant:blinky_plant_on", param2 = param2})
			mesecon:receptor_on(pos)
		else
			minetest.add_node(pos, {name="mesecons_blinkyplant:blinky_plant_off", param2 = param2})
			mesecon:receptor_off(pos)
		end
		nodeupdate(pos)	
	end,
})

