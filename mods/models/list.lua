-- Models mod for minetest
-- Allows players to choose their player model in-game
-- License: WTFPL
-- Based on the skins mod by Zeg9 (WTFPL)

models.list = {}

--models.register_model(name, modeldef)
--Registers a character model
--Parameters:
--name:
-- This should be a unique name for the model (use the node naming
--  convention, for example: "mobs:dungeon_master")
--modeldef:
-- mesh: mesh to be loaded
-- textures: textures for the mesh (uv map)
-- preview: image preview in the model selection menu
-- visual_size: vertical/horizontal size (depends on model shape/size)
-- collisionbox: collision box dimensions
models.register_model = function(name, modeldef)
	models.list[name] = modeldef
end


--default player
models.register_model("character", {
	mesh = "character.x",
	textures = {"character.png"},
	preview = "models_character_preview.png",
	visual_size = {x=1, y=1},
	collisionbox = {-0.5, -1, -0.5, 0.5, 1, 0.5}
})


--some test models using simple mobs if installed
if (minetest.get_modpath("mobs") ~= nil) then
	models.register_model("mobs:dungeon_master", {
		mesh = "mobs_dungeon_master.x",
		textures = {"mobs_dungeon_master.png"},
		preview = "models_dm_preview.png",
		visual_size = {x=8, y=8},
		collisionbox = {-0.7, -0.01, -0.7, 0.7, 2.6, 0.7}
	})

	models.register_model("mobs:sheep", {
		mesh = "mobs_sheep.x",
		textures = {"mobs_sheep.png"},
		preview = "models_sheep_preview.png",
		visual_size = {x=1, y=1},
		collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4}
	})
end
