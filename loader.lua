local BASE_URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/3b7edf10e5c0f0c1aed408f9cb053955a3737d7b/"

warn("[PureLib] Loader started")

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
