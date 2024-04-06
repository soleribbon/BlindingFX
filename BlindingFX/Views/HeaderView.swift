//
//  HeaderView.swift
//  BlindingFX
//
//  Created by Ravi Heyne on 05/04/24.
//

import SwiftUI

struct HeaderView: View {

    //Extra - to use if I want to display the app version
    let officialAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String



    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("BlindingFX")
                    .bold()
                    .font(.title)
                    .foregroundColor(.primary)

                Text("Unleash your inner DJ")
                    .font(.title3)
                    .foregroundColor(.primary)

            }
            Spacer()
        }
    }
}


#Preview {
    HeaderView()
}
