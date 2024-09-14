//
//  KatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct KatasView: View {
    @Binding var katas: [Kata]
    
    var body: some View {
        List {
            ForEach(katas) { kata in
                Text(kata.name)
            }
        }
        .navigationTitle("Katas")
    }
}

// Preview Provider (Optional)
struct KatasView_Previews: PreviewProvider {
    @State static var katas = [
        Kata(name: "Heian Shodan", category: "Beginner"),
        Kata(name: "Heian Nidan", category: "Beginner")
    ]
    
    static var previews: some View {
        KatasView(katas: $katas)
    }
}
