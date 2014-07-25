--bigreactor_control.lua: A basic control system for a reactor from the Big Reactors mod

local reactor_side = "right"
reactor = peripheral.wrap(reactor_side)

while true do
  if reactor.getActive() then
    if reactor.getEnergyStored > 9000000 then
      reactor.setActive(false)
    end
  else
    if reactor.getEnergyStored == 0 then
      reactor.setActive(true)
    end
  end
end