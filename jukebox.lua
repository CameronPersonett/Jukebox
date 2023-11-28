local jukebox_ui = require('jukebox_ui')

local sendPacket = function(cmd)
    rednet.broadcast({ command = cmd }, 'JBP')
end

rednet.open('back')

if #arg > 0 then
    local command = arg[1]

    if command == 'ui' then
        if #arg == 2 then
            jukebox_ui.run(arg[2], true)
        else
            jukebox_ui.run('/', true)
        end
    elseif command == 'queue' then
        if #arg == 2 then
            -- The song script will send the sample data to
            -- the player computer automagically
            shell.run(arg[2])

        else
            print('Error: No song/playlist arg passed.')
        end
    
    elseif command == 'play' then
        -- If the optional song/playlist arg is present, queue it up
        if #arg == 2 then
            shell.run(arg[2])
        end

        sendPacket('play')

    -- Fast-foward/rewind
    elseif command == 'ff' or command == 'rw' then
        -- Default to 5 seconds
        local ticks = 100

        if #arg == 2 then
            ticks = tonumber(arg[2])
        end

        local packet = {}
        packet.command = command
        packet.ticks = ticks
        rednet.broadcast(packet, 'JBP')

    elseif command == 'skip' or command == 'pause' or command == 'stop' then
        -- Pause, skip and stop need no extra logic; just
        -- chuck the packet at the player computer
        sendPacket(command)

    else
        print('Command \"' .. command .. '\" not recognized.')
    end

else
    print('Usage: jukebox <command> [arg]')
end
