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
                        .onChange(of: audioFileURL) { newURL in
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

                    //slider view
                    VStack {


                        HStack (alignment: .center){
                            Text("File Name: ")
                                .bold()
                                .foregroundColor(.black)
                            Text(audioFileURL?.lastPathComponent ?? "Energetic.wav")
                                .lineLimit(1)
                                .foregroundColor(.black)
                        }
                        .font(.title3)
                        .padding()




                        //begginng of one slider section
                        HStack (alignment: .center){

                            VStack (alignment: .center) {
                                Image(systemName: "tuningfork")
                                    .iconStyle()

                                Text("Pitch")
                                    .sliderLabel()

                            }.frame(width: labelWidth)

                            Slider(value: $pitchSliderValue, in: -1500...1500, step: 50, onEditingChanged: { _ in
                                easyPlayer.setPitch(pitchSliderValue)
                            })
                            .padding(.horizontal)
                            .accentColor(.blue)

                            //reset & unit display section
                            VStack (alignment: .trailing){
                                Text($pitchSliderValue.wrappedValue == 1 ? "0" : String(format: "%.f", $pitchSliderValue.wrappedValue))
                                    .sliderUnitLabel()


                                if pitchSliderValue != 1.0 {
                                    Button(action: {
                                        pitchSliderValue = 1.0
                                        easyPlayer.setPitch(pitchSliderValue)

                                    }, label: {
                                        Text("Reset")
                                            .resetLabel()

                                    })
                                }else{
                                    Text("Default")
                                        .defaultLabel()
                                }
                            }

                        }.padding()

                        HStack (alignment: .center){

                            VStack (alignment: .center) {
                                Image(systemName: "hare.fill")
                                    .iconStyle()

                                Text("Speed")
                                    .sliderLabel()

                            }.frame(width: labelWidth)

                            Slider(value: $speedSliderValue, in: 0.5...1.5, step: 0.01, onEditingChanged: { _ in
                                easyPlayer.setSpeed(speedSliderValue)
                            })
                            .padding(.horizontal)
                            .accentColor(.green)

                            //reset & unit display section
                            VStack (alignment: .trailing){
                                Text("\(Int($speedSliderValue.wrappedValue * 100))")
                                    .sliderUnitLabel()


                                if speedSliderValue != 1.0 {
                                    Button(action: {
                                        speedSliderValue = 1.0
                                        easyPlayer.setSpeed(speedSliderValue)

                                    }, label: {
                                        Text("Reset")
                                            .resetLabel()
                                    })
                                }else{
                                    Text("Default")
                                        .defaultLabel()
                                }
                            }

                        }.padding()

                        //next one
                        HStack (alignment: .center){

                            VStack (alignment: .center) {
                                Image(systemName: "waveform.path")
                                    .iconStyle()

                                Text("Distortion")
                                    .sliderLabel()

                                Menu {

                                    Picker(selection: $selectedDistortionPreset, label: Label("Change Preset", systemImage: "slider.vertical.3")) {
                                        Text("Drums LoFi").tag(AVAudioUnitDistortionPreset.drumsLoFi)
                                        Text("Drums Bit Brush").tag(AVAudioUnitDistortionPreset.drumsBitBrush)
                                        Text("Multi Broken Speaker").tag(AVAudioUnitDistortionPreset.multiBrokenSpeaker)
                                        Text("Multi Distorted Cubed").tag(AVAudioUnitDistortionPreset.multiDistortedCubed)
                                        Text("Multi Echo").tag(AVAudioUnitDistortionPreset.multiEcho1)
                                        Text("Multi Echo Tight").tag(AVAudioUnitDistortionPreset.multiEchoTight1)
                                        Text("Speech Golden Pi").tag(AVAudioUnitDistortionPreset.speechGoldenPi)
                                        Text("Speech Radio Tower").tag(AVAudioUnitDistortionPreset.speechRadioTower)
                                        Text("Speech Waves").tag(AVAudioUnitDistortionPreset.speechWaves)
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .tint(.black)
                                    .scaledToFit()



                                    .onChange(of: selectedDistortionPreset) { preset in
                                        easyPlayer.setDistortionPreset(preset)
                                        //to make sure mix stays the same
                                        easyPlayer.setDistortion(distortionSliderValue)
                                    }
                                }label: {
                                    Text(labelForPreset(selectedDistortionPreset))
                                        .font(.body)
                                        .underline()
                                        .foregroundColor(.black)
                                }


                            }.frame(width: labelWidth)

                            Slider(value: $distortionSliderValue, in: 0...100, step: 1, onEditingChanged: { _ in
                                easyPlayer.setDistortion(distortionSliderValue)
                            })
                            .padding(.horizontal)
                            .accentColor(.orange)

                            //reset & unit display section
                            VStack (alignment: .trailing){
                                Text(String(format: "%.0f", $distortionSliderValue.wrappedValue))
                                    .sliderUnitLabel()

                                if distortionSliderValue != 0.0 {
                                    Button(action: {
                                        distortionSliderValue = 0.0
                                        easyPlayer.setDistortion(distortionSliderValue)

                                    }, label: {
                                        Text("Reset")
                                            .resetLabel()

                                    })
                                }else{
                                    Text("Default")
                                        .defaultLabel()
                                }
                            }

                        }.padding()

                        HStack (alignment: .center){

                            VStack (alignment: .center) {
                                Image(systemName: "wave.3.forward")
                                    .iconStyle()
                                Text("Reverb")
                                    .sliderLabel()

                                Menu {
                                    Picker(selection: $selectedReverbPreset, label: Label("Change Preset", systemImage: "slider.vertical.3")) {
                                        Text("Large Hall").tag(AVAudioUnitReverbPreset.largeHall)
                                        Text("Large Chamber").tag(AVAudioUnitReverbPreset.largeChamber)
                                        Text("Medium Chamber").tag(AVAudioUnitReverbPreset.mediumChamber)
                                        Text("Cathedral").tag(AVAudioUnitReverbPreset.cathedral)
                                        Text("Medium Hall").tag(AVAudioUnitReverbPreset.mediumHall)
                                        Text("Plate").tag(AVAudioUnitReverbPreset.plate)
                                        Text("Medium Room").tag(AVAudioUnitReverbPreset.mediumRoom)
                                        Text("Small Room").tag(AVAudioUnitReverbPreset.smallRoom)
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .tint(.black)
                                    .scaledToFit()

                                    .onChange(of: selectedReverbPreset) { preset in
                                        easyPlayer.setReverbPreset(preset)
                                    }

                                }label: {
                                    Text(labelForPreset(selectedReverbPreset))
                                        .font(.body)
                                        .underline()
                                        .foregroundColor(.black)
                                }
                            }.frame(width: labelWidth)

                            Slider(value: $reverbSliderValue, in: 0...100, step: 1, onEditingChanged: { _ in
                                easyPlayer.setReverb(reverbSliderValue)
                            })
                            .padding(.horizontal)
                            .accentColor(.red)

                            //reset & unit display section
                            VStack (alignment: .trailing){
                                Text(String(format: "%.0f", $reverbSliderValue.wrappedValue))
                                    .sliderUnitLabel()

                                if reverbSliderValue != 0.0 {
                                    Button(action: {
                                        reverbSliderValue = 0.0
                                        easyPlayer.setReverb(reverbSliderValue)

                                    }, label: {
                                        Text("Reset")
                                            .resetLabel()

                                    })
                                }else{
                                    Text("Default")
                                        .defaultLabel()
                                }
                            }

                        }.padding()





                    }
                    .padding()
                    .cornerRadius(14)
                    .background(

                        RoundedRectangle(cornerRadius: 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 1, y: 1)
                                    .mask(RoundedRectangle(cornerRadius: 14)
                                        .fill(LinearGradient(Color.black, Color.clear))
                                        .background(.white))
                                    .background(.white)
                                    .cornerRadius(14)
                            )



                    )



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
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .padding(.horizontal, 100)
                            .foregroundColor(.primary)

                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .strokeBorder(Color(#colorLiteral(red: 0.9375, green: 0.9375, blue: 0.9375, alpha: 1)), lineWidth: 2)

                            ).background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(.green)
                                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.10000000149011612)), radius:7, x:0, y:2)
                            )
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



//Extra documentation to explain more obscure functions

// Struct representing a document picker to allow the user to pick an audio file
struct DocumentPicker: UIViewControllerRepresentable {
    // Access the environment's presentation mode to control dismissal of the view
    @Environment(\.presentationMode) var presentationMode
    // A completion handler for when a file is picked
    @Binding var completionHandler: ((URL) -> Void)?
    // A binding to a URL representing the chosen audio file
    @Binding var audioFileURL: URL?

    // Creates a coordinator for managing the document picker's delegate callbacks
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    // Creates the view controller that represents the document picker
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        // Define supported audio file types
        let audioTypes: [UTType] = [UTType.mp3, UTType.wav]
        // Create a document picker with supported file types
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: audioTypes, asCopy: true)
        // Set the coordinator as the document picker's delegate
        picker.delegate = context.coordinator
        return picker
    }

    // Updates the view controller - no action needed here
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }

    // class for coordinating the document picker's delegate callbacks
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        // reference to the DocumentPicker instance
        var parent: DocumentPicker

        // Initialize the coordinator with a reference to the parent document picker
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        // Called when the user picks a document
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Set the parent's audioFileURL to the first URL in the array
            parent.audioFileURL = urls.first
            // Dismiss the document picker
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Called when the user cancels the document picker
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Dismiss the document picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//Go-to styling for different elements
extension Text {
    // Style for slider label
    func sliderLabel() -> Text {
        return self
            .bold()
            .foregroundColor(.black)
    }

    // Style for reset label
    func resetLabel() -> Text {
        return self
            .foregroundColor(.red)
            .underline()
            .bold()
            .font(.body)
    }

    // Style for slider unit label
    func sliderUnitLabel() -> Text {
        return self
            .font(.title2)
            .foregroundColor(.black)
            .bold()
    }

    // Default style for labels
    func defaultLabel() -> Text {
        return self
            .font(.caption)
            .foregroundColor(.gray)
    }
}

// ViewModifier to apply a consistent icon style
struct IconStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.black)
    }
}

// Icon style
extension Image {
    func iconStyle() -> some View {
        self.modifier(IconStyle())
    }
}
//For VStack Gradient
extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    ContentView()
}
