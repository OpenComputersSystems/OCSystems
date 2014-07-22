--door_control.lua: monitor energy storage levels, dynamically adapting to connected/disconnected storage

------------------------------ Begin Config options -------------------------------------------------------
--Change modem_side to the side where the wired modem is
--Change rednet_side to the side where the wireless modem is

-- redstone_side consists of key/value combos.
-- This allows you to invert the on/off state of any side individually.
local redstone_side = {["left"] = true}
local rednet_side = "top"

--Note that controller_ids uses computer ids as the keys of the table and true as the values.
--This is what makes the id validation statement controller_ids[id] work.
--There's probably another way to do this, but I thought it was easiest to do it this way.
--Simply add new controllers by appending [computer_id]=true, to the end of the controller_ids table
local controller_ids = {[27]=true}

-------------------------------- End config options---------------------------------------------------------

-------------------------------- Begin setup ---------------------------------------------------------------
rednet.open(rednet_side)
-- Start with generators off:
output_sides(redstone_side, false)


-------------------------------- End setup -----------------------------------------------------------------

-------------------------------- Begin function definitions ------------------------------------------------
function output_sides(side_dict, invert)
  if invert then
    for side, output in pairs(side_dict) do
      redstone.setOutput(side, not output)
    end
  else
    for side,output in pairs(side_dict) do
      redstone.setOutput(side, output)
    end
  end
end

-------------------------------- End function definitions---------------------------------------------------------

-------------------------------- Begin main loop -----------------------------------------------------------------
while true do
  event, id, text = os.pullEvent()
  if event == "rednet_message" and controller_ids[id] then
    if text == "open_door" then
      print("Opening door")
      output_sides(redstone_side, true)
    elseif text == "close_door" then
      print("Closing door")
      output_sides(redstone_side, false)
    end
  end
end
