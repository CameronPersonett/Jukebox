local M = {}
jukebox_commands = require('jukebox-commands')

-- Local functions
function get_all_songs(dir)
    local songs = {}
    local items = fs.list(dir)
    for i, item in ipairs(items) do
        local path = fs.combine(dir, item)
        if fs.isDir(path) then
            local sub_songs = get_all_songs(path)
            for j, song in ipairs(sub_songs) do
                table.insert(songs, song)
            end
        else
            table.insert(songs, path)
        end
    end
    return songs
end

function shuffle_songs(songs)
    for i = #songs, 2, -1 do
        local j = math.random(i)
        songs[i], songs[j] = songs[j], songs[i]
    end
end

local function play_random_song(songs)
    M.shuffle_songs(songs)
    jukebox_commands.play(songs[1])
end

function M.run(dir, isRoot)
    -- Open the monitors
    local monitor = peripheral.wrap("top")
    local monitor2 = peripheral.wrap("left")
    monitor.setTextScale(0.5)
    monitor2.setTextScale(0.5)

    if monitor == nil then
        error("No monitor found on top")
    end

    if monitor2 == nil then
        error("No monitor found on left")
    end

    local scrollPos = 0

    while true do
        -- Clear the monitor and set the cursor position to the top-left corner
        monitor.clear()
        monitor.setCursorPos(1, 1)

        -- List all files and directories in the directory
        local items = fs.list(dir)
        local displayItems = {}

        -- If not in the root directory, add an item to go back
        if not isRoot then
            table.insert(displayItems, "..")
        end

        for i, item in ipairs(items) do
            local fileName = string.gsub(item, "%..+$", "") -- remove file extension
            table.insert(displayItems, fileName)
        end

        -- Only display the items that fit on the screen based on the scroll position
        local width, height = monitor.getSize()
        for i = scrollPos + 1, math.min(scrollPos + height, #displayItems) do
            monitor.write(displayItems[i])
            monitor.setCursorPos(1, i - scrollPos + 1)
        end

        -- Add scroll indicators
        if scrollPos > 0 then
            monitor.setCursorPos(width, 1)
            monitor.setTextColor(colors.red) -- Set the text color to red
            monitor.write("^")
        elseif scrollPos == 0 then
            monitor.setCursorPos(width, 1)
            monitor.setTextColor(colors.gray) -- Set the text color to gray
            monitor.write("^")
        end
        if scrollPos + height < #displayItems then
            monitor.setCursorPos(width, height)
            monitor.setTextColor(colors.red) -- Set the text color to red
            monitor.write("v")
        elseif scrollPos + height == #displayItems then
            monitor.setCursorPos(width, height)
            monitor.setTextColor(colors.gray) -- Set the text color to gray
            monitor.write("v")
        end
        monitor.setTextColor(colors.white) -- Reset the text color to white

        -- Clear the second monitor and set the cursor position to the top-left corner
        monitor2.clear()
        monitor2.setCursorPos(1, 1)

        -- Display control options
        monitor2.write("[>]  Play")
        monitor2.setCursorPos(1, 2)
        monitor2.write("[||] Pause")
        monitor2.setCursorPos(1, 3)
        monitor2.write("[■]  Stop")
        monitor2.setCursorPos(1, 4)
        monitor2.write("[>>] Next")
        monitor2.setCursorPos(1, 5)
        monitor2.write("[<<] Previous")
        monitor2.setCursorPos(1, 6)
        monitor2.write("[?]  Shuffle")

        -- Wait for a mouse click event
        local event, side, x, y = os.pullEvent("monitor_touch")
        if event == "monitor_touch" and side == "top" then
            if x == width and y == 1 and scrollPos == 0 then
                -- Do nothing if the top arrow was clicked and we can't scroll up
            elseif x == width and y == 1 and scrollPos > 0 then
                -- If the top arrow was clicked and we can scroll up, decrease the scroll position
                scrollPos = scrollPos - 1
            elseif x == width and y == height and scrollPos + height <= #displayItems then
                -- If the bottom arrow was clicked and we can scroll down, increase the scroll position
                scrollPos = scrollPos + 1
            else
                -- Calculate which item was clicked
                local item = displayItems[scrollPos + y]
                if item then
                    if item == ".." then
                        -- If ".." was clicked, navigate to the parent directory
                        local parentDir = fs.getDir(dir)
                        M.run(parentDir, parentDir == "")
                    else
                        local path = fs.combine(dir, item)
                        if fs.isDir(path) then
                            -- If a directory was clicked, navigate into it
                            M.run(path, false)
                        else
                            -- If a file was clicked, display options for it
                            monitor.clear()
                            monitor.setCursorPos(1, 1)
                            monitor.write(item)
                            monitor.setCursorPos(1, 2)
                            monitor.write("1. Play")
                            monitor.setCursorPos(1, 3)
                            monitor.write("2. Queue")
                            monitor.setCursorPos(1, 4)
                            monitor.write("3. Back")

                            -- Wait for a mouse click event
                            local event, side, x, y = os.pullEvent("monitor_touch")
                            if event == "monitor_touch" then
                                if y == 2 then
                                    -- Play action
                                    jukebox_commands.play(path .. ".lua")
                                    -- Return to the directory listing
                                    M.run(dir, isRoot)
                                elseif y == 3 then
                                    -- Queue action
                                    jukebox_commands.queue(path .. ".lua")
                                    -- Return to the directory listing
                                    M.run(dir, isRoot)
                                elseif y == 4 then
                                    -- Back action
                                    M.run(dir, isRoot)
                                end
                            end
                        end
                    end
                end
            end
        elseif event == "monitor_touch" and side == "left" then
            if y == 1 then
                -- Play action
                jukebox_commands.play()
            elseif y == 2 then
                -- Pause action
                jukebox_commands.pause()
            elseif y == 3 then
                -- Stop action
                jukebox_commands.stop()
            elseif y == 4 then
                -- Next action
                jukebox_commands.skip()
            elseif y == 5 then
                -- Previous action
                jukebox_commands.previous()
            elseif y == 6 then
                -- Shuffle action
                local songs = get_all_songs(dir)
                shuffle_songs(songs)
                for _, song in ipairs(songs) do
                    jukebox_commands.queue(song .. ".lua")
                end
                jukebox_commands.play()
            end
        end
    end
end

return M