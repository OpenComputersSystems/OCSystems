-- display_controller.lua - controls glass HUD and monitor displays

--TODO: add documentation, add table of labels, show error messages when
--unable to connect to level polling machines
--have a timeout function in the parallel loop to mitigate the effects of ddos

-- Planned features:
-- Control power generation, activate/deactivate non-essentials based on energy storage level
-- monitor energy (EU/MJ/whatever) each with separate bars
-- monitor liquid levels from tanks
-- monitor ME storage network (free space, etc.)
-- colorize status bars
-- configure via chat messages

-- Version history:
--12/21/2013: v1.2 - Added automatic generator triggering when in the RED_ZONE
--12/21/2013: v1.1 - colorized status bars
--12/21/2013: v1.0 - initial power monitor functioning

glass_bridge_side = "top"
local energy_poller = 4
local energy_label = "Energy Storage (RF)"
local rednet_side = "right"

local generator_controller = 7

--HUD/display options
--Width of HUD
local width = 100
local RED_ZONE = 0.30
local YELLOW_ZONE = 0.65
local GREEN_ZONE = 0.75



function activate_generators(truthval)
  if truthval then
    state = "generators_on"
  else
    state = "generators_off"
  end
  rednet.send(generator_controller, state)
end


function poll_energy()
    print("Polling energy")
    rednet.send(energy_poller, "poll_energy")
end

function update_energy(energy_table, valid_id)
  id, message, distance = rednet.receive(5)
  if message ~= nil and id == valid_id then
    print("Message received!")
    energy_poll_result = textutils.unserialize(message)
    energy_table["capacity"] = energy_poll_result["capacity"]
    energy_table["stored"] = energy_poll_result["stored"]
  else
    print("No message received!")
    energy_table["capacity"] = 0
    energy_table["stored"] = 0
  end

end


function colorize_bar(level, gui)
  gui["power_level"].delete()
  if level["stored"]<level["capacity"]*gui["red"] then
    gui["power_level"] = gui["bridge"].addBox(4, gui["level_offset"], 0, 5, 0xCC0000, 0.9)
  elseif level["stored"]<level["capacity"]*gui["yellow"] then
    gui["power_level"] = gui["bridge"].addBox(4, gui["level_offset"], 0, 5, 0xCCCC00, 0.9)
  else
    gui["power_level"] = gui["bridge"].addBox(4, gui["level_offset"], 0, 5, 0x00CC00, 0.9)
  end
  --gui_elements["power_level"].setZIndex(2)
end

--Initialization
rednet.open(rednet_side)
local bridge = peripheral.wrap(glass_bridge_side)
bridge.clear()
local offset = 0
pxOffset = offset * 20
gui_elements = {}
gui_elements["red"] = RED_ZONE
gui_elements["yellow"] = YELLOW_ZONE
gui_elements["green"] = GREEN_ZONE
gui_elements["bridge"] = bridge
gui_elements["label"] = bridge.addText(4, 4 + pxOffset, energy_label, 0x666666)
gui_elements["label_offset"] = 4 + pxOffset
gui_elements["level_offset"] = 14 + pxOffset
gui_elements["power_level"] = bridge.addBox(4, 14 + pxOffset, 0, 5, 0xCC0000, 0.9)
--gui_elements["power_level"].setZIndex(2)
gui_elements["background"] = bridge.addBox(4, 14 + pxOffset, width, 5, 0x000000, 0.5)

energy_levels = {["capacity"]= 0, ["stored"] = 0}


--Main loop
while true do
  --Poll power monitor over rednet
  poll_energy()
  update_energy(energy_levels, energy_poller)
  --TODO: see if we can get parallel to work nicely.
  --parallel.waitForAny(poll_energy, update_energy(energy_levels, energy_poller))
  --Update glass display
  colorize_bar(energy_levels, gui_elements)
  gui_elements["power_level"].setWidth(width / energy_levels["capacity"] * energy_levels["stored"])
  --If energy levels are critical, activate generators:
  if energy_levels["stored"] < energy_levels["capacity"]*RED_ZONE then
    activate_generators(true)
  else
    activate_generators(false)
  end
  
  --TODO: update monitor
  sleep(0.5)
end

