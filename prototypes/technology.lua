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
			count = 1,
			ingredients = {
				{"science-pack-1", 1}
			},
			time = 5
		}
	}
})
