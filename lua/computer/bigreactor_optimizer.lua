--bigreactor_control.lua: A simple attempt to optimize the efficiency of a reactor in Big Reactors
-- Currently, this iterates control rod levels 1-99 for all rods at once and finds the best efficiency.
-- In the future, individual control rods will be manipulated, and a much more sophisticated
-- optimization technique will be needed: most likely GA (hard) or Simplex with random starting points (not as hard)

-- WARNING: THIS SCRIPT MAY NOT FIND OPTIMAL SETTINGS FOR VERY SMALL REACTORS!
-- The output of small reactors can change significantly depending on how much
-- waste is present in the reactor.  Large reactors (>100 ingot capacity) don't
-- suffer noticeably from this issue.  Take any optimizations found on a small
-- reactor with a grain of salt.  There are ways around this, but they can be
-- wasteful and/or time-consuming.

------------------------------ Begin Config options -------------------------------------------------------

local reactor_side = "back"
local settle_time = 15 --Seconds to wait for a reactor's output to 'settle' to new levels
local num_samples = 10 --Number of times the 

-------------------------------- End config options---------------------------------------------------------

-------------------------------- Begin function definitions ------------------------------------------------

-- In order to calculate fuel efficiency, we take several samples at random,
-- but short, time intervals.  This is done in an effort to compensate for the
-- small fluctuations that can occur in output levels
function calculateFuelEfficiency(r, samples)
  e = 0.0
  for i=1,samples do
    e = e + r.getEnergyProducedLastTick()/r.getFuelConsumedLastTick()
    sleep(math.random()+0.2) -- output fluctuates a bit
  end
  return e/samples
end

-------------------------------- End function definitions---------------------------------------------------------

-------------------------------- Begin setup ---------------------------------------------------------------------

reactor = peripheral.wrap(reactor_side)
math.randomseed(os.time())
num_control_rods = reactor.getNumberOfControlRods()
reactor.setAllControlRodLevels(0)
sleep(settle_time)
best_efficiency = calculateFuelEfficiency(reactor, num_samples)
best_efficiency_level = 0
efficiencies = {}

-------------------------------- End setup -----------------------------------------------------------------------

-------------------------------- Begin main loop -----------------------------------------------------------------

for i=1,99 do
  reactor.setAllControlRodLevels(i)
  sleep(settle_time)
  efficiencies[i]=calculateFuelEfficiency(reactor, num_samples)
  if efficiencies[i] > best_efficiency then
    print("Found new best efficiency of "..efficiencies[i].." RF/mB at level "..i)
    best_efficiency = efficiencies[i]
    best_efficiency_level = i
  end
end

-------------------------------- End main loop -------------------------------------------------------------------


print("Best efficiency found: "..best_efficiency.." RF/mB")
print("Energy per yellowrium ingot: "..1000*best_efficiency.." RF (without reprocessing)")
-- Reprocessing ingots yields half again as much material as you started with, at negligible energy cost
-- This means that the total energy from reprocessing fuel can be found in the infinite sum:
-- $\sum_{n=0}^{\infty} \frac{1}{2^n} = 2$ times the effective energy of an ingot without reprocessing.
-- Yay math! (You may need to know a bit of LaTeX to parse the above equation)
print("Approximate energy per yellowrium ingot including residual energy from reprocessing: "..2000*best_efficiency.." RF")
print("Terminating and setting reactor control rods to best found level. . .")
reactor.setAllControlRodLevels(best_efficiency_level)
