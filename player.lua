speaker = peripheral.wrap('top')
rednet.open('back')

function resetQueue()
    songs = {}
    lastSong = 1
    lastSample = 1
end

lastCommand = ''
resetQueue()

function run()
    while true do
        if lastCommand == '' then
            awaitInput()

        elseif lastCommand == 'play' then
            if #songs > 0 then
                print('Playing song ' .. lastSong .. ' beginning at sample ' .. lastSample .. ".")
                parallel.waitForAny(awaitInput, play)
                
            else
                print('Cannot play music; there are no songs in the queue!')
                lastCommand = ''
            end

        elseif lastCommand == 'skip' then
            -- Increment the song index and reset the sample index
            -- to get to the next song in the queue, then play again
            if #songs > 1 then
                print('Skipping song ' .. lastSong .. '.')

                lastSong = lastSong + 1
                lastSample = 1
                lastCommand = 'play'

            else
                print('Skipped final song in queue.')
                lastCommand = 'stop'
            end

        elseif lastCommand == 'pause' then
            print('Pausing song ' .. lastSong .. ' at sample ' .. lastSample)

            -- Simply idle until we're told to do something else
            lastCommand = ''
            
        elseif lastCommand == 'stop' then
            print('Stopping playback and clearing queue.')
            resetQueue()
            lastCommand = ''
        end
    end
end

function awaitInput()
    -- Run a while loop to listen for incoming packets from the jukebox computer
    while true do
        -- Receive a packet over the jukebox protocol
        local sender, packet, protocol = rednet.receive('JBP')
 
        -- Grab the command from the packet
        local command = packet.command

        -- Set the last command to know how to proceed if we return
        lastCommand = command

        -- The queue command can be dealt with during playback; just append
        -- the song and its samples to the songs table
        if command == 'queue' then
            local song = packet.song

            -- Inject the song in the songs table
            table.insert(songs, song)

            print('Added ' .. song.name .. ' (' .. #song.samples .. ' samples) to the queue.')

        else
            -- If we received any other command, return to handle it in run()
            return
        end
    end
end
 
function play()
    -- Get some information about the queue
    local totalSamples = 0

    for i = 1, #songs, 1 do
        totalSamples = totalSamples + #songs[i].samples
    end
    
    -- Print some information about the songs table
    --print('Playing ' .. #songs .. ' songs (' .. totalSamples .. ' samples).')
    
    -- We use a nested for loop here - one for the amount of songs we have, another for the number
    -- of samples in each song and the last for the number of note events in each sample
    for curSong = lastSong, #songs, 1 do
        for curSample = lastSample, #songs[curSong].samples, 1 do
            for curEvent = 1, #songs[curSong].samples[curSample].noteEvents, 1 do
                -- Play a note for every note event in the sample
                playNote(songs[curSong].samples[curSample].noteEvents[curEvent])
            end
            
            -- Wait until the next tick
            local curMS = os.epoch()
            local tickRem = curMS % 50
            local tickMin = 50 - tickRem
            local waitTime = tickMin / 1000
            sleep(waitTime)

            lastSample = curSample
        end
 
        -- Set the sampleIndex back to 1 after this song is complete so we start from the
        -- beginning of the next song
        lastSong = cur
    end
 
    -- Reset globals after playback is complete
    lastCommand = 'stop'
end
 
function playNote(noteEvent)
    -- This function interfaces with the speaker peripheral to play the current note event's
    -- note on the current note event's instrument
    if noteEvent.instrument == 'bass' then
        speaker.playNote(noteEvent.instrument, 3, getNoteValue(noteEvent.instrument, noteEvent.note))
        
    elseif noteEvent.instrument == 'guitar' then
        speaker.playNote(noteEvent.instrument, 3, getNoteValue(noteEvent.instrument, noteEvent.note))
 
    elseif noteEvent.instrument == 'flute' then
        speaker.playNote(noteEvent.instrument, 3, getNoteValue(noteEvent.instrument, noteEvent.note))
 
    elseif noteEvent.instrument == 'bell' then
        speaker.playNote(noteEvent.instrument, 3, getNoteValue(noteEvent.instrument, noteEvent.note))
 
    else -- Drums
        if noteEvent.instrument == 'bassDrum' then
            speaker.playNote('baseDrum', 3, 0)
 
        elseif noteEvent.instrument == 'lowFloorTom' then
            speaker.playNote('baseDrum', 3, 18)
 
        elseif noteEvent.instrument == 'highFloorTom' then
            speaker.playNote('baseDrum', 3, 21)
 
        elseif noteEvent.instrument == 'lowTom' then
            speaker.playNote('baseDrum', 3, 24)
 
        elseif noteEvent.instrument == 'lowMidTom' then
            speaker.playNote('snare', 3, 0)
 
        elseif noteEvent.instrument == 'highMidTom' then
            speaker.playNote('snare', 3, 3)
 
        elseif noteEvent.instrument == 'highTom' then
            speaker.playNote('snare', 3, 6)
 
        elseif noteEvent.instrument == 'snare' then
            speaker.playNote('snare', 3, 12)
 
        elseif noteEvent.instrument == 'hat' then
            speaker.playNote('hat', 3, 24)
        end
    end
end
 
function getNoteValue(instrument, note)
    -- This function returns the integer required for speaker.playNote(...)'s third parameter: pitch
    -- The value returned corresponds to each instrument's musical range - for example, 0 returned
    -- from the "bell" instrument is a higher pitch than an 11 returned from the "bass" instrument
    if instrument == 'bass' then
        if note == "F#1" then
            return 0
        elseif note == "G1" then
            return 1
        elseif note == "G#1" then
            return 2
        elseif note == "A1" then
            return 3
        elseif note == "A#1" then
            return 4
        elseif note == "B1" then
            return 5
        elseif note == "C2" then
            return 6
        elseif note == "C#2" then
            return 7
        elseif note == "D2" then
            return 8
        elseif note == "D#2" then
            return 9
        elseif note == "E2" then
            return 10
        elseif note == "F2" then
            return 11
        end
    elseif instrument == 'guitar' then
        if note == "F#2" then
            return 0
        elseif note == "G2" then
            return 1
        elseif note == "G#2" then
            return 2
        elseif note == "A2" then
            return 3
        elseif note == "A#2" then
            return 4
        elseif note == "B2" then
            return 5
        elseif note == "C3" then
            return 6
        elseif note == "C#3" then
            return 7
        elseif note == "D3" then
            return 8
        elseif note == "D#3" then
            return 9
        elseif note == "E3" then
            return 10
        elseif note == "F3" then
            return 11
        elseif note == "F#3" then
            return 12
        elseif note == "G3" then
            return 13
        elseif note == "G#3" then
            return 14
        elseif note == "A3" then
            return 15
        elseif note == "A#3" then
            return 16
        elseif note == "B3" then
            return 17
        elseif note == "C4" then
            return 18
        elseif note == "C#4" then
            return 19
        elseif note == "D4" then
            return 20
        elseif note == "D#4" then
            return 21
        elseif note == "E4" then
            return 22
        elseif note == "F4" then
            return 23
        elseif note == "F#4" then
            return 24
        end
    elseif instrument == 'flute' then
        if note == "G4" then
            return 1
        elseif note == "G#4" then
            return 2
        elseif note == "A4" then
            return 3
        elseif note == "A#4" then
            return 4
        elseif note == "B4" then
            return 5
        elseif note == "C5" then
            return 6
        elseif note == "C#5" then
            return 7
        elseif note == "D5" then
            return 8
        elseif note == "D#5" then
            return 9
        elseif note == "E5" then
            return 10
        elseif note == "F5" then
            return 11
        elseif note == "F#5" then
            return 12
        elseif note == "G5" then
            return 13
        elseif note == "G#5" then
            return 14
        elseif note == "A5" then
            return 15
        elseif note == "A#5" then
            return 16
        elseif note == "B5" then
            return 17
        elseif note == "C6" then
            return 18
        elseif note == "C#6" then
            return 19
        elseif note == "D6" then
            return 20
        elseif note == "D#6" then
            return 21
        elseif note == "E6" then
            return 22
        elseif note == "F6" then
            return 23
        elseif note == "F#6" then
            return 24
        end
    elseif instrument == 'bell' then
        if note == "G6" then
            return 13
        elseif note == "G#6" then
            return 14
        elseif note == "A6" then
            return 15
        elseif note == "A#6" then
            return 16
        elseif note == "B6" then
            return 17
        elseif note == "C7" then
            return 18
        elseif note == "C#7" then
            return 19
        elseif note == "D7" then
            return 20
        elseif note == "D#7" then
            return 21
        elseif note == "E7" then
            return 22
        elseif note == "F7" then
            return 23
        elseif note == "F#7" then
            return 24
        end
    end
end
 
run()
