function run()
    -- Open the modem on our left side for networking with the back-end
    rednet.open('back')
 
    -- Run a while loop to get user input
    while true do
        -- Read a line from the user terminal
        line = read()
 
        -- Split the text by the space character into a table
        keywords = split(line)

        if #keywords > 0 then
            command = keywords[1]

            if command == 'quit' then
                -- If the user typed 'quit,' exit our script by returning
                return
     
            elseif command == 'queue' then
                -- The user must enter a second keyword that contains the song/playlist name
                if #keywords == 2 then
                    -- Run the song's script to load the samples and broadcast them to the player computer
                    shell.run(keywords[2])
     
                else
                    -- Alert the user that their command structure is invalid
                    print('Invalid syntax - correct syntax is: queue <song/playlist>')
                end
                
            elseif command == 'play' then
                local arg = keywords[2]

                -- The play command accepts two different command structures
                if arg == nil then
                    -- The first is just simply "play" - this is to resume playback from a
                    -- paused state
                    play()

                else
                    -- The second is "play <song/playlist>" - it queues the song and begins
                    -- playback in one fell swoop
                    
                    -- Stop playback if it is occurring and tell the player computer to
                    -- dump all of its current songs and reset its internal state
                    stop()
     
                    sleep(2)
                    
                    -- Queue the requested song/playlist
                    shell.run(arg)
                    
                    -- Begin playback
                    play();
                end
     
            elseif command == 'pause' then
                -- Pause playback
                packet = {}
                packet.command = 'pause'
                rednet.broadcast(packet, 'JBP')
     
            elseif command == 'skip' then
                -- Skip the current song and begin playing the next
                packet = {}
                packet.command = 'skip' 
                rednet.broadcast(packet, 'JBP')
                
            elseif command == 'stop' then
                -- Stop playback
                stop()
            end
        end
    end
end
 
function play()
    -- Turn off any previous pause/stop signals
    rs.setBundledOutput('back', 0)
    
    -- Send a packet containing the "play" command to the player computer
    packet = {}
    packet.command = 'play'
    rednet.broadcast(packet, 'JBP')
end
 
function stop()
    packet = {}
	packet.command = 'stop'
	rednet.broadcast(packet, 'JBP')
end
 
function split(inputstr)
    -- This function separates all of the text between spaces within a string
    -- and returns a table containing each bit of text
    local t={}
    local sep = "%s"
 
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
 
    return t
end
 
run()
