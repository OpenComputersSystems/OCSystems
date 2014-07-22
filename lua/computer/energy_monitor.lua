--energy_monitor.lua: monitor energy storage levels, dynamically adapting to connected/disconnected storage

------------------------------ Begin Config options -------------------------------------------------------
--Change modem_side to the side where the wired modem is
--Change rednet_side to the side where the wireless modem is


local modem_side = "left"
local rednet_side = "top"

--Note that controller_ids uses computer ids as the keys of the table and true as the values.
--This is what makes the id validation statement controller_ids[id] work.
--There's probably another way to do this, but I thought it was easiest to do it this way.
--Simply add new controllers by appending [computer_id]=true, to the end of the controller_ids table
local controller_ids = {[6]=true,[5]=true}

-------------------------------- End config options---------------------------------------------------------

-------------------------------- Begin setup ---------------------------------------------------------------
rednet.open(rednet_side)
local net = peripheral.wrap(modem_side)

-------------------------------- End setup -----------------------------------------------------------------


-------------------------------- Begin function definitions ------------------------------------------------
function poll_energy(energyStorageUnits, wired_network)
  local total_capacity = 0
  local total_stored = 0
  for i=#energyStorageUnits,1,-1 do
    storageUnit = energyStorageUnits[i]
    if net.isPresentRemote(storageUnit) then
      total_capacity = total_capacity + wired_network.callRemote(storageUnit, "getMaxEnergyStored", "up")
      total_stored = total_stored + wired_network.callRemote(storageUnit, "getEnergyStored", "up")
    else
      table.remove(energyStorageUnits, i)
    end
  end
  return {["stored"] = total_stored, ["capacity"] = total_capacity}
end

function scanPeripherals()
    p = peripheral.getNames()
    names = {}
    for key, val in ipairs(p) do
      if string.find(val,"cofh_thermalexpansion_energycell_") ~= nil then
        print("Found energy storage: "..val)
        table.insert(names, val)
      end
    end
    return names
end

-------------------------------- End function definitions---------------------------------------------------------
-------------------------------- Begin main loop -----------------------------------------------------------------
while true do
    event, id, text = os.pullEvent()
    if event == "rednet_message" and controller_ids[id] then
        
        --If we receive a request from an authorized controller 
        if text == "poll_energy" then
            print("Poll request received")
            --Poll available peripherals and find attached energy storage
            energy_peripherals = scanPeripherals()
            --Calculate the amount of energy stored and the capacity
            print("Calculating energy")
            energy_table = poll_energy(energy_peripherals, net)
            --Serialize the results of the poll_energy function
            serialized_energy_table = textutils.serialize(energy_table)
            print("sending data: "..serialized_energy_table)
            --Send energy storage numbers back to the controller that made the request
            rednet.send(id, serialized_energy_table)
        end
    end
end

