minetest.after(0, function()
 if not armor.def then
	minetest.after(2,minetest.chat_send_all,"#Better HUD: Please update your version of 3darmor")
	HUD_SHOW_ARMOR = false
 end
end)

function hud.get_armor(player)
	if not player or not armor.def then
		return
	end
	local name = player:get_player_name()
	local def = armor.def[name] or nil
	if playerdata[name].mana and playerdata[name].max_mana then
		hud.set_armor(name, playerdata[name].mana, playerdata[name].max_mana)--def.state, def.count)
	end
end

function hud.set_armor(player_name, ges_state, items)
	hud.armor[player_name] = ges_state/items
end