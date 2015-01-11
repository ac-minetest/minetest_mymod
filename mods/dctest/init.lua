-- MOB BREEDER
-- purpose: define nodes that spawn specific mobs if there are not too many around yet
-- from https://forum.minetest.net/viewtopic.php?p=57231#p57231
use_mesecons = false

function mob_breeder(pos, mob_name)
	local objects = minetest.get_objects_inside_radius(pos, 8) -- radius
	local mob_count = 0
	for _,obj in ipairs(objects) do
		-- how to make it check for object mob name==mob_name?
		-- or count the mobs within radius in a more elegant way
		if (obj:is_player()) then
			mob_count = mob_count + 1
		end
	end
	if mob_count < 5 then
		minetest.env:add_entity({x=pos.x+math.random(-1,1),y=pos.y+math.random(2,3),z=pos.z+math.random(-1,1)}, mob_name)
	end
end

-- here i see a for looping over a list and defining spawners for specific mob types
-- animal spawners named "barn", monster spawners named "cursed stone" like on just test
minetest.register_node("dctest:mob_breeder", {
	description = "Chicken breeding barn",
	drawtype = "glasslike",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {"default_glass.png"},   
	sunlight_propagates = true,
	param2 = "light",
})

minetest.register_abm({
	nodenames = {"dctest:mob_breeder"},
	interval = 1.0,
	chance = 20,
	action = function(pos)
		mob_breeder(pos, "mob:chicken")
	end,
})
