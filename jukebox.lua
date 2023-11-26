local sendPacket = function(cmd)
    rednet.broadcast({ command = cmd }, 'JBP')
end

rednet.open('back')

if #args > 0 then
    local command = args[1]

    if command == 'queue' then
        if #args == 2 then
            -- The song script will send the sample data to
            -- the player computer automagically
            shell.run(args[2])

        else
            print('Error: No song/playlist arg passed.')
        end
    
    elseif command == 'play' then
        -- If the optional song/playlist arg is present, queue it up
        if #args == 2 then
            shell.run(args[2])
        end

        sendPacket('play')

    -- Fast-foward/rewind
    elseif command == 'ff' or command == 'rw' then
        -- Default to 5 seconds
        local ticks = 100

        if #args == 2 then
            ticks = tonumber(args[2])
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
    print('Error: No args passed.')
end
