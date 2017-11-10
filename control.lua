require "util"
require("config.constants")
require("helpers")

--[[
script.on_init(function()
	
end)
]]

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == TB_DETONATOR_NAME then --DETONATE
		game.players[event.player_index].print("DETONATING")
	end
end)

function detonate(trenchBomb)

end