DEBUG = false

CC_NAME = "control-combinator"
CC_PRETTY_NAME = "Control Combinator"

CC_ICON_PATH = "__ControlCombinator__/graphics/control_combinator_icon.png"
CC_ENTITY_PATH = "__ControlCombinator__/graphics/control_combinator_gallery.png"
CC_TECH_ICON_PATH = "__ControlCombinator__/graphics/control_combinator_tech.png"

CC_ICON_SIZE = 38
CC_SIGNAL_ICON_SIZE = 32
CC_TECH_ICON_SIZE = 128

function CC_SIGNAL_ICON(number)
	return "__ControlCombinator__/graphics/control_combinator_signal_" .. number .. ".png"
end

function CC_SIGNAL_NAME(number)
	return "control-combinator-signal-" .. number
end

function CC_SIGNAL_PRETTY_NAME(number)
	return "Control Combinator Signal #" .. number
end


-------------------------------------------
----------------- Styling -----------------
-------------------------------------------

--Master window dimensions
CC_WINDOW_WIDTH = 1000
CC_WINDOW_HEIGHT = 400

--General padding amount
CC_WINDOW_PADDING = 10

--Top padding for labels that appear next to buttons
CC_LABEL_PADDING = 8


-------------------------------------------
-------------- DEFAULT DATA ---------------
-------------------------------------------

function CC_DEFAULT_PRIVATE_DATA()
	return {
		combinators = {}	
	}
end