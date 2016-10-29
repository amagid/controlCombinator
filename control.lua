require "util"
require("config.constants")
require("helpers")

script.on_init(function()
	--[[
		Table to store all control combinator data, indexed by owning player for private CCs or force name for public CCs.
		Data format:
		{
			combinators = {
				{
					name = "",
					entity = *Control Combinator Entity Reference*,
					outputs = {
						owner = "",          -- Player index or force name
						category = "",       -- Category index
						signal = "",         -- Signal index
						output = "",         -- Output index
					}
				}
			},
			categories = {
				{
					name = "",
					signals = {
						{
							name = "",
							outputs = {
								{
									color = "",        --color is green or red (wire colors)
									line = "",         --line is the output signal type (water, crude oil, virtual circuit 1...)
									value = "",        --the output value
									type = "",         --type is "pulse", "duration", "toggle" or "circuit"
									combinator = int,  --combinator is the index of the combinator in the above array
									active = boolean   --is this output currently active?
								}
							}
						}
					}
				}
			}
		}
	--]]
	if not global.ccdata then
		global.ccdata = {}
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	if not global.ccdata then
		global.ccdata = {}
	end

	local player = game.players[event.player_index]

	global.ccdata[event.player_index] = CC_DEFAULT_PRIVATE_DATA

	if not global.ccdata[player.force.name] then
		global.ccdata[player.force.name] = CC_DEFAULT_PUBLIC_DATA
	end

	if player.force.technologies[CC_NAME].researched or DEBUG then
		createGUI(player)
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name == CC_NAME then
		for player in pairs(event.research.force.players) do
			if player and type(player) ~= "number" and type(player) ~= "function" and player.valid then
				createGUI(player)
			end
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	local element = event.element
	local CCContainer = player.gui.top.CCMaster.CCContainer
	if element.name == "CCToggle" and not CCContainer.style.visible then
		local CCContainer = player.gui.top.CCMaster.CCContainer
		element.style.visible = false
		--Hide central gui until fully loaded
		player.gui.top.CCMaster.style.visible = true
		CCContainer.container.style.visible = false
		CCContainer.top.caption = "Loading..."
		CCContainer.style.visible = true

		--If there are no categories in data, show message
		if #global.ccdata[event.player_index].categories == 0 then
			CCContainer.container.privateCategories.noCategoriesMessage.style.visible = true

		else
			CCContainer.container.privateCategories.noCategoriesMessage.style.visible = false
			for _, category in ipairs(global.ccdata[event.player_index].categories) do
				addCategory(CCContainer.container.privateCategories, category)
			end
		end

		if #global.ccdata[player.force.name].categories == 0 then
			CCContainer.container.publicCategories.noCategoriesMessage.style.visible = true
		else
			CCContainer.container.publicCategories.noCategoriesMessage.style.visible = false
			for _, category in ipairs(global.ccdata[event.player_index].categories) do
				addCategory(CCContainer.container.publicCategories, category)
			end
		end

		addLabelPadding(player.gui.top.CCMaster)
		setWidths(player.gui.top.CCMaster, 0)

		CCContainer.top.caption = "Control Combinators"
		CCContainer.container.style.visible = true
	elseif element.name == "CCToggle" then
		CCContainer.style.visible = false
		player.gui.top.CCMaster.style.visible = false
		player.gui.top.CCToggle.style.visible = true
	elseif element.name == "CCNCButton" then
		global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)].name = element.parent.CCNCField.text
		element.parent.style.visible = false
		element.parent.CCNCField.text = ""
		element.parent.CCNCIndex.text = ""
	end
end)

function createGUI(player)
	player.gui.top.add{type="button", name="CCToggle", caption="Control Combinator", tooltip="Toggle the Control Combinator menu."}
	local CCMaster = player.gui.top.add{type="flow", name="CCMaster"}
	setStyles(CCMaster, {
		top_padding = 100,
		left_padding = 100,
		minimal_width = CC_WINDOW_WIDTH,
		maximal_width = CC_WINDOW_WIDTH,
		visible = false
	})
	local CCContainer = CCMaster.add{type="frame", name="CCContainer", direction="vertical"}
	setStyles(CCContainer, {
		minimal_width = CC_WINDOW_WIDTH - 100,
		maximal_width = CC_WINDOW_WIDTH - 100
	})
	setStyles(CCContainer.add{type="flow", name="top", direction="horizontal"}, {
		minimal_width = CC_WINDOW_WIDTH,
		maximal_width = CC_WINDOW_WIDTH
	})
	CCContainer.top.add{type="button", name="CCToggle", caption="Close"}
	local CCCTLabel = CCContainer.top.add{type="label", caption="Control Combinators"}
	setStyles(CCCTLabel, {
		font = "default-large-bold",
		top_padding = CC_LABEL_PADDING
	})
	CCContainer.top.add{type="button", name="addCategory", caption="Add Category"}
	CCContainer.top.add{type="button", name="addSignal", caption="Add Signal"}
	local container = CCContainer.add{type="scroll-pane", name="container", vertical_scroll_policy="always", horizontal_scroll_policy="never", direction="vertical"}
	setStyles(container, {
		visible = false,
		minimal_height = CC_WINDOW_HEIGHT,
		maximal_height = CC_WINDOW_HEIGHT
	})
	container.add{type="flow", name="privateCategories", direction="vertical"}
	setStyles(container.privateCategories.add{type="label", caption="Available only to you"}, {
		font = "default-large-bold",
		top_padding = 30,
		bottom_padding = 10
	})
	container.privateCategories.add{type="label", name="noCategoriesMessage", caption="You have no private categories."}
	container.add{type="flow", name="publicCategories", direction="vertical"}
	setStyles(container.publicCategories.add{type="label", caption="Available to your force"}, {
		font = "default-large-bold",
		top_padding = 30,
		bottom_padding = 10
	})
	container.publicCategories.add{type="label", name="noCategoriesMessage", caption="You have no private categories."}

	--CREATE COMBINATOR LABEL GUI--

	player.gui.center.add{type="frame", name="CCNewCombinator", caption="Name this Control Combinator"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCIndex"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCField"}
	player.gui.center.CCNewCombinator.add{type="button", name="CCNCButton", caption="Set Name"}

end

function addCategory(container, category)
	local categoryActive = false
	local categoryFrame = container.add{type="frame", name=category.name, direction="vertical"}
	categoryFrame.add{type="flow", name="top", direction="horizontal"}
	categoryFrame.top.add{type="label", name="categoryLabel", caption=category.name}.style.font = "default-large-bold"
	for _, signal in ipairs(category.signals) do
		for _, output in ipairs(signal.outputs) do
			if output.active then
				categoryActive = true
			end
		end
	end
	if categoryActive then
		categoryFrame.top.add{type="button", name="toggle", caption="Deactivate All"}
		categoryFrame.top.categoryLabel.style.font_color = {r=0, g=1, b=0}
	else
		categoryFrame.top.add{type="button", name="toggle", caption="Activate All"}
		categoryFrame.top.categoryLabel.style.font_color = {r=1, g=1, b=1}
	end
	categoryFrame.top.add{type="button", name="add", caption="Add Signal"}
	categoryFrame.top.add{type="button", name="delete", caption="Delete"}
	
	categoryFrame.add{type="label", name="noSignalsMessage", caption="This category has no signals."}

	if #category.signals == 0 then
		categoryFrame.noSignalsMessage.style.visible = true
	else
		categoryFrame.noSignalsMessage.style.visible = false
		for _, signal in ipairs(category.signals) do
			local signalActive = false
			local signalFrame = categoryFrame.add{type="frame", name=signal.name, caption=signal.name, direction="horizontal"}
			for _, output in ipairs(signal.outputs) do
				if output.active then
					signalActive = true
				end
			end
			if signalActive then
				signalFrame.style.font_color = {r=0, g=1, b=0}
				signalFrame.add{type="button", name="toggle", caption="Deactivate"}
			else
				signalFrame.style.font_color = {r=1, g=1, b=1}
				signalFrame.add{type="button", name="toggle", caption="Activate"}
			end
			signalFrame.add{type="button", name="more", caption="More"}
			signalFrame.add{type="button", name="delete", caption="Delete"}
		end
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	event.created_entity.operable = false
	game.players[event.player_index].gui.center.CCNewCombinator.style.visible = true
	table.insert(global.ccdata[event.player_index].combinators, {
		name = nil,
		entity = event.created_entity,
		outputs = {}
	})
	game.players[event.player_index].gui.center.CCNewCombinator.CCNCIndex.text = #global.ccdata[event.player_index].combinators
end)
