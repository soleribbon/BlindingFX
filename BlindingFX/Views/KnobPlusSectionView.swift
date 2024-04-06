import SwiftUI
import AVFAudio
import Knob_iOS // Ensure you have this or a similar knob component.

struct PresetOption<Value>: Identifiable where Value: Hashable {
    let id = UUID()
    var name: String
    var value: Value
}

let distortionPresets = [
    PresetOption(name: "Drums LoFi", value: AVAudioUnitDistortionPreset.drumsLoFi),
    PresetOption(name: "Drums Bit Brush", value: AVAudioUnitDistortionPreset.drumsBitBrush),
    PresetOption(name: "Multi Broken Speaker", value: AVAudioUnitDistortionPreset.multiBrokenSpeaker),
    PresetOption(name: "Multi Distorted Cubed", value: AVAudioUnitDistortionPreset.multiDistortedCubed),
    PresetOption(name: "Multi Echo", value: AVAudioUnitDistortionPreset.multiEcho1),
    PresetOption(name: "Multi Echo Tight", value: AVAudioUnitDistortionPreset.multiEchoTight1),
    PresetOption(name: "Speech Golden Pi", value: AVAudioUnitDistortionPreset.speechGoldenPi),
    PresetOption(name: "Speech Radio Tower", value: AVAudioUnitDistortionPreset.speechRadioTower),
    PresetOption(name: "Speech Waves", value: AVAudioUnitDistortionPreset.speechWaves)
]
let reverbPresets = [
    PresetOption(name: "Large Hall", value: AVAudioUnitReverbPreset.largeHall),
    PresetOption(name: "Large Chamber", value: AVAudioUnitReverbPreset.largeChamber),
    PresetOption(name: "Medium Chamber", value: AVAudioUnitReverbPreset.mediumChamber),
    PresetOption(name: "Cathedral", value: AVAudioUnitReverbPreset.cathedral),
    PresetOption(name: "Medium Hall", value: AVAudioUnitReverbPreset.mediumHall),
    PresetOption(name: "Plate", value: AVAudioUnitReverbPreset.plate),
    PresetOption(name: "Medium Room", value: AVAudioUnitReverbPreset.mediumRoom),
    PresetOption(name: "Small Room", value: AVAudioUnitReverbPreset.smallRoom)
]


struct KnobPlusSectionView<Value>: View where Value: Hashable {
    var iconName: String
    var labelText: String
    @Binding var value: Float
    var minimumValue: Float
    var maximumValue: Float
    var resetValue: Float = 1.0
    var onChange: (Float) -> Void
    var onReset: () -> Void
    var trackColor: Color
    var progressColor: Color
    var indicatorColor: Color
    var presets: [PresetOption<Value>]
    @Binding var selectedPreset: Value
    var onPresetSelected: (Value) -> Void

    var body: some View {
        HStack(alignment: .center) {
            // Reset & unit display section
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    if labelText == "Speed" {
                        Text("\(Int(value * 100 - 100))")
                            .sliderUnitLabel()
                    } else {
                        Text(value == resetValue ? "0" : String(format: "%.f", value))
                            .sliderUnitLabel()
                    }
                }

                ZStack {
                    Button(action: {
                        onReset()
                    }) {
                        Text("Reset")
                            .resetLabel()
                    }
                    .opacity(value != resetValue ? 1 : 0)

                    Text("Default")
                        .defaultLabel()
                        .opacity(value == resetValue ? 1 : 0)
                }
                Spacer().frame(height: 20)
            }.padding(4)

            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Image(systemName: iconName)
                        .iconStyle()
                        .padding()
                    //                    Text(labelText)
                    //                        .sliderLabel()
                }


                KnobView(value: $value, manipulating: .constant(true),
                         minimum: minimumValue, maximum: maximumValue)
                .touchSensitivity(8)
                .trackStyle(widthFactor: 0.06, color: trackColor)
                .progressStyle(widthFactor: 0.06, color: progressColor)
                .indicatorStyle(widthFactor: 0.06, color: indicatorColor, length: 1)
                .onChange(of: value) { oldValue, newValue in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onChange(newValue)
                }
                .frame(minWidth: 100, maxWidth: 240, minHeight: 100, maxHeight: 240)
                .aspectRatio(1.0, contentMode: .fit)
                .accessibilityIdentifier("pan knob")


                Menu {
                    Picker("Select Preset", selection: $selectedPreset) {
                        ForEach(presets) { option in
                            Text(option.name).tag(option.value)
                        }
                    }
                } label: {
                    Text("Change \(labelText)")
                        .underline()
                        .font(.caption)
                        .foregroundColor(.primary)
                        .opacity(0.75)
                }
                .onChange(of: selectedPreset) { oldValue, newValue in
                    onPresetSelected(newValue)
                    print($selectedPreset)
                }



            }
        }
    }

}
