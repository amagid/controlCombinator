require "util"
require("config.constants")
require("helpers")
require("prototypes.style")

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
						active                    -- Is the combinator currently active
						gui                       -- A reference to the GUI element for this combinator
						output = {
							signalNum             -- The color number of the signal to output
							amount                -- The value of the signal to output
							type                  -- The signal mode (toggle, duration)
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

-- If the configuration has changed, destroy and re-create each player's CC GUI
script.on_configuration_changed(function()
	local gui
	for index, _ in pairs(global.ccdata) do
		if game.players[index] and game.players[index].gui then
			gui = game.players[index].gui
			if gui.center.CCMaster then
				gui.center.CCMaster.destroy()
			end
			if gui.top.CCToggle then
				gui.top.CCToggle.destroy()
			end
			if gui.center.CCNewCombinator then
				gui.center.CCNewCombinator.destroy()
			end
			if gui.center.CCViewCombinator then
				gui.center.CCViewCombinator.destroy()
			end
			createGUI(game.players[index])
		end
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

	if not global.ccdata[event.player_index] then
		-- Generate new base CCData entry
		global.ccdata[event.player_index] = CC_DEFAULT_PRIVATE_DATA()
	end
	createGUI(player)

	-- If the player's force has already researched the CC tech (or we're in DEBUG mode), create their CC GUI
	if player.force.technologies[CC_NAME].researched or DEBUG then
		activateGUI(player)
	end
end)

-- When a force researches the CC tech, generate CC GUIs for all players on that force
script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name == CC_NAME then
		for _, player in pairs(event.research.force.players) do
			if global.ccdata[player.index] == nil then
				global.ccdata[player.index] = CC_DEFAULT_PRIVATE_DATA()
			end
			if player and type(player) ~= "number" and type(player) ~= "function" and player.valid then
				createGUI(player)
				activateGUI(player)
			end
		end
	end
end)

-- Handle clicks of CC GUI elements
script.on_event(defines.events.on_gui_click, function(event)
	-- Store, element, and GUI container for faster access
	local player = game.players[event.player_index]
	local element = event.element
	local CCContainer = player.gui.center.CCMaster.CCContainer

	--If this is the master CC GUI toggle button and the GUI isn't visible
	if element.name == "CCToggle" and not CCContainer.style.visible then
		-- Hide the button
		element.style.visible = false
		--Hide central gui until fully loaded
		player.gui.center.CCMaster.style.visible = true
		CCContainer.container.style.visible = false
		CCContainer.top.caption = "Loading..."
		CCContainer.style.visible = true
		
		cleanBadCombinators(global.ccdata[event.player_index])
		--Clear the Edit Combinator Page
		CCContainer.editCombinatorContainer.style.visible = false
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)

		--If there are no combinators in data, show message
		if #global.ccdata[player.index].combinators == 0 then
			CCContainer.container.noCombinatorsMessage.style.visible = true
	
		--Otherwise, list out the combinators
		else
			CCContainer.container.noCombinatorsMessage.style.visible = false
		end

		CCContainer.top.caption = "Control Combinators"
		CCContainer.container.style.visible = true
	--If this is the master CC GUI toggle button and the GUI is visible
	elseif element.name == "CCToggle" then
		CCContainer.style.visible = false
		player.gui.center.CCMaster.style.visible = false

		CCContainer.editCombinatorContainer.style.visible = false
		--Clear the Edit Combinator Page
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)

		player.gui.top.CCToggle.style.visible = true
	--If this is the Combinator naming GUI
	elseif element.name == "CCNCButton" then
		local name = element.parent.CCNCField.text
		if name == nil or name == "" then
			name = "Unnamed Control Combinator (" .. math.random(9999) .. ")"
		end
		if not global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)] then
			return false
		end
		global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)].name = name
		addCombinator(CCContainer.container, global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)])
		element.parent.style.visible = false
		element.parent.CCNCField.text = ""
		element.parent.CCNCIndex.text = ""
	elseif element.name == "CCEditCombinator" then
		--Hide combinator list page
		CCContainer.container.style.visible = false

		--Get the combinator data entry
		local combinator = findCombinatorByName(global.ccdata[event.player_index].combinators, element.parent.parent.name)
		--Populate the combinator edit page fields
		CCContainer.editCombinatorContainer.editCombinatorName.text = combinator.name
		CCContainer.editCombinatorContainer.combinatorName.text = combinator.name
		CCContainer.editCombinatorContainer.editCombinatorDesc.text = combinator.description

		if combinator.output then
			if combinator.output.signalNum then
				setStyles(getSignalButton(combinator.output.signalNum, CCContainer.editCombinatorContainer.signalButtonRowContainer), {
					minimal_width = 60,
					minimal_height = 60,
					maximal_width = 60,
					maximal_height = 60
				})
			end
			
			CCContainer.editCombinatorContainer.CCSelectedSignal.text = combinator.output.signalNum
			CCContainer.editCombinatorContainer.editCombinatorAmount.text = combinator.output.amount
--[[
			CCContainer.editCombinatorContainer.typeButtonRow.CCToggleMode.state = (combinator.output.type == "toggle")
			CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state = (combinator.output.type == "duration")
--]]
		else
			combinator.output = {
				signalNum = 1,
				amount = 1,
				type = "toggle"
			}
			
			setStyles(CCContainer.editCombinatorContainer.signalButtonRowContainer.signalButtonRow["CCSignalButton" .. combinator.output.signalNum], {
				minimal_width = 60,
				minimal_height = 60,
				maximal_width = 60,
				maximal_height = 60
			})
		
			CCContainer.editCombinatorContainer.CCSelectedSignal.text = combinator.output.signalNum
			CCContainer.editCombinatorContainer.editCombinatorAmount.text = combinator.output.amount
--[[
			CCContainer.editCombinatorContainer.typeButtonRow.CCToggleMode.state = (combinator.output.type == "toggle")
			CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state = (combinator.output.type == "duration")
--]]
		end
		--Show combinator edit page
		CCContainer.editCombinatorContainer.style.visible = true
	elseif element.name == "editCombinatorSaveButton" then
		--Switch back to combinator list page
		CCContainer.container.style.visible = true
		CCContainer.editCombinatorContainer.style.visible = false
		local changedName = (CCContainer.editCombinatorContainer.combinatorName.text ~= CCContainer.editCombinatorContainer.editCombinatorName.text)
		--Update the GUI entry
		if changedName then
			CCContainer.container[CCContainer.editCombinatorContainer.combinatorName.text].destroy()
		end
		--Save the changes
		local combinator = findCombinatorByName(global.ccdata[event.player_index].combinators, CCContainer.editCombinatorContainer.combinatorName.text)

		local name = CCContainer.editCombinatorContainer.editCombinatorName.text
		if name == nil or name == "" then
			name = "Unnamed Control Combinator (" .. math.random(9999) .. ")"
		end
		combinator.name = name

		combinator.description = CCContainer.editCombinatorContainer.editCombinatorDesc.text
		
		local signalNum = tonumber(CCContainer.editCombinatorContainer.CCSelectedSignal.text)
		if signalNum == nil or signalNum < 0 then
			signalNum = 1
		end
		combinator.output.signalNum = signalNum

		local amount = tonumber(CCContainer.editCombinatorContainer.editCombinatorAmount.text)
		if amount == nil or amount < 1 then
			amount = 1
		end
		if amount > 1000000 then
			amount = 1000000
		end
		amount = math.floor(amount)
		combinator.output.amount = amount

--[[
		if CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state then
			combinator.output.type = "duration"
		else
			combinator.output.type = "toggle"
		end
--]]

		if changedName then
			addCombinator(CCContainer.container, combinator)
		end
		--Clear the Edit Combinator Page
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)
	elseif element.name == "editCombinatorCancelButton" then
		--Switch back to combinator list page
		CCContainer.container.style.visible = true
		CCContainer.editCombinatorContainer.style.visible = false
		--Clear the Edit Combinator Page
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)
	elseif element.name == "editCombinatorDestroyButton" then
		--Switch back to combinator list page
		CCContainer.container.style.visible = true
		CCContainer.editCombinatorContainer.style.visible = false
		--Destroy the combinator
		local combinator = findCombinatorByName(global.ccdata[event.player_index].combinators, CCContainer.editCombinatorContainer.combinatorName.text)
		if combinator.entity.valid then
			combinator.entity.force = "enemy"
			combinator.entity.die()
		end
		--Clear the Edit Combinator Page
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)
		--Clean the combinator list
		cleanBadCombinators(global.ccdata[event.player_index])

		--Check if we should show the 'no combinators' message
		if #global.ccdata[player.index].combinators == 0 then
			CCContainer.container.noCombinatorsMessage.style.visible = true
		else
			CCContainer.container.noCombinatorsMessage.style.visible = false
		end

	elseif string.find(element.name, "CCSignalButton") then
		--Deselect all of the buttons
		for i = 1, 10, 1 do
			setStyles(getSignalButton(i, element.parent.parent), {
				minimal_width = 40,
				minimal_height = 40,
				maximal_width = 40,
				maximal_height = 40
			})
		end
		--Select this button
		setStyles(element, {
			minimal_width = 60,
			minimal_height = 60,
			maximal_width = 60,
			maximal_height = 60
		})

		local num = string.sub(element.name, -1)
		if num == '0' then
			num = '10'
		end
		CCContainer.editCombinatorContainer.CCSelectedSignal.text = num
		

--[[
	elseif element.name == "CCToggleMode" or element.name == "CCDurationMode" then
		element.parent.CCToggleMode.state = false
		element.parent.CCDurationMode.state = false
		element.state = true
--]]
	elseif element.name == "CCCombinatorButton" then
		local combinator = findCombinatorByName(global.ccdata[event.player_index].combinators, element.parent.parent.name)
		if not combinator.entity.valid then
			return false
		end
		local inventory = combinator.entity.get_inventory(defines.inventory.chest)
		inventory.clear()
		if combinator.active then
			element.caption = "Activate"
			combinator.active = false
		else
			inventory.insert({
				name = CC_SIGNAL_NAME(combinator.output.signalNum),
				count = combinator.output.amount
			})
			element.caption = "Deactivate"
			combinator.active = true
		end
	end

end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	if event.entity.name == CC_NAME then
		event.entity.get_inventory(defines.inventory.chest).clear()
	end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	if event.entity.name == CC_NAME then
		event.entity.get_inventory(defines.inventory.chest).clear()
	end
end)

function createGUI(player)
	--If the GUI has already been created, don't create it again
	if player.gui.top.CCToggle ~= nil then
		return false
	end

	--CREATE TOGGLE BUTTON--

	setStyles(player.gui.top.add{type="button", name="CCToggle", caption="Control Combinator", tooltip="Toggle the Control Combinator menu."}, {
		visible = false
	})

	--CREATE MAIN GUI WINDOW--

	local CCMaster = player.gui.center.add{type="flow", name="CCMaster"}
	setStyles(CCMaster, {
		top_padding = 50,
		left_padding = 50,
		bottom_padding = 50,
		right_padding = 50,
		visible = false,
		maximal_height = 400,
		minimal_width = 300,
		maximal_width = 600
	})
	local CCContainer = CCMaster.add{type="frame", name="CCContainer", direction="vertical"}
	setStyles(CCContainer, {
		visible = false
	})
	setStyles(CCContainer.add{type="flow", name="top", direction="horizontal"}, {
	})
	CCContainer.top.add{type="button", name="CCToggle", caption="Close"}
	local CCCTLabel = CCContainer.top.add{type="label", caption="Control Combinators"}
	setStyles(CCCTLabel, {
		font = "default-large-bold",
		top_padding = CC_LABEL_PADDING
	})
	local container = CCContainer.add{type="scroll-pane", name="container", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical"}
	setStyles(container, {
		visible = false
	})
	
	setStyles(container.add{type="label", name="noCombinatorsMessage", caption="You have no combinators yet. Build a combinator, and it will show up here."}, {
		single_line = false
	})

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
	addLabelPadding(player.gui.center.CCMaster)

	--Force all boxes to be full width
	--setWidths(player.gui.center.CCMaster, 0)

	--CREATE EDIT COMBINATOR PAGE--

	local editCombinatorContainer = CCContainer.add{type="scroll-pane", name="editCombinatorContainer", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical", caption="Edit Combinator"}

	setStyles(editCombinatorContainer, {
		visible = false
	})

	setStyles(editCombinatorContainer.add{type="label", caption="Combinator Name"}, {
		top_padding = 30,
		font = "default-large-bold",
		single_line = false
	})
	setStyles(editCombinatorContainer.add{type="textfield", name="editCombinatorName", tooltip="FYI: Editing the Control Combinator's name will move the Combinator's entry to the bottom of your list"}, {
		horizontally_stretchable = true,
		minimal_width = 200
	})
	setStyles(editCombinatorContainer.add{type="label", caption="Combinator Description"}, {
		top_padding = 30,
		font = "default-large-bold",
		single_line = false
	})
	setStyles(editCombinatorContainer.add{type="text-box", word_wrap=true, name="editCombinatorDesc"}, {
		height = 100,
		horizontally_stretchable = true,
		minimal_width = 200
	})
	setStyles(editCombinatorContainer.add{type="textfield", name="combinatorName"}, {
		visible = false
	})

	setStyles(editCombinatorContainer.add{type="label", caption="Output Signal"}, {
		top_padding = 30,
		font = "default-large-bold",
		single_line = false
	})

	setStyles(editCombinatorContainer.add{type="textfield", name="CCSelectedSignal"}, {
		visible = false
	})

	local signalButtonRowContainer = editCombinatorContainer.add{type="flow", direction="vertical", name="signalButtonRowContainer"}

	local signalButtonRow1 = signalButtonRowContainer.add{type="flow", direction="horizontal", name="signalButtonRow1"}
	local signalButtonRow2 = signalButtonRowContainer.add{type="flow", direction="horizontal", name="signalButtonRow2"}

	for i=1, 5, 1 do
		setStyles(signalButtonRow1.add{type="sprite-button", name="CCSignalButton" .. i, sprite="item/" .. CC_SIGNAL_NAME(i)}, {
			minimal_width = 40,
			minimal_height = 40,
			maximal_width = 40,
			maximal_height = 40
		})
	end
	for i=6, 10, 1 do
		setStyles(signalButtonRow2.add{type="sprite-button", name="CCSignalButton" .. i, sprite="item/" .. CC_SIGNAL_NAME(i)}, {
			minimal_width = 40,
			minimal_height = 40,
			maximal_width = 40,
			maximal_height = 40
		})
	end

	setStyles(editCombinatorContainer.add{type="label", caption="Signal Amount"}, {
		top_padding = 30,
		font = "default-large-bold",
		single_line = false
	})
	setStyles(editCombinatorContainer.add{type="textfield", name="editCombinatorAmount"}, {
		horizontally_stretchable = true,
		minimal_width = 200
	})

	setStyles(editCombinatorContainer.add{type="flow", direction="horizontal"}, {
		minimal_height = 30,
		maximal_height = 30
	})

--[[
	setStyles(editCombinatorContainer.add{type="label", caption="Signal Mode"}, {
		top_padding = 30,
		font = "default-large-bold",
		single_line = false
	})

	local typeButtonRow = editCombinatorContainer.add{type="flow", direction="horizontal", name="typeButtonRow"}

	typeButtonRow.add{type="radiobutton", state=true, name="CCToggleMode", caption="Toggle Mode", tooltip="When in this mode, a Control Combinator will stay active until deactivated by the player through the GUI."}
	typeButtonRow.add{type="radiobutton", state=false, name="CCDurationMode", caption="Duration Mode", tooltip="When in this mode, a Control Combinator will activate for a single tick of the game and then immediately deactivate."}
--]]
	local ECCButtonRow = editCombinatorContainer.add{type="flow", direction="horizontal"}
	ECCButtonRow.add{type="button", name="editCombinatorSaveButton", caption="Save Changes"}
	ECCButtonRow.add{type="button", name="editCombinatorCancelButton", caption="Discard Changes"}
	ECCButtonRow.add{type="button", name="editCombinatorDestroyButton", caption="Destroy Combinator"}

	--CREATE NEW COMBINATOR GUI--
	player.gui.center.add{type="frame", name="CCNewCombinator", caption="Name this Control Combinator"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCIndex"}.style.visible = false
	player.gui.center.CCNewCombinator.add{type="textfield", name="CCNCField"}
	player.gui.center.CCNewCombinator.add{type="button", name="CCNCButton", caption="Set Name"}

	--CREATE VIEW COMBINATOR GUI--
	player.gui.center.add{type="frame", name="CCViewCombinator"}.style.visible = false
	setStyles(player.gui.center.CCViewCombinator.add{type="label", caption="", name="CCVCName"}, {
		font = "default-large-bold",
		top_padding = CC_LABEL_PADDING
	})

end

function activateGUI(player)
	setStyles(player.gui.top.CCToggle, { visible = true })
end

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == CC_NAME then
		event.created_entity.operable = false
		local newCombinator = generateCombinatorReference("Unnamed Control Combinator (" .. math.random(9999) .. ")", event.created_entity)
		table.insert(global.ccdata[event.player_index].combinators, newCombinator)
		if game.players[event.player_index].gui.center.CCNewCombinator.style.visible then
			addCombinator(game.players[event.player_index].gui.center.CCMaster.CCContainer.container, newCombinator)
		else
			game.players[event.player_index].gui.center.CCNewCombinator.CCNCIndex.text = #global.ccdata[event.player_index].combinators
			game.players[event.player_index].gui.center.CCNewCombinator.style.visible = true
		end
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.name == CC_NAME then

		event.created_entity.operable = false

		-- There are certain cases where it is not possible to determine the Player
		-- based on the robot and entity data alone. Unfortunately, this would present a
		-- problem in configuring the Control Combinator. Therefore, if this data
		-- is not known at build time, the Combinator's deconstruction is ordered.
		local lastUser = nil
		if event.created_entity.last_user ~= nil then
			lastUser = event.created_entity.last_user.index
		elseif event.robot.last_user ~= nil then
			lastUser = event.robot.last_user.index
		end

		if lastUser == nil then
			event.created_entity.order_deconstruction(event.robot.force)
		else
			local name = "Unnamed Control Combinator (" .. math.random(9999) .. ")"
			local newCombinator = generateCombinatorReference(name, event.created_entity)
			table.insert(global.ccdata[lastUser].combinators, newCombinator)
			addCombinator(game.players[lastUser].gui.center.CCMaster.CCContainer.container, newCombinator)
		end
	end
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	local entity = game.players[event.player_index].selected
	if entity and entity.name == CC_NAME and entity.last_user and entity.last_user.index == event.player_index and global.ccdata[event.player_index] and global.ccdata[event.player_index].combinators and game.players[event.player_index] and game.players[event.player_index].gui and game.players[event.player_index].gui.center.CCMaster and game.players[event.player_index].gui.center.CCMaster.CCContainer and game.players[event.player_index].gui.center.CCMaster.CCContainer.style.visible == false and game.players[event.player_index].gui.center.CCNewCombinator and game.players[event.player_index].gui.center.CCNewCombinator.style.visible == false and game.players[event.player_index].gui.center.CCViewCombinator and game.players[event.player_index].gui.center.CCViewCombinator.style.visible == false then
		for _, combinator in ipairs(global.ccdata[event.player_index].combinators) do
			if combinator.entity == entity then
				game.players[event.player_index].gui.center.CCViewCombinator.CCVCName.caption = "Control Combinator: " .. combinator.name
				game.players[event.player_index].gui.center.CCViewCombinator.style.visible = true
				return true
			end
		end
		return false
	elseif game.players[event.player_index].gui.center.CCViewCombinator then
		game.players[event.player_index].gui.center.CCViewCombinator.style.visible = false
	end
end)