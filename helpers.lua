--[[
function setStyles(styleObject, newStyleTable)
	for k, v in pairs(newStyleTable) do
		styleObject.style[k] = v
	end
end
--]]