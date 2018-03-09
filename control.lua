require "util"
require("config.constants")
require("helpers")
require("prototypes.style")
require("queue-utils")

--[[

FOR DURATION MODE:

Best idea I can think of for efficient implementation follows:

1) Maintain a global linked list of combinators that are currently active and in "duration" mode. This list will include combinators for all players.
2) When a combinator in "duration" mode is activated, place it in the list in order of deactivation time so the list is always sorted.
3) Set the combinator's "additional time" with the number of ticks it should wait to deactivate after the one before it deactivates.
4) Each tick, decrement a tick counter.
5) When the counter reaches zero, pop the first combinator off of the list, deactivate it, and set the tick counter equal to the
   "additional time" of the next combinator in the list.
6) This setup lends itself easily to "pulse" mode, the only needed change is to put combinators back into the list immediately after popping them
   and store a boolean saying whether the next action is to activate or deactivate them. You'll also definitely need to check,
   when popping combinators from the list, whether the next one should also be popped in this tick since it's possible that some may coincide.

]]

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
		global.ccdata = {
			durationQueue = createQueue()
		}
	end
end)

-- Initialize the new player's Control Combinator list
script.on_event(defines.events.on_player_created, function(event)
	-- Initialize global CCData if not yet initialized
	if not global.ccdata then
		global.ccdata = {
			durationQueue = createQueue()
		}
	end

	-- Store the player to improve efficiency
	local player = game.players[event.player_index]

	-- Generate new base CCData entry
	global.ccdata[event.player_index] = CC_DEFAULT_PRIVATE_DATA()

	-- If the player's force has already researched the CC tech (or we're in DEBUG mode), create their CC GUI
	if player.force.technologies[CC_NAME].researched or DEBUG then
		createGUI(player)
	end
end)

script.on_tick(function(event)
	--If the popCounter has not yet reached 0
	if global.ccdata.durationQueue.popCounter > 0 then
		--Decrement the popCounter
		global.ccdata.durationQueue.popCounter = global.ccdata.durationQueue.popCounter - 1
	elseif global.ccdata.durationQueue.length > 0 then
		deactivateCombinator(popCombinatorFromQueue(global.ccdata.durationQueue))
		activateCombinator(peekAtQueue(global.ccdata.durationQueue))
	end
end)

function deactivateCombinator(combinator)
	combinator.active = false
	combinator.entity.get_inventory(defines.inventory.chest).clear()
	combinator.gui.buttonRow.CCCombinatorButton.caption = "Activate"
end

function activateCombinator(combinator)
	if combinator ~= nil then
		combinator.active = true
		combinator.entity.get_inventory(defines.inventory.chest).clear()
		combinator.entity.get_inventory(defines.inventory.chest).insert({
			name = CC_SIGNAL_NAME(combinator.output.signalNum),
			count = combinator.output.amount
		})
		combinator.gui.buttonRow.CCCombinatorButton.caption = "Deactivate"
	end
end

-- When a force researches the CC tech, generate CC GUIs for all players on that force
script.on_event(defines.events.on_research_finished, function(event)
	game.players[1].print("Researched a tech: " .. event.research.name)
	if event.research.name == CC_NAME then
		game.players[1].print("It's our tech!")
		for _, player in pairs(event.research.force.players) do
			if global.ccdata[player.index] == nil then
				global.ccdata[player.index] = CC_DEFAULT_PRIVATE_DATA()
			end
			game.players[1].print("Player")
			if player and type(player) ~= "number" and type(player) ~= "function" and player.valid then
				game.players[1].print("Creating GUI")
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
		-- Hide the button
		element.style.visible = false
		--Hide central gui until fully loaded
		player.gui.top.CCMaster.style.visible = true
		CCContainer.container.style.visible = false
		CCContainer.top.caption = "Loading..."
		CCContainer.style.visible = true
		
		cleanBadCombinators(global.ccdata[event.player_index])

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
		player.gui.top.CCMaster.style.visible = false
		player.gui.top.CCToggle.style.visible = true
	--If this is the Combinator naming GUI
	elseif element.name == "CCNCButton" then
		global.ccdata[event.player_index].combinators[tonumber(element.parent.CCNCIndex.text)].name = element.parent.CCNCField.text
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
				setStyles(CCContainer.editCombinatorContainer.signalButtonRow["CCSignalButton" .. combinator.output.signalNum], {
					minimal_width = 80,
					minimal_height = 80,
					maximal_width = 80,
					maximal_height = 80
				})
			end
			
			CCContainer.editCombinatorContainer.CCSelectedSignal.text = combinator.output.signalNum
			CCContainer.editCombinatorContainer.editCombinatorAmount.text = combinator.output.amount
			CCContainer.editCombinatorContainer.typeButtonRow.CCToggleMode.state = (combinator.output.type == "toggle")
			CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state = (combinator.output.type == "duration")
		else
			combinator.output = {
				signalNum = 1,
				amount = 1,
				type = "toggle"
			}
			
			setStyles(CCContainer.editCombinatorContainer.signalButtonRow["CCSignalButton" .. combinator.output.signalNum], {
				minimal_width = 80,
				minimal_height = 80,
				maximal_width = 80,
				maximal_height = 80
			})
		
			CCContainer.editCombinatorContainer.CCSelectedSignal.text = combinator.output.signalNum
			CCContainer.editCombinatorContainer.editCombinatorAmount.text = combinator.output.amount
			CCContainer.editCombinatorContainer.typeButtonRow.CCToggleMode.state = (combinator.output.type == "toggle")
			CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state = (combinator.output.type == "duration")
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
		combinator.name = CCContainer.editCombinatorContainer.editCombinatorName.text
		combinator.description = CCContainer.editCombinatorContainer.editCombinatorDesc.text
		combinator.output.signalNum = CCContainer.editCombinatorContainer.CCSelectedSignal.text
		combinator.output.amount = CCContainer.editCombinatorContainer.editCombinatorAmount.text
		if CCContainer.editCombinatorContainer.typeButtonRow.CCDurationMode.state then
			combinator.output.type = "duration"
		else
			combinator.output.type = "toggle"
		end

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
		combinator.entity.force = "enemy"
		combinator.entity.die()
		--Clear the Edit Combinator Page
		clearEditCombinatorPage(CCContainer.editCombinatorContainer)
		--Clean the combinator list
		cleanBadCombinators(global.ccdata[event.player_index])
	elseif string.find(element.name, "CCSignalButton") then
		--Deselect all of the buttons
		for i = 1, 10, 1 do
			setStyles(element.parent["CCSignalButton" .. i], {
				minimal_width = 40,
				minimal_height = 40,
				maximal_width = 40,
				maximal_height = 40
			})
		end
		--Select this button
		setStyles(element, {
			minimal_width = 80,
			minimal_height = 80,
			maximal_width = 80,
			maximal_height = 80
		})

		CCContainer.editCombinatorContainer.CCSelectedSignal.text = string.sub(element.name, -1)
	elseif element.name == "CCToggleMode" or element.name == "CCDurationMode" then
		element.parent.CCToggleMode.state = false
		element.parent.CCDurationMode.state = false
		element.state = true
	elseif element.name == "CCCombinatorButton" then
		local combinator = findCombinatorByName(global.ccdata[event.player_index].combinators, element.parent.parent.name)
		if combinator.active then
			if combinator.output.type == "duration" then
				removeFromQueue(global.ccdata.durationQueue, combinator)
			end
			deactivateCombinator(combinator)
		else
			activateCombinator(combinator)
		end
	end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	if event.entity.name == CC_NAME then
		event.entity.get_inventory(defines.inventory.chest).clear()
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	if event.entity.name == CC_NAME then
		event.entity.get_inventory(defines.inventory.chest).clear()
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

	--CREATE EDIT COMBINATOR PAGE--

	local editCombinatorContainer = CCContainer.add{type="scroll-pane", name="editCombinatorContainer", vertical_scroll_policy="auto", horizontal_scroll_policy="never", direction="vertical", caption="Edit Combinator"}

	setStyles(editCombinatorContainer, {
		visible = false,
		minimal_height = CC_WINDOW_HEIGHT,
		maximal_height = CC_WINDOW_HEIGHT
	})

	setStyles(editCombinatorContainer.add{type="label", caption="Combinator Name"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	editCombinatorContainer.add{type="textfield", name="editCombinatorName", tooltip="FYI: Editing the Control Combinator's name will move the Combinator's entry to the bottom of your list"}
	setStyles(editCombinatorContainer.add{type="label", caption="Combinator Description"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	setStyles(editCombinatorContainer.add{type="text-box", name="editCombinatorDesc"}, {
		minimal_width=CC_WINDOW_WIDTH,
		maximal_width=CC_WINDOW_WIDTH
	})
	setStyles(editCombinatorContainer.add{type="textfield", name="combinatorName"}, {
		visible = false
	})

	setStyles(editCombinatorContainer.add{type="label", caption="Output Signal"}, {
		top_padding = 30,
		font = "default-large-bold"
	})

	setStyles(editCombinatorContainer.add{type="textfield", name="CCSelectedSignal"}, {
		visible = false
	})

	local signalButtonRow = editCombinatorContainer.add{type="flow", direction="horizontal", name="signalButtonRow"}

	for i=1, 10, 1 do
		setStyles(signalButtonRow.add{type="sprite-button", name="CCSignalButton" .. i, sprite="item/" .. CC_SIGNAL_NAME(i)}, {
			minimal_width = 40,
			minimal_height = 40,
			maximal_width = 40,
			maximal_height = 40
		})
	end

	setStyles(editCombinatorContainer.add{type="label", caption="Signal Amount"}, {
		top_padding = 30,
		font = "default-large-bold"
	})
	editCombinatorContainer.add{type="textfield", name="editCombinatorAmount"}

	setStyles(editCombinatorContainer.add{type="label", caption="Signal Mode"}, {
		top_padding = 30,
		font = "default-large-bold"
	})

	local typeButtonRow = editCombinatorContainer.add{type="flow", direction="horizontal", name="typeButtonRow"}

	typeButtonRow.add{type="radiobutton", state=true, name="CCToggleMode", caption="Toggle Mode", tooltip="When in this mode, a Control Combinator must be manually turned on and off from the GUI."}
	typeButtonRow.add{type="radiobutton", state=false, name="CCDurationMode", caption="Duration Mode", tooltip="When in this mode, a Control Combinator will automatically turn off after the specified amount of time."}

	local ECCButtonRow = editCombinatorContainer.add{type="flow", direction="horizontal"}
	ECCButtonRow.add{type="button", name="editCombinatorSaveButton", caption="Save Changes"}
	ECCButtonRow.add{type="button", name="editCombinatorCancelButton", caption="Discard Changes"}
	ECCButtonRow.add{type="button", name="editCombinatorDestroyButton", caption="Destroy Combinator"}

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
		local newCombinator = generateCombinatorReference("New Combinator", event.created_entity)
		table.insert(global.ccdata[event.player_index].combinators, newCombinator)
		game.players[event.player_index].gui.center.CCNewCombinator.CCNCIndex.text = #global.ccdata[event.player_index].combinators
	end
end)
