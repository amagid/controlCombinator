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
			layer = layer + 1
		end
		for _, name in ipairs(guiElement.children_names) do
			setWidths(guiElement[name], layer)
		end
	end
end

--Set all padding and maximum sizes
function CC_WINDOW_SETSTYLE(styleObject)
	styleObject.top_padding = CC_WINDOW_PADDING
	styleObject.right_padding = CC_WINDOW_PADDING
	styleObject.bottom_padding = CC_WINDOW_PADDING
	styleObject.left_padding = CC_WINDOW_PADDING
end

-- Create a new combinator reference with the given arguments
function generateCombinatorReference(name, entity)
	return {
				name = name,                     -- A user-defined name for the combinator
				entity = entity,                 -- A reference to the actual combinator entity
				gui = nil,                       -- A reference to the gui element representing this combinator
				active = false,                  -- Is this combinator outputting a signal?
				output = nil
			}
end

function addCombinator(container, combinator)
	local guiReference = container.add{type="frame", name=combinator.name, direction="vertical"}
	setStyles(guiReference, {
		minimal_width = CC_WINDOW_WIDTH,
		maximal_width = CC_WINDOW_WIDTH
	})
	setStyles(guiReference.add{type="label", caption=combinator.name}, {
		top_padding = 25,
		font = "default-large-bold"
	})
	local buttonRow = guiReference.add{type="flow", name="buttonRow", direction="horizontal"}
	setStyles(buttonRow, {
		minimal_width = CC_WINDOW_WIDTH,
		maximal_width = CC_WINDOW_WIDTH
	})
	buttonRow.add{type="button", name="CCEditCombinator", caption="Edit"}
	buttonRow.add{type="button", name="CCCombinatorButton", caption="Activate"}
	
	combinator.gui = guiReference
end

function cleanBadCombinators(playerCCData)
	local newList = {}
	for _, combinator in pairs(playerCCData.combinators) do
		if combinator.entity.valid then
			table.insert(newList, combinator)
		elseif combinator.gui ~= nil then
			combinator.gui.style.visible = false
		end
	end
	playerCCData.combinators = newList
end

function clearEditCombinatorPage(page)
	page.editCombinatorName.text = ""
	page.editCombinatorDesc.text = ""
end