--install.lua: install a specific script to the given computer

local args = {...}
if not args[1] and not args[2] then
  print("Usage: install (computer | turtle | pocket) <program name>")
  return
end

local file_path = "ComputerCraftSystems/CCSystems/master/lua"

file_path = file_path + args[1] + args[2]

shell.run("openp/github", "get", file_path, args[2])
shell.setAlias("startup", args[2])


--github usage:
--openp/github get username/reponame/branch/path <filename>