data:extend({
	{
		type = "technology",
		name = CC_NAME,
		icon = CC_TECH_ICON_PATH,
		icon_size = CC_TECH_ICON_SIZE,
		effects = {
			{
				type = "unlock-recipe",
				recipe = CC_NAME
			}
		},
		unit = {
			count = 150,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
			},
			time = 20
		},
		prerequisites = {"circuit-network", "advanced-electronics", "battery"},
		localised_description = {"technology-description." .. CC_NAME},
		order = "a-d-d"
	}
})
