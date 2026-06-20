local BASE_URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/main/"

local function loadSource(path)
	local url = BASE_URL .. path
	local source = game:HttpGet(url)
	local chunk, compileError = loadstring(source, "@PureLib/" .. path)

	assert(chunk, ("PureLib failed to compile %s: %s"):format(path, compileError))

	local success, result = pcall(chunk)

	assert(success, ("PureLib failed to load %s: %s"):format(path, result))

	return result
end

local modules = {
	Window = loadSource("src/Window.lua"),
}

local PureLib = {}

function PureLib:CreateWindow(options)
	return modules.Window.new(options)
end

PureLib.Window = PureLib:CreateWindow({
	Title = "PureLib",
})

return PureLib
