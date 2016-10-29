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
