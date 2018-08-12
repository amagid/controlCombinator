data:extend({
	{
		type = "container",
		name = CC_NAME,
		icon = CC_ICON_PATH,
		icon_size = CC_ICON_SIZE,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = CC_NAME},
		max_health = 50,
		corpse = "small-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
		close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		inventory_size = 1,
		vehicle_impact_sound =	{ filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "5KW",
		picture =
		{
			filename = CC_ENTITY_PATH,
			x = 0,
			y = 0,
			width = 50,
			height = 50,
			frame_count = 1,
			shift = {0.140625, 0.140625}
		},
		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.26, -0.44},
				green = {-0.3, -0.44},
			},
			wire =
			{
				red = {0.22, -0.48},
				green = {-0.26, -0.48},
			}
		},
		circuit_wire_max_distance = 7.5
	},

})
