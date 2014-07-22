--redstone_controller.lua: control one or more redstone outputs over rednet.

local wireless_side = "top"
local redstone_side = {["left"] = false, ["right"] = true}
local controller_ids = {[6]=true,[5]=true}

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


rednet.open(wireless_side)
-- Start with generators off:
output_sides(redstone_side, false)

while true do
  event, id, text = os.pullEvent()
  if event == "rednet_message" and controller_ids[id] then
    if text == "generators_on" then
      print("Turning on generators")
      output_sides(redstone_side, true)
    elseif text == "generators_off" then
      print("Turning off generators")
      output_sides(redstone_side, false)
    end
  end
end

