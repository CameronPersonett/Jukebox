jukebox_ui = require('jukebox-ui')
jukebox_commands = require('jukebox-commands')

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
            jukebox_commands.queue(arg[2])
        else
            print('Error: No song/playlist arg passed.')
        end
    
    elseif command == 'play' then
        -- If the optional song/playlist arg is present, queue it up
        if #arg == 2 then
            jukebox_commands.play(arg[2])
        else
            error('Error: No song/playlist arg passed.')
        end


    -- Fast-foward/rewind
    elseif command == 'ff' or command == 'rw' then
        if #arg == 2 then
            ticks = tonumber(arg[2])
        end

        jukebox_commands[command](ticks)

    elseif command == 'skip' or command == 'pause' or command == 'stop' then
        jukebox_commands[command]()

    elseif command == 'version' then
        print('Jukebox v1.0.0')
    
    elseif command == 'help' then
        print('Usage: jukebox <command> [arg]')
        print('Commands:')
        print('  ui [path] - Run the jukebox UI')
        print('  queue <path> - Queue a song or playlist')
        print('  play <path> - Queue a song or playlist and play it')
        print('  ff [ticks] - Fast-forward the current song')
        print('  rw [ticks] - Rewind the current song')
        print('  skip - Skip the current song')
        print('  pause - Pause the current song')
        print('  stop - Stop the current song')
        print('  help - Display this help message')
        print('  version - Display the version number')
    else
        print('Command \"' .. command .. '\" not recognized.')
    end

else
    print('Usage: jukebox <command> [arg]')
end
