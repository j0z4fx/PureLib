local BASE_URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/72f7c43f60e9bb354e213f11a487909d42fd0be3/"

warn("[PureLib] Loader started")

local compilerTest, compilerError = loadstring("return 1")
assert(compilerTest, ("PureLib loadstring self-test failed: %s"):format(compilerError))
assert(compilerTest() == 1, "PureLib loadstring self-test returned an invalid result")
warn("[PureLib] loadstring self-test passed")

local function loadSource(path)
	local url = BASE_URL .. path
	warn(("[PureLib] Fetching %s"):format(url))

	local source = game:HttpGet(url)
	assert(type(source) == "string" and #source > 0, ("PureLib received an empty response for %s"):format(path))
	warn(("[PureLib] Fetched %s (%d bytes)"):format(path, #source))

	local chunk, compileError = loadstring(source)

	assert(chunk, ("PureLib failed to compile %s: %s"):format(path, compileError))
	warn(("[PureLib] Compiled %s"):format(path))

	local success, result = pcall(chunk)

	assert(success, ("PureLib failed to load %s: %s"):format(path, result))
	assert(result ~= nil, ("PureLib module %s returned nil"):format(path))
	warn(("[PureLib] Loaded %s"):format(path))

	return result
end

local modules = {
	Window = loadSource("src/Window.lua"),
}

local PureLib = {}

function PureLib:CreateWindow(options)
	warn("[PureLib] CreateWindow called")

	local window = modules.Window.new(options)

	warn("[PureLib] CreateWindow completed")
	return window
end

warn("[PureLib] Loader ready")

return PureLib
