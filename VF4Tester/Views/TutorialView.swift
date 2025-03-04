import SwiftUI

struct TutorialView: View {
    @Binding var showTutorial: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to the Tutorial")
                    .font(.largeTitle)
                    .bold()
                Text("This tutorial will guide you through the key features of the VEROflow-4 Field Tester.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Button("Got it!") {
                    showTutorial = false
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("MarsBlue"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Tutorial")
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(showTutorial: .constant(true))
    }
}

