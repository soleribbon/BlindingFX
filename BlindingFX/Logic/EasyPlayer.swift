//
//  EasyPlayer.swift
//  BlindingFX
//
//  Created by Ravi Heyne on 05/04/24.
//


import AVFoundation

class EasyPlayer: ObservableObject {

    // Audio engine for managing and playing audio
    var engine: AVAudioEngine! = AVAudioEngine()
    // Node for playing audio files
    var player: AVAudioPlayerNode! = AVAudioPlayerNode()
    // Audio file to be played
    var audioFile: AVAudioFile!
    // Total samples in the audio file
    var songLengthSamples: AVAudioFramePosition!


    // Sample rate of the audio file
    var sampleRateSong: Float = 0
    // Length of the audio file in seconds
    var lengthSongSeconds: Float = 0
    // Current position within the audio file
    var startInSongSeconds: Float = 0

    // Audio effect nodes
    let pitch: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let reverb: AVAudioUnitReverb = AVAudioUnitReverb()
    let distortion: AVAudioUnitDistortion = AVAudioUnitDistortion()

    // Presets for the audio effect nodes
    var selectedReverbPreset: AVAudioUnitReverbPreset?
    var selectedDistortionPreset: AVAudioUnitDistortionPreset?



    init() {

        //Handles playing sound when ringer is off
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            // report for an error
        }
        //Sets volume
        player.volume = 1.0

        // Load the default audio file and initialize the audio engine
        if let path = Bundle.main.path(forResource: "Energetic", ofType: "mp3"),
           let url = NSURL.fileURL(withPath: path) as URL? {
            print(url)

            // Load the audio file and set up playback
            do {
                audioFile = try AVAudioFile(forReading: url)
            } catch {
                print("Error loading audio file: \(error)")
                return
            }

            songLengthSamples = audioFile.length

            let songFormat = audioFile.processingFormat
            sampleRateSong = Float(songFormat.sampleRate)
            lengthSongSeconds = Float(songLengthSamples) / sampleRateSong

            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            do {
                try audioFile.read(into: buffer!)
            } catch {
                print("Error reading audio file: \(error)")
            }

            pitch.pitch = 1
            pitch.rate = 1

            reverb.loadFactoryPreset(.largeHall)
            selectedReverbPreset = .largeHall // set the default preset
            reverb.wetDryMix = 0

            distortion.loadFactoryPreset(.drumsLoFi)
            selectedDistortionPreset = .drumsLoFi // set the default preset
            distortion.wetDryMix = 0

            // Attach the nodes to the engine
            engine.attach(player)
            engine.attach(pitch)
            engine.attach(reverb)
            engine.attach(distortion)

            // Connect the nodes in the audio engine
            connectNodes()

            // Schedule the buffer for playback and start the engine
            player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            engine.prepare()

            do {
                try engine.start()


            } catch _ {
                print("Error starting audio engine")
            }
        }
    }


    func loadAudioFile(from url: URL) {

        print(url)
        //Stop previous player and engine (to enable new file playback)
        resetPlayer()

        // Load the audio file and set up playback
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Error loading audio file: \(error)")
            return
        }

        songLengthSamples = audioFile.length

        let songFormat = audioFile.processingFormat
        sampleRateSong = Float(songFormat.sampleRate)
        lengthSongSeconds = Float(songLengthSamples) / sampleRateSong


        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        do {
            try audioFile.read(into: buffer!)
        } catch _ {
        }



        pitch.pitch = 1
        pitch.rate = 1

        reverb.loadFactoryPreset(.largeHall)
        selectedReverbPreset = .largeHall // set the default preset
        reverb.wetDryMix = 0

        distortion.loadFactoryPreset(.drumsLoFi)
        selectedDistortionPreset = .drumsLoFi // set the default preset
        distortion.wetDryMix = 0

        engine.attach(player)
        engine.attach(pitch)
        engine.attach(reverb)
        engine.attach(distortion)

        connectNodes()

        player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        engine.prepare()
        do {
            try engine.start()


        } catch _ {
            print("Error starting audio engine")
        }

    }

    deinit {
        engine.stop()
        engine.detach(player)
        engine.detach(pitch)
        engine.detach(reverb)
        engine.detach(distortion)

    }

    func setSpeed(_ pitch: Float) {
        self.pitch.rate = pitch
    }

    func setPitch(_ pitch: Float) {
        self.pitch.pitch = pitch
    }
    func setReverb(_ value: Float) {
        reverb.wetDryMix = value
    }

    func setReverbPreset(_ preset: AVAudioUnitReverbPreset) {
        selectedReverbPreset = preset
        reverb.loadFactoryPreset(preset)
    }

    func setDistortion(_ value: Float) {
        distortion.wetDryMix = value
    }
    func setDistortionPreset(_ preset: AVAudioUnitDistortionPreset) {
        selectedDistortionPreset = preset
        distortion.loadFactoryPreset(preset)
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    // Function to get the current position within the audio file
    func getCurrentPosition() -> Float {
        // Check if the player is currently playing
        if player.isPlaying {
            // Obtain the last render time and the corresponding player time
            if let nodeTime = player.lastRenderTime, let playerTime = player.playerTime(forNodeTime: nodeTime) {
                // Calculate the elapsed seconds in the audio file
                let elapsedSeconds = startInSongSeconds + (Float(playerTime.sampleTime) / Float(sampleRateSong))
                // Return the current position within the audio file in seconds
                return elapsedSeconds
            }
        }
        // If the player is not playing, return the start position
        return startInSongSeconds
    }

    // Function to seek to a specific time in the audio file
    func seekTo(time: Float) {
        // Stop the player before seeking
        player.stop()

        // Set the start position for the new segment
        startInSongSeconds = time
        // Calculate the start sample based on the time and sample rate
        let startSample = floor(time * sampleRateSong)
        // Calculate the number of samples left after seeking
        let lengthSamples = Float(songLengthSamples) - startSample

        // Schedule the new segment of the audio file for playback
        player.scheduleSegment(audioFile, startingFrame: AVAudioFramePosition(startSample), frameCount: AVAudioFrameCount(lengthSamples), at: nil, completionHandler: nil)
        // Resume playback from the new position
        player.play()
    }

    func resetPlayer() {
        print("Resetting Player")
        player.stop()
        engine.stop()
        player.reset()
    }

    func connectNodes() {
        print("Connecting Nodes")
        let bufferFormat = audioFile.processingFormat
        engine.connect(player, to: pitch, format: bufferFormat)
        engine.connect(pitch, to: distortion, format: bufferFormat)
        engine.connect(distortion, to: reverb, format: bufferFormat)
        engine.connect(reverb, to: engine.mainMixerNode, format: bufferFormat)

    }

}

