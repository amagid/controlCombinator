DEBUG = true

CC_NAME = "control_combinator"
CC_PRETTY_NAME = "Control Combinator"

CC_ICON_PATH = "__ControlCombinator__/graphics/control_combinator_icon.png"
CC_ENTITY_PATH = "__ControlCombinator__/graphics/control_combinator_entities.png"





-------------------------------------------
----------------- Styling -----------------
-------------------------------------------

--Master window dimensions
CC_WINDOW_WIDTH = 1000
CC_WINDOW_HEIGHT = 500

--General padding amount
CC_WINDOW_PADDING = 10

--Top padding for labels that appear next to buttons
CC_LABEL_PADDING = 8

--Set all padding and maximum sizes
function CC_WINDOW_SETSTYLE(styleObject)
	styleObject.top_padding = CC_WINDOW_PADDING
	styleObject.right_padding = CC_WINDOW_PADDING
	styleObject.bottom_padding = CC_WINDOW_PADDING
	styleObject.left_padding = CC_WINDOW_PADDING
end

-------------------------------------------
-------------- DEFAULT DATA ---------------
-------------------------------------------

CC_DEFAULT_PRIVATE_DATA = {
	combinators = {},
	categories = {
		{
			name = "Category with no signals",
			signals = {}
		}, 
		{
			name = "Category with a bunch of signals",
			signals = {
				{
					name = "active signal 1",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = true   --is this output currently active?
						}
					}
				},
				{
					name = "inactive signal 1",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false   --is this output currently active?
						}
					}
				}, 
				{
					name = "active signal 2",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false   --is this output currently active?
						}, 
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false     --is this output currently active?
						}, 
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = true   --is this output currently active?
						}
					}
				}, 
				{
					name = "inactive signal 2",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false  --is this output currently active?
						}
					}
				}
			}
		}
	}
}

CC_DEFAULT_PUBLIC_DATA = {
	combinators = {},
	categories = {
		{
			name = "Category with no signals",
			signals = {}
		}, 
		{
			name = "Category with a bunch of signals",
			signals = {
				{
					name = "active signal 1",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = true   --is this output currently active?
						}
					}
				},
				{
					name = "inactive signal 1",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false   --is this output currently active?
						}
					}
				}, 
				{
					name = "active signal 2",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false   --is this output currently active?
						}, 
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false     --is this output currently active?
						}, 
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = true   --is this output currently active?
						}
					}
				}, 
				{
					name = "inactive signal 2",
					outputs = {
						{
							color = "",        --color is green or red (wire colors)
							line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
							value = "",        --the output value
							type = "",         --type is "pulse", "duration", "toggle" or "circuit"
							combinator = int,  --combinator is the index of the combinator in the above array
							active = false  --is this output currently active?
						}
					}
				}
			}
		}
	}
}
