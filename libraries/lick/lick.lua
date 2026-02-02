---@diagnostic disable: undefined-global
-- lick.lua
--
-- simple LIVECODING environment for Löve
-- overwrites love.run, pressing all errors to the terminal/console or overlays it
--

local lick = {}
lick.debug = false                     -- show debug output
lick.reset = false                     -- reset the game and call love.load on file change
lick.clearFlag = false                 -- clear the screen on file change
lick.sleepTime = 0.001                 -- sleep time in seconds
lick.showReloadMessage = true          -- show message when a file is reloaded
lick.chunkLoadMessage = "CHUNK LOADED" -- message to show when a chunk is loaded
lick.updateAllFiles = false            -- include files in watchlist for changes
lick.clearPackages = false             -- clear all packages in package.loaded on file change
lick.defaultFile = "main.lua"          -- default file to load
lick.fileExtensions = { ".lua" }       -- file extensions to watch
lick.entryPoint = "main.lua"           -- entry point for the game, if empty, all files are reloaded
lick.debugTextXOffset = 50             -- X offset for debug text from the center (positive moves right)
lick.debugTextWidth = 400              -- Maximum width for debug text
lick.debugTextAlpha = 0.8              -- Opacity of the debug text (0.0 to 1.0)
lick.debugTextAlignment = "right"      -- Alignment of the debug text ("left", "right", "center", "justify")
lick.ignoreFile = ".lickignore"        -- file containing list of files to ignore
lick.mergePatterns = false             -- If true, merges default ignore patterns with .lickignore patterns
lick.onReload = nil                    -- Optional callback function to call after a reload. Passes list of reloaded files. Signature: function(reloaded_files)
lick.ignorePackages = {}               -- list of package names to ignore when clearing package.loaded

-- Default Ignore Patterns (used if no .lickignore file is found)
local default_ignore_patterns = [[
# Lick Itself
lick.lua
.lickignore

# Common Lua/LOVE directories
.git/
.vscode/
.idea/
vendor/
lib/
libraries/
modules/
]]

-- local variables
-- No longer needed, debug_output tracks persistent errors
local last_modified = {}
local debug_output = nil
local working_files = {}
local should_clear_screen_next_frame = false -- Flag to clear screen on next draw cycle
local ignore_patterns = {}

-- List of built-in Lua libraries that should never be cleared from package cache
local builtin_libs = {
    string = true,
    table = true,
    math = true,
    io = true,
    os = true,
    debug = true,
    coroutine = true,
    package = true,
    utf8 = true,
    bit = true,
    jit = true,
    ffi = true,
    -- LOVE built-in modules
    love = true
}

-- Helper to handle error output and update debug_output
local function handleErrorOutput(err_message)
    -- Ensure the message starts with "ERROR: " for console output if it doesn't already
    local console_message = tostring(err_message)
    if not console_message:find("^ERROR: ") then
        console_message = "ERROR: " .. console_message
    end
    print(console_message)

    -- Update debug_output for on-screen display
    if debug_output then
        debug_output = debug_output .. console_message .. "\n"
    else
        debug_output = console_message .. "\n"
    end
end

-- Error handler wrapping for pcall
local function handle(err)
    return "ERROR: " .. err
end

-- Helper function for consistent debug printing
-- Prefix can be set to false to omit the "[LICK]" prefix
-- Can be overridden for custom log handling outside LICK
function lick.debugPrint(message, showPrefix)
    if showPrefix == false then
        print(tostring(message))
    else
        print("[LICK] " .. tostring(message))
    end
end

-- Local alias for easier calls
-- Check for debug or force within local.
local function debugPrint(message, force, showPrefix)
    if force or lick.debug then
        lick.debugPrint(message, showPrefix)
    end
end

-- Convert gitignore-style patterns to Lua patterns
local function convertIgnorePattern(line)
    -- Trim whitespace
    line = line:match("^%s*(.-)%s*$")

    -- Skip empty lines and comments
    if line == "" or line:match("^#") then
        return nil
    end

    -- Convert gitignore-style patterns to Lua patterns
    local pattern = line

    -- Escape special lua pattern characters except '*' and '?'
    pattern = pattern:gsub("([%^%$%(%)%%%.%[%]%+%-])", "%%%1")

    -- Convert wildcards: '*' to '.*' and '?' to '.'
    pattern = pattern:gsub("%*%*", "\001")  -- Temporary marker for '**'
    pattern = pattern:gsub("%*", "[^/]*")   -- '*' matches any sequence except '/'
    pattern = pattern:gsub("\001", ".*")    -- '**' matches any sequence including '/'
    pattern = pattern:gsub("%?", ".")       -- '?' matches any single character

    -- Handle directory patterns (ending with '/')
    if line:sub(-1) == "/" then
        pattern = "^" .. pattern:sub(1, -2) .. "/?"
    else
        -- Match the pattern at any position in the path
        if not line:match("^/") then
            pattern = pattern .. "$"
        else
            pattern = "^" .. pattern:sub(2) .. "$"
        end
    end

    return pattern
end


-- Parse .lickignore file for patterns to ignore
local function loadIgnorePatterns()
    local patterns = {}
    local ignoreFileContent, err = love.filesystem.read(lick.ignoreFile)
    local default_patterns = {}

    -- Parse default patterns first
    for line in default_ignore_patterns:gmatch("[^\r\n]+") do
        local pattern = convertIgnorePattern(line)
        if pattern then
            table.insert(default_patterns, pattern)
        end
    end

    -- If no .lickignore file found, use default patterns
    if not ignoreFileContent then
        debugPrint("No .lickignore file found. Using default ignore patterns.")

        for _, pattern in ipairs(default_patterns) do
            table.insert(patterns, pattern)
        end
    else
        -- .lickignore file exists, check for merging option
        if lick.mergePatterns then
            debugPrint("Merging .lickignore patterns with default ignore patterns.")

            for _, pattern in ipairs(default_patterns) do
                table.insert(patterns, pattern)
            end
        else
            debugPrint("Using .lickignore patterns only.")
        end

        -- Parse .lickignore file
        for line in ignoreFileContent:gmatch("[^\r\n]+") do
            local pattern = convertIgnorePattern(line)
            if pattern then
                table.insert(patterns, pattern)
            end
        end
    end

    debugPrint("Loaded " .. tostring(#patterns) .. " ignore patterns.")
    return patterns
end

-- Check if a file path matches any ignore pattern
local function shouldIgnore(filePath)
    for _, pattern in ipairs(ignore_patterns) do
        if filePath:match(pattern) then
            return true
        end
    end
    return false
end

-- Prints the working_files in a tree structure for debugging
local function printWorkingFiles(files)
    -- Build a tree structure from flat file paths
    local tree = {}

    for _, filepath in ipairs(files) do
        local parts = {}
        for part in filepath:gmatch("[^/]+") do
            table.insert(parts, part)
        end

        local current = tree
        for i, part in ipairs(parts) do
            if i == #parts then
                -- It's a file
                table.insert(current, { name = part, is_file = true })
            else
                -- It's a directory
                local found = false
                for _, node in ipairs(current) do
                    if node.name == part and not node.is_file then
                        current = node.children
                        found = true
                        break
                    end
                end

                if not found then
                    local new_dir = { name = part, is_file = false, children = {} }
                    table.insert(current, new_dir)
                    current = new_dir.children
                end
            end
        end
    end

    -- Sort function to put directories first, then alphabetically
    local function sortTree(node)
        table.sort(node, function(a, b)
            if a.is_file ~= b.is_file then
                return not a.is_file -- directories first
            end
            return a.name < b.name
        end)

        for _, child in ipairs(node) do
            if not child.is_file then
                sortTree(child.children)
            end
        end
    end
    sortTree(tree)

    -- Build the tree as a single string
    local tree_lines = {}
    local function buildTree(node, prefix)
        for i, item in ipairs(node) do
            local is_last_item = (i == #node)
            local connector = is_last_item and "└── " or "├── "
            local display_name = item.is_file and item.name or (item.name .. "/")

            table.insert(tree_lines, prefix .. connector .. display_name)

            if not item.is_file then
                local new_prefix = prefix .. (is_last_item and "    " or "│   ")
                buildTree(item.children, new_prefix)
            end
        end
    end

    buildTree(tree, "")

    -- Print the entire tree at once
    debugPrint(table.concat(tree_lines, "\n"), true, false)
end

-- Function to collect all files in the directory and subdirectories with the given extensions into a set
local function collectWorkingFiles(file_set, dir)
    dir = dir or ""
    local files = love.filesystem.getDirectoryItems(dir)
    for _, file in ipairs(files) do
        local filePath = dir .. (dir ~= "" and "/" or "") .. file
        local info = love.filesystem.getInfo(filePath)

        -- Skip if file/directory matches any ignore pattern
        if shouldIgnore(filePath) then
            goto continue
        end

        if info and info.type == "file" then
            -- If fileExtensions is empty, accept all files
            if #lick.fileExtensions == 0 then
                file_set[filePath] = true
            else
                -- Otherwise, check if file matches any of the specified extensions
                for _, ext in ipairs(lick.fileExtensions) do
                    if file:sub(- #ext) == ext then
                        file_set[filePath] = true
                        break -- No need to check other extensions once matched
                    end
                end
            end
        elseif info and info.type == "directory" then
            collectWorkingFiles(file_set, filePath)
        end

        ::continue::
    end
end

-- Initialization
local function load()
    debugPrint("Initializing LICK...")
    -- Load ignore patterns from .lickignore file
    ignore_patterns = loadIgnorePatterns()

    -- Clear previous working files to prevent accumulation if load() is called multiple times
    working_files = {}

    if not lick.updateAllFiles then
        table.insert(working_files, lick.defaultFile)
        debugPrint("Watching default file only: " .. lick.defaultFile)
    else
        local file_set = {}
        collectWorkingFiles(file_set, "") -- Start collection from root directory
        -- Convert set to ordered list
        for file_path, _ in pairs(file_set) do
            table.insert(working_files, file_path)
        end
    end

    -- Initialize the last_modified table for all working files
    for _, file in ipairs(working_files) do
        local info = love.filesystem.getInfo(file)
        -- Ensure info exists before accessing modtime; set to 0 or current time if file not found
        if info then
            last_modified[file] = info.modtime
        else
            -- If a file listed in working_files doesn't exist, treat its modtime as 0
            -- This ensures it will appear as "modified" if it ever appears later.
            last_modified[file] = 0
        end
    end

    debugPrint("LICK initialized.")
    -- Debug Output
    if lick.debug then
        debugPrint("Watching " .. tostring(#working_files) .. " files:")
        printWorkingFiles(working_files)
    end
end

local function reloadFile(file)
    debugPrint("Reloading file: " .. file)
    local success, chunk = pcall(love.filesystem.load, file)
    if not success then
        handleErrorOutput(chunk)
        return
    end
    if chunk then
        local ok, err = xpcall(chunk, handle)
        if not ok then
            handleErrorOutput(err)
        else
            if lick.showReloadMessage then
                debugPrint(lick.chunkLoadMessage .. ": " .. file)
            end
            debug_output = nil
        end
    end

    if lick.reset and love.load then
        debugPrint("Calling love.load due to reset flag.")
        local loadok, err = xpcall(love.load, handle)
        if not loadok then -- Always report load errors
            handleErrorOutput(err)
        end
    end
end

-- if a file is modified, reload relevant files
local function checkFileUpdate()
    local any_file_modified = false
    local files_actually_modified = {} -- Store paths of files whose modtime has changed

    for _, file_path in ipairs(working_files) do
        local info = love.filesystem.getInfo(file_path)
        -- Check if file exists and its modification time has changed
        -- Use `or 0` for `last_modified[file_path]` to handle cases where it might not be initialized,
        -- ensuring `info.modtime` (if exists) is always greater than 0.
        if info and info.type == "file" and info.modtime and info.modtime > (last_modified[file_path] or 0) then
            any_file_modified = true
            table.insert(files_actually_modified, file_path)
            last_modified[file_path] = info.modtime -- Update the last modified time
        elseif not info and last_modified[file_path] ~= nil then
            debugPrint("File deleted: " .. file_path)
            -- Handle case where a previously tracked file no longer exists (it was deleted)
            -- This means its state has changed.
            any_file_modified = true
            last_modified[file_path] = 0 -- Set to 0 so if it reappears, it's detected as modified
            -- Note: We don't add deleted files to `files_actually_modified` because `reloadFile`
            -- would fail if called on a non-existent file. The effect of deletion is usually
            -- handled by re-running the entry point or by the user.
        end
    end

    if not any_file_modified then
        return -- No files changed, nothing to do
    end

    debugPrint("Detected changes in " .. tostring(#files_actually_modified) .. " file(s).")

    -- If lick.clearFlag is true, set a flag to clear the screen on the next draw
    if lick.clearFlag then
        debugPrint("Screen will be cleared on next frame.")
        should_clear_screen_next_frame = true
    end

    -- If any file was modified, clear packages from the require cache if configured
    if lick.clearPackages then
        local cleared_count = 0
        for k, _ in pairs(package.loaded) do
            -- Only clear non-builtin packages and those not in the ignorePackages list
            if not builtin_libs[k] and not lick.ignorePackages[k] then
                package.loaded[k] = nil
            end
        end
        debugPrint("Cleared " .. cleared_count .. " packages from require cache.")
    end

    if lick.entryPoint ~= "" then
        -- If an entry point is defined, reload it. This ensures the entire game logic
        -- (which might implicitly depend on modified files) is re-executed.
        debugPrint("Reloading entry point: " .. lick.entryPoint)
        reloadFile(lick.entryPoint)
    else
        -- If no specific entry point, only reload the files that were actually modified.
        debugPrint("Reloading modified files individually.")
        for _, file_path in ipairs(files_actually_modified) do
            reloadFile(file_path)
        end
    end

    -- Call the onReload callback if defined, passing the list of reloaded files
    if lick.onReload and type(lick.onReload) == "function" then
        debugPrint("Calling onReload callback.")
        local status, err = pcall(lick.onReload, files_actually_modified)
        if not status then
            handleErrorOutput("Error in onReload callback: " .. tostring(err))
        end
    end

    -- last_modified for files that actually changed was updated in the initial loop.
    -- For files that didn't change, their last_modified values remain correct.
    -- If a file was deleted, its last_modified is set to 0.
    -- No further global update loop for last_modified is needed.
end

local function update(dt)
    checkFileUpdate()
    if not love.update then return end
    local updateok, err = pcall(love.update, dt)
    if not updateok then -- Always report update errors
        handleErrorOutput(err)
    end
end

local function draw()
    local drawok, err = xpcall(love.draw, handle)
    if not drawok then -- Always report draw errors
        handleErrorOutput(err)
    end

    if lick.debug and debug_output then
        love.graphics.setColor(1, 1, 1, lick.debugTextAlpha)
        love.graphics.printf(debug_output, (love.graphics.getWidth() / 2) + lick.debugTextXOffset, 0, lick.debugTextWidth, lick.debugTextAlignment)
    end
end

-- Expose API functions for external use so users can override
-- their own love.run if desired and call these functions as
-- according to documentation for 'Custom love.run Implementation'.
lick.init = load
lick.check = checkFileUpdate
lick.drawDebug = function()
    if lick.debug and debug_output and love.graphics and love.graphics.isActive() then
        love.graphics.setColor(1, 1, 1, lick.debugTextAlpha)
        love.graphics.printf(debug_output, (love.graphics.getWidth() / 2) + lick.debugTextXOffset, 0, lick.debugTextWidth, lick.debugTextAlignment)
    end
end

function love.run()
    load()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- Workaround for macOS random number generator issue
    -- On macOS, the random number generator can produce the same sequence of numbers
    -- if not properly seeded. This workaround ensures that the random number generator
    -- is seeded correctly to avoid this issue.
    if jit and jit.os == "OSX" then
        math.randomseed(os.time())
        math.random()
        math.random()
    end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    return function()
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            dt = love.timer.step()
        end

        -- Call update and draw
        if update then update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            -- Clear the screen based on lick.clearFlag and file modification
            if lick.clearFlag and should_clear_screen_next_frame then
                love.graphics.clear(love.graphics.getBackgroundColor())
                should_clear_screen_next_frame = false -- Reset the flag after clearing
            elseif not lick.clearFlag then
                -- If lick.clearFlag is false, clear the screen every frame (default behavior)
                love.graphics.clear(love.graphics.getBackgroundColor())
            end
            if draw then draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(lick.sleepTime) end
    end
end

return lick
