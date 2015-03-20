-- EXTRACTOR: extract stuff from bones with small probability

function bone_extractor(pos)
	
	local pos_above  = {x=pos.x,y=pos.y+1,z=pos.z};
	local pos_below  = {x=pos.x,y=pos.y-1,z=pos.z};
	local below = minetest.get_node(pos_below);
	if below.name~="air" then return end
	minetest.set_node(pos_above, {name="air"})
	local  i = math.random(1000);

	local out;
	if i>=800 then out = "bones:bones" end
	if i>=600 and i< 800 then out = "moreores:mineral_tin" end
	if i>=400 and i<600 then out = "default:stone_with_copper" end
	if i>=200 and i<400 then out = "default:stone_with_iron" end
	if i>=100 and i< 200 then out = "default:stone_with_gold" end
	if i>=50 and i<100 then out = "default:stone_with_mese" end
	if i>=25 and i<50 then out = "default:stone_with_diamond" end
	if i>=10 and i<25 then out = "moreores:mineral_mithril" end
	
	if out~=nil then
		minetest.set_node(pos_below, {name=out})
	end
	minetest.sound_play("default_cool_lava.3", {pos=pos, gain=1})
	
end

-- here i see a for looping over a list and defining spawners for specific mob types
-- animal spawners named "barn", monster spawners named "cursed stone" like on just test
minetest.register_node("mymod:bone_extractor", {
	description = "Bone extractor",
	tiles = {"extractor.png"},
	groups = {oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Bone extractor: place bones on top, extract appears below")
	end,
})

minetest.register_abm({
	nodenames = {"mymod:bone_extractor"},
	interval = 10.0,
	chance = 1,
	action = function(pos)		
		local pos_above = {x=pos.x,y=pos.y+1,z=pos.z}
		local above = minetest.get_node(pos_above)
		if above.name == "bones:bones" then 
			bone_extractor(pos)
		end
	end,
})


minetest.register_craft({
	output = "mymod:bone_extractor",
	recipe = {
		{"bones:bones", "bones:bones", "bones:bones"},
		{"bones:bones", "default:mese_block","bones:bones"},
		{"bones:bones", "bones:bones", "bones:bones"}
	}
})