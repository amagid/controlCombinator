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
					name = ""
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
					description = "",
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
	--If this is a toggle button and the GUI isn't visible
	if element.name == "CCToggle" and not CCContainer.style.visible then
		local CCContainer = player.gui.top.CCMaster.CCContainer
		element.style.visible = false
		--Hide central gui until fully loaded
		player.gui.top.CCMaster.style.visible = true
		CCContainer.container.style.visible = false
		CCContainer.top.caption = "Loading..."
		CCContainer.style.visible = true

		CCContainer.top.caption = "Control Combinators"
		CCContainer.container.style.visible = true
	--If this is a toggle button and the GUI is visible
	elseif element.name == "CCToggle" then
		CCContainer.style.visible = false
		player.gui.top.CCMaster.style.visible = false
		player.gui.top.CCToggle.style.visible = true
	--If this is the Combinator naming GUI
	elseif element.name == "CCNCButton" and isCCGUIElement(element) then
		global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)].name = element.parent.CCNCField.text
		element.parent.style.visible = false
		element.parent.CCNCField.text = ""
		element.parent.CCNCIndex.text = ""
	--If this is the addCategory button
	elseif element.name == "addCategory" and isCCGUIElement(element) then
		if CCContainer.addCategoryContainer.style.visible then
			CCContainer.top.addCategory.caption = "Add Category"
		else
			CCContainer.top.addCategory.caption = "Back"
		end
		CCContainer.addCategoryContainer.style.visible = not CCContainer.addCategoryContainer.style.visible
		CCContainer.container.style.visible = not CCContainer.addCategoryContainer.style.visible
	--If this is the New Category button
	elseif element.name == "newCategoryButton" and isCCGUIElement(element) then

		--Add the new category to the appropriate ccdata entry

		if CCContainer.addCategoryContainer.newCategoryPublic.state then

			--Format data
			local newCategory = {
				name = CCContainer.addCategoryContainer.newCategoryName.text,
				description = CCContainer.addCategoryContainer.newCategoryDesc.text,
				signals = {}
			}

			--Add new category to global data
			table.insert(global.ccdata[player.force.name].categories, newCategory)

			--Add new category to all GUIs in force
			for _, p in ipairs(player.force.players) do
				addCategory(p.gui.top.CCMaster.CCContainer.container.publicCategories, newCategory)
			end
		else

			--Format data
			local newCategory = {
				name = CCContainer.addCategoryContainer.newCategoryName.text,
				description = CCContainer.addCategoryContainer.newCategoryDesc.text,
				signals = {}
			}

			--Add new category to global data
			table.insert(global.ccdata[player.index].categories, newCategory)

			--Add new category to only this player's GUI
			addCategory(CCContainer.container.privateCategories, newCategory)
		end

		--Go back to main GUI page

		if CCContainer.addCategoryContainer.style.visible then
			CCContainer.top.addCategory.caption = "Add Category"
		else
			CCContainer.top.addCategory.caption = "Back"
		end
		CCContainer.addCategoryContainer.style.visible = not CCContainer.addCategoryContainer.style.visible
		CCContainer.container.style.visible = not CCContainer.addCategoryContainer.style.visible

		--Clear form

		CCContainer.addCategoryContainer.newCategoryName.text = ""
		CCContainer.addCategoryContainer.newCategoryDesc.text = ""
		CCContainer.addCategoryContainer.newCategoryPublic.state = false

	--If this is the Delete category button
	--If this is the More 
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
	CCContainer.top.add{type="button", name="addCategory", caption="Add Category"}
	CCContainer.top.add{type="button", name="addSignal", caption="Add Signal"}
	local container = CCContainer.add{type="scroll-pane", name="container", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical"}
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

	--POPULATE MAIN GUI WINDOW--

	--If there are no categories in data, show message
	if #global.ccdata[player.index].categories == 0 then
		CCContainer.container.privateCategories.noCategoriesMessage.style.visible = true

	--Otherwise, list out the categories
	else
		CCContainer.container.privateCategories.noCategoriesMessage.style.visible = false
		for _, category in ipairs(global.ccdata[player.index].categories) do
			addCategory(CCContainer.container.privateCategories, category)
		end
	end

	--If there are no Force categories, show message
	if #global.ccdata[player.force.name].categories == 0 then
		CCContainer.container.publicCategories.noCategoriesMessage.style.visible = true
	--Otherwise, list out the categories
	else
		CCContainer.container.publicCategories.noCategoriesMessage.style.visible = false
		for _, category in ipairs(global.ccdata[player.index].categories) do
			addCategory(CCContainer.container.publicCategories, category)
		end
	end

	--Add padding to the top of every existing label that is next to buttons
	addLabelPadding(player.gui.top.CCMaster)

	--Force all boxes to be full width
	setWidths(player.gui.top.CCMaster, 0)


	--CREATE ADD CATEGORY PAGE--
	
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

	--CREATE CONFIRM DELETE CATEGORY BOX--



	--CREATE ADD SIGNAL PAGE--
	


	--CREATE EDIT SIGNAL PAGE--



	--CREATE CONFIRM DELETE SIGNAL BOX--

	

	--CREATE NEW COMBINATOR GUI--

	player.gui.center.add{type="frame", name="CCNewCombinator", caption="Name this Control Combinator"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCIndex"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCField"}
	player.gui.center.CCNewCombinator.add{type="button", name="CCNCButton", caption="Set Name"}

end

function addCategory(container, category)
	local categoryActive = false
	local categoryFrame = container.add{type="frame", name=category.name, direction="vertical", tooltip=category.description}
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
	categoryFrame.top.add{type="button", name="edit", caption="Edit Category"}
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
