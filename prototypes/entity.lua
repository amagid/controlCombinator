data:extend({
	
    {
    type = "tile",
    name = TB_NAME,
    needs_correction = false,
    minable = {hardness = 0.2, mining_time = 0.5, result = TB_NAME},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1,
    layer = 60,
    decorative_removal_probability = 0.6,
    variants =
    {
      main =
      {
        {
          picture = "__base__/graphics/terrain/stone-path/stone-path-1.png",
          count = 16,
          size = 1
        },
        {
          picture = "__base__/graphics/terrain/stone-path/stone-path-2.png",
          count = 4,
          size = 2,
          probability = 0.39,
        },
        {
          picture = "__base__/graphics/terrain/stone-path/stone-path-4.png",
          count = 4,
          size = 4,
          probability = 1,
        },
      },
      inner_corner =
      {
        picture = "__base__/graphics/terrain/stone-path/stone-path-inner-corner.png",
        count = 8
      },
      outer_corner =
      {
        picture = "__base__/graphics/terrain/stone-path/stone-path-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__base__/graphics/terrain/stone-path/stone-path-side.png",
        count = 10
      },
      u_transition =
      {
        picture = "__base__/graphics/terrain/stone-path/stone-path-u.png",
        count = 10
      },
      o_transition =
      {
        picture = "__base__/graphics/terrain/stone-path/stone-path-o.png",
        count = 10
      }
    },
    walking_sound =
    {
      {
        filename = "__base__/sound/walking/concrete-01.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-02.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-03.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-04.ogg",
        volume = 1.2
      }
    },
    map_color={r=100, g=0, b=0},
    ageing=0,
    vehicle_friction_modifier = 1,
    dying_explosion = "massive-explosion"
  },

  {
    type = "constant-combinator",
    name = TB_DETONATOR_NAME,
    icon = TB_DETONATOR_ENTITY_PATH,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = TB_DETONATOR_NAME},
    max_health = 50,
    corpse = "small-remnants",
    dying_explosion = "explosion-hit",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 0,

    sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/combinator-entities.png",
        x = 158,
        y = 126,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/combinator-entities.png",
        y = 126,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/combinator-entities.png",
        x = 237,
        y = 126,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/combinator-entities.png",
        x = 79,
        y = 126,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      }
    },

    activity_led_sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-north.png",
        width = 11,
        height = 10,
        frame_count = 1,
        shift = {0.296875, -0.40625},
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-east.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = {0.25, -0.03125},
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-west.png",
        width = 12,
        height = 12,
        frame_count = 1,
        shift = {-0.21875, -0.46875},
      }
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 7.5
  }

})




--[[


{
		type = "container",
		name = CC_NAME,
		icon = CC_ICON_PATH,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = CC_NAME},
		max_health = 50,
		corpse = "small-remnants",
		open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
		close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		inventory_size = 1024,
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
			width = 82,
			height = 60,
			frame_count = 1,
			shift = {0.140625, 0.140625}
		},
		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.734375, 0.453125},
				green = {0.609375, 0.515625},
			},
			wire =
			{
				red = {0.40625, 0.21875},
				green = {0.40625, 0.375},
			}
		},
		circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.15625}, nil, 18),
		circuit_wire_max_distance = 7.5
	},


]]