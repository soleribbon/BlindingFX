//
//  ContentView.swift
//  BlindingFX
//
//  Created by Ravi Heyne on 05/04/24.
//

import AVFoundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Knob_iOS
struct ContentView: View {
    @ObservedObject var easyPlayer = EasyPlayer()

    @State var isPlaying = false

    @State var sliderValue: Float = 0.0 //playback
    @State var pitchSliderValue: Float = 1.0
    @State var speedSliderValue: Float = 1.0
    @State var reverbSliderValue: Float = 0.0
    @State var distortionSliderValue: Float = 0.0





    @State var selectedReverbPreset: AVAudioUnitReverbPreset = .largeHall
    @State var selectedDistortionPreset: AVAudioUnitDistortionPreset = .drumsLoFi

    let buttonHaptic = UIImpactFeedbackGenerator(style: .medium)
    @State var generalManipulating: Bool = false
    //General bool to track manipulation across all knobs

    @State var audioFileURL: URL? = nil
    @State var showDocumentPicker = false

    var body: some View {

        GeometryReader { geometry in
            let labelWidth = geometry.size.width * 0.14

            VStack {
                VStack {
                    HStack {
                        HeaderView().padding(6)

                        Button(action: {
                            buttonHaptic.impactOccurred()

                            if isPlaying {
                                easyPlayer.pause()
                                isPlaying.toggle()
                                showDocumentPicker.toggle()
                                //file selector
                            } else {
                                showDocumentPicker.toggle()

                                //file selector
                            }
                        }) {
                            Text("Load Song")
                                .bold()
                                .foregroundColor(.black)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .strokeBorder(Color(#colorLiteral(red: 0.9375, green: 0.9375, blue: 0.9375, alpha: 1)), lineWidth: 2)

                                ).background(
                                    RoundedRectangle(cornerRadius: 40)
                                        .fill(.white)
                                        .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.10000000149011612)), radius:7, x:0, y:2)
                                )
                        }
                        .onChange(of: audioFileURL) { oldURL, newURL in
                            if let url = newURL {
                                //resetting everything
                                easyPlayer.loadAudioFile(from: url)
                                sliderValue = 0.0
                                easyPlayer.seekTo(time: sliderValue)
                                easyPlayer.pause()
                                isPlaying = false


                            }
                        }
                        .sheet(isPresented: $showDocumentPicker) {
                            DocumentPicker(completionHandler: .constant { url in
                                audioFileURL = url

                            }, audioFileURL: $audioFileURL)
                        }

                    }
                    Spacer()
                    //slider view
                    VStack (alignment: .center){

                        HStack (alignment: .center){
                            Text("Now Editing: ")
                                .bold()
                                .foregroundColor(.primary)
                            Text(audioFileURL?.lastPathComponent ?? "Energetic.wav")
                                .lineLimit(1)
                                .foregroundColor(.primary)
                        }
                        .font(.subheadline)


                        //FIRST ROW HSTACK
                        HStack (alignment: .center){
                            //PITCH
                            KnobSectionView(
                                iconName: "tuningfork",
                                labelText: "Pitch",
                                value: $pitchSliderValue,
                                minimumValue: -1000,
                                maximumValue: 1000,
                                resetValue: 1.0,
                                onChange: { newValue in
                                    easyPlayer.setPitch(newValue)
                                },
                                onReset: {
                                    pitchSliderValue = 1.0
                                    easyPlayer.setPitch(pitchSliderValue)
                                },
                                trackColor: .gray,
                                progressColor: .gray,
                                indicatorColor: .green
                            )
                            //SPEED
                            KnobSectionView(
                                iconName: "hare.fill",
                                labelText: "Speed",
                                value: $speedSliderValue,
                                minimumValue: 0.5,
                                maximumValue: 1.5,
                                resetValue: 1.0,
                                onChange: { newValue in
                                    easyPlayer.setSpeed(newValue)
                                },
                                onReset: {
                                    speedSliderValue = 1.0
                                    easyPlayer.setSpeed(speedSliderValue)
                                },
                                trackColor: .gray,
                                progressColor: .gray,
                                indicatorColor: .blue
                            )





                        }


                        HStack (alignment: .center){
                            //DISTORTION




                            VStack (alignment: .trailing) {
                                KnobPlusSectionView(
                                    iconName: "waveform.path",
                                    labelText: "Distortion",
                                    value: $distortionSliderValue,
                                    minimumValue: 0,
                                    maximumValue: 100,
                                    resetValue: 0.0,
                                    onChange: { newValue in
                                        easyPlayer.setDistortion(distortionSliderValue)
                                    },
                                    onReset: {
                                        distortionSliderValue = 0.0
                                        easyPlayer.setDistortion(distortionSliderValue)
                                    },
                                    trackColor: .gray,
                                    progressColor: .orange,
                                    indicatorColor: .orange,
                                    presets: distortionPresets,
                                    selectedPreset: $selectedDistortionPreset,
                                    onPresetSelected: { newValue in
                                        easyPlayer.setDistortionPreset(newValue)
                                    }
                                )

                            }


                            VStack (alignment: .trailing){

                                KnobPlusSectionView(
                                                iconName: "wave.3.forward",
                                                labelText: "Reverb",
                                                value: $reverbSliderValue,
                                                minimumValue: 0,
                                                maximumValue: 100,
                                                resetValue: 0.0,
                                                onChange: { newValue in
                                                    easyPlayer.setReverb(newValue)
                                                },
                                                onReset: {
                                                    reverbSliderValue = 0.0
                                                    easyPlayer.setReverb(reverbSliderValue)
                                                },
                                                trackColor: .gray,
                                                progressColor: .red,
                                                indicatorColor: .red,
                                                presets: reverbPresets,
                                                selectedPreset: $selectedReverbPreset,
                                                onPresetSelected: { newValue in
                                                    easyPlayer.setReverbPreset(newValue)
                                                }
                                            )

                                
                            }



                        }

                    }

                    Spacer()




                    //playbackSlider and timestamps
                    VStack (alignment: .center){
                        HStack {
                            Text(timeString(from: sliderValue))
                                .foregroundColor(.gray)

                            Spacer()
                            Text(timeString(from: easyPlayer.lengthSongSeconds))
                                .foregroundColor(.gray)

                        }
                        Slider(value: $sliderValue, in: 0...easyPlayer.lengthSongSeconds, step: 0.01, onEditingChanged: { editing in
                            if !editing {
                                easyPlayer.seekTo(time: sliderValue)
                                if !isPlaying {
                                    isPlaying = true
                                    easyPlayer.play()
                                }
                            }
                        })
                        .accentColor(.secondary)
                        .padding(.horizontal)

                    }.padding(.horizontal)



                    //bottom buttons
                    HStack (alignment: .center) {

                        Button(action: {
                            buttonHaptic.impactOccurred()

                            if isPlaying {
                                easyPlayer.pause()
                            } else {
                                easyPlayer.play()
                            }
                            isPlaying.toggle()
                        }) {
                            HStack{
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.largeTitle)

                            }
                            .padding()
                            .padding(.horizontal, 100)
                            .foregroundColor(.primary)


                        }


                    }



                }
                .padding()


            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    sliderValue = easyPlayer.getCurrentPosition()
                    if sliderValue >= easyPlayer.lengthSongSeconds {
                        timer.invalidate() // stop the timer if audio has finished playing
                    }
                }
            }
        }
    }

    //To format playback time display
    func timeString(from seconds: Float) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    //for preset picker labels
    func labelForPreset(_ preset: Any) -> String {
        if let distortionPreset = preset as? AVAudioUnitDistortionPreset {
            switch distortionPreset {
            case .drumsLoFi:
                return "Drums LoFi"
            case .drumsBitBrush:
                return "Drums Bit Brush"
            case .multiBrokenSpeaker:
                return "Multi Broken Speaker"
            case .multiDistortedCubed:
                return "Multi Distorted Cubed"
            case .multiEcho1:
                return "Multi Echo"
            case .multiEchoTight1:
                return "Multi Echo Tight"
            case .speechGoldenPi:
                return "Speech Golden Pi"
            case .speechRadioTower:
                return "Speech Radio Tower"
            case .speechWaves:
                return "Speech Waves"
            default:
                return "Unknown"
            }
        } else if let reverbPreset = preset as? AVAudioUnitReverbPreset {
            switch reverbPreset {
            case .largeHall:
                return "Large Hall"
            case .largeChamber:
                return "Large Chamber"
            case .mediumChamber:
                return "Medium Chamber"
            case .cathedral:
                return "Cathedral"
            case .mediumHall:
                return "Medium Hall"
            case .plate:
                return "Plate"
            case .mediumRoom:
                return "Medium Room"
            case .smallRoom:
                return "Small Room"
            default:
                return "Unknown"
            }
        } else {
            return "Unknown"
        }
    }


}

#Preview {
    ContentView()
}
