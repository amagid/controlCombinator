function setStyles(styleObject, newStyleTable)
	for k, v in pairs(newStyleTable) do
		styleObject.style[k] = v
	end
end

function addLabelPadding(guiElement)
	if guiElement and type(guiElement) ~= "function" then
		if guiElement.type == "label" then
			guiElement.style.top_padding = CC_LABEL_PADDING
		end
		for _, name in ipairs(guiElement.children_names) do
			addLabelPadding(guiElement[name])
		end
	end
end

function setWidths(guiElement, layer)
	if guiElement and type(guiElement) ~= "function" then
		if guiElement.type == "frame" or guiElement.type == "flow" or guiElement.type == "scroll-pane" then
			guiElement.style.minimal_width = CC_WINDOW_WIDTH - (60 * layer)
			guiElement.style.maximal_width = CC_WINDOW_WIDTH - (60 * layer)
			if guiElement.name == "publicCategories" or guiElement.name == "privateCategories" or (guiElement.parent and (guiElement.parent.name == "publicCategories" or guiElement.parent.name == "privateCategories") and guiElement.name ~= "top") then
				guiElement.style.left_padding = 30
			end
			layer = layer + 1
		end
		for _, name in ipairs(guiElement.children_names) do
			setWidths(guiElement[name], layer)
		end
	end
end

function isCCGUIElement(guiElement)
	local flag = false
	while guiElement.parent do
		if guiElement.name == "CCMaster" then
			flag = true
		end
		guiElement = guiElement.parent
	end
	return flag
end

--Set all padding and maximum sizes
function CC_WINDOW_SETSTYLE(styleObject)
	styleObject.top_padding = CC_WINDOW_PADDING
	styleObject.right_padding = CC_WINDOW_PADDING
	styleObject.bottom_padding = CC_WINDOW_PADDING
	styleObject.left_padding = CC_WINDOW_PADDING
end

-- Create a new combinator reference with the given arguments
function generateCombinatorReference(name, entity, signalId, strength, mode, duration) {
	return {
				name = name                      -- A user-defined name for the combinator
				entity = entity,                 -- A reference to the actual combinator entity
				active = false,                  -- Is this combinator outputting a signal?
				output = {
					signalId = signalId          -- The type of the signal to output
					strength = strength          -- The value of the signal to output
					mode = mode                  -- The signal mode (toggle, duration)
					duration = duration          -- Only matters for DURATION mode. The duration of the signal
				}
			}
}