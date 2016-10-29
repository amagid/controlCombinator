data:extend({
	{
		type = "lamp",
		name = CC_NAME,
		icon = CC_ICON_PATH,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = CC_NAME},
		max_health = 2000,
		corpse = "small-remnants",
		energy_per_hit_point = 1,
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "5KW",
		light = {intensity = 0.0, size = 0},
		picture_off =
		{
			filename = CC_ENTITY_PATH,
			x = 0,
			y = 60,
			width = 82,
			height = 59,
			frame_count = 1,
			shift = {0.140625, 0.140625}
		},
		picture_on =
		{
			filename = CC_ENTITY_PATH,
			x = 0,
			y = 0,
			width = 82,
			height = 60,
			frame_count = 1,
			shift = {0.140625, 0.140625}
		},

		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.4, 0.4},
				green = {-0.4, 0.4},
			},
			wire =
			{
				red = {0.4, 0.4},
				green = {-0.4, 0.4},
			}
		},

		circuit_wire_max_distance = 7.5
	},

})
