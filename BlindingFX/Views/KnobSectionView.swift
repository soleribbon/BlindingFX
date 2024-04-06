import SwiftUI
import Knob_iOS

struct KnobSectionView: View {
    var iconName: String
    var labelText: String
    @Binding var value: Float
    var minimumValue: Float
    var maximumValue: Float
    var resetValue: Float = 1.0
    var onChange: (Float) -> Void
    var onReset: () -> Void

    // Color variables for customization
    var trackColor: Color
    var progressColor: Color
    var indicatorColor: Color

    var body: some View {
        HStack(alignment: .center) {
            // Reset & unit display section
            VStack(alignment: .trailing) {
                HStack (alignment: .center){
                    Spacer()
                    if labelText == "Speed" {
                        Text("\(Int(value * 100 - 100))")
                            .sliderUnitLabel()
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    } else {
                        Text(value == resetValue ? "0" : String(format: "%.f", value))
                            .sliderUnitLabel()
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)


                    }
                }.frame(maxWidth: 50)


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
                .touchSensitivity(6)
                .trackStyle(widthFactor: 0.06, color: trackColor)
                .progressStyle(widthFactor: 0.06, color: progressColor)
                .indicatorStyle(widthFactor: 0.06, color: indicatorColor, length: 1)
                .onChange(of: value) { oldValue, newValue in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onChange(newValue)
                }

                .aspectRatio(1.0, contentMode: .fit)
                .accessibilityIdentifier("pan knob")


            }
            .padding(6)

        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1) 
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
