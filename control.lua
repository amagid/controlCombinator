require "util"
require("config.constants")
require("helpers")

script.on_init(function()
	--[[
		Table to store all control combinator data, indexed by owning player for private CCs or force name for public CCs.
		Data format:
		{
			<PLAYER ID> = {
				combinators = {
					{
						name = ""
						entity = *Control Combinator Entity Reference*,
						output = {
							signal_id             -- The type of the signal to output
							strength              -- The value of the signal to output
							mode                  -- The signal mode (toggle, duration)
							duration              -- Only matters for DURATION mode. The duration of the signal
						}
					}
				}
			},
		}
	--]]
	-- Make sure our data storage is initialized, but don't reinitialize if a new player is entering
	if not global.ccdata then
		global.ccdata = {}
	end
end)

-- Initialize the new player's Control Combinator list
script.on_event(defines.events.on_player_created, function(event)
	-- Initialize global CCData if not yet initialized
	if not global.ccdata then
		global.ccdata = {}
	end

	-- Store the player to improve efficiency
	local player = game.players[event.player_index]

	-- Generate new base CCData entry
	global.ccdata[event.player_index] = CC_DEFAULT_PRIVATE_DATA

	-- If the player's force has already researched the CC tech (or we're in DEBUG mode), create their CC GUI
	if player.force.technologies[CC_NAME].researched or DEBUG then
		createGUI(player)
	end
end)

-- When a force researches the CC tech, generate CC GUIs for all players on that force
script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name == CC_NAME then
		for player in pairs(event.research.force.players) do
			if player and type(player) ~= "number" and type(player) ~= "function" and player.valid then
				createGUI(player)
			end
		end
	end
end)

-- Handle clicks of CC GUI elements
script.on_event(defines.events.on_gui_click, function(event)
	-- Store, element, and GUI container for faster access
	local player = game.players[event.player_index]
	local element = event.element
	local CCContainer = player.gui.top.CCMaster.CCContainer

	--If this is the master CC GUI toggle button and the GUI isn't visible
	if element.name == "CCToggle" and not CCContainer.style.visible then
		local CCContainer = player.gui.top.CCMaster.CCContainer
		-- Hide the button
		element.style.visible = false
		--Hide central gui until fully loaded
		player.gui.top.CCMaster.style.visible = true
		CCContainer.container.style.visible = false
		CCContainer.top.caption = "Loading..."
		CCContainer.style.visible = true

		CCContainer.top.caption = "Control Combinators"
		CCContainer.container.style.visible = true
	--If this is the master CC GUI toggle button and the GUI is visible
	elseif element.name == "CCToggle" then
		CCContainer.style.visible = false
		player.gui.top.CCMaster.style.visible = false
		player.gui.top.CCToggle.style.visible = true
	--If this is the Combinator naming GUI
	elseif element.name == "CCNCButton" then
		global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)].name = element.parent.CCNCField.text
		element.parent.style.visible = false
		element.parent.CCNCField.text = ""
		element.parent.CCNCIndex.text = ""
	end
end)

function createGUI(player)

	--CREATE TOGGLE BUTTON--

	player.gui.top.add{type="button", name="CCToggle", caption="Control Combinator", tooltip="Toggle the Control Combinator menu."}

	--CREATE MAIN GUI WINDOW--

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
		minimal_width = CC_WINDOW_WIDTH - 110,
		maximal_width = CC_WINDOW_WIDTH - 110
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
	local container = CCContainer.add{type="scroll-pane", name="container", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical"}
	setStyles(container, {
		visible = false,
		minimal_height = CC_WINDOW_HEIGHT,
		maximal_height = CC_WINDOW_HEIGHT
	})
	
	container.add{type="label", name="noCombinatorsMessage", caption="You have no combinators yet. Build a combinator, and it will show up here."}

	--POPULATE MAIN GUI WINDOW--

	--If there are no combinators in data, show message
	if #global.ccdata[player.index].combinators == 0 then
		CCContainer.container.noCombinatorsMessage.style.visible = true

	--Otherwise, list out the combinators
	else
		CCContainer.container.noCombinatorsMessage.style.visible = false
		for _, combinator in ipairs(global.ccdata[player.index].combinators) do
			addCombinator(CCContainer.container, combinator)
		end
	end

	--Add padding to the top of every existing label that is next to buttons
	addLabelPadding(player.gui.top.CCMaster)

	--Force all boxes to be full width
	setWidths(player.gui.top.CCMaster, 0)


	--CREATE ADD CATEGORY PAGE--
[[--	
	local addCategoryContainer = CCContainer.add{type="scroll-pane", name="addCategoryContainer", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical", caption="Add New Category"}
	setStyles(addCategoryContainer, {
		visible = false,
		minimal_height = CC_WINDOW_HEIGHT,
		maximal_height = CC_WINDOW_HEIGHT
	})
	setStyles(addCategoryContainer.add{type="label", caption="Category name"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	addCategoryContainer.add{type="textfield", name="newCategoryName"}
	setStyles(addCategoryContainer.add{type="label", caption="Category description"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	setStyles(addCategoryContainer.add{type="textfield", name="newCategoryDesc"}, {
		minimal_width=400,
		maximal_width=400
	})
	setStyles(addCategoryContainer.add{type="checkbox", name="newCategoryPublic", state=false, caption="Make Category public", tooltip="Checking this box will open your Category to everyone in your Force. Any of them will be able to use, edit or delete this Category. It will also be listed in the main menu under \"Available to your force\" instead of \"Available only to you\"."}, {
		top_padding = 30,
		bottom_padding = 30
	})
	addCategoryContainer.add{type="button", name="newCategoryButton", caption="Create Category"}
	
	--CREATE EDIT CATEGORY PAGE--

	local editCategoryContainer = CCContainer.add{type="scroll-pane", name="editCategoryContainer", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical", caption="Edit Category"}

	setStyles(editCategoryContainer, {
		visible = false,
		minimal_height = CC_WINDOW_HEIGHT,
		maximal_height = CC_WINDOW_HEIGHT
	})

	setStyles(editCategoryContainer.add{type="label", caption="Category name"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	editCategoryContainer.add{type="textfield", name="editCategoryName"}
	setStyles(editCategoryContainer.add{type="label", caption="Category description"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	setStyles(editCategoryContainer.add{type="textfield", name="editCategoryDesc"}, {
		minimal_width=400,
		maximal_width=400
	})
	setStyles(editCategoryContainer.add{type="checkbox", name="editCategoryPublic", state=false, caption="Make Category public", tooltip="Checking this box will open your Category to everyone in your Force. Any of them will be able to use, edit or delete this Category. It will also be listed in the main menu under \"Available to your force\" instead of \"Available only to you\"."}, {
		top_padding = 30,
		bottom_padding = 30
	})

	local ECCButtonRow = editCategoryContainer.add{type="flow", direction="horizontal"}
	ECCButtonRow.add{type="button", name="editCategorySaveButton", caption="Save Changes"}
	ECCButtonRow.add{type="button", name="editCategoryCancelButton", caption="Discard Changes"}
	ECCButtonRow.add{type="button", name="editCategoryDeleteButton", caption="Delete Category"}
--]]

	--CREATE EDIT COMBINATOR OUTPUT GUI

	--CREATE NEW COMBINATOR GUI--

	player.gui.center.add{type="frame", name="CCNewCombinator", caption="Name this Control Combinator"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCIndex"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCField"}
	player.gui.center.CCNewCombinator.add{type="button", name="CCNCButton", caption="Set Name"}

end

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == CC_NAME then
		event.created_entity.operable = false
		game.players[event.player_index].gui.center.CCNewCombinator.style.visible = true
		table.insert(global.ccdata[event.player_index].combinators, {
			name = nil,
			entity = event.created_entity,
			outputs = {}
		})
		game.players[event.player_index].gui.center.CCNewCombinator.CCNCIndex.text = #global.ccdata[event.player_index].combinators
	end
end)
