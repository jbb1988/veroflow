import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(.white)
            Text("You are offline. Changes will be saved locally.")
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red)
    }
}

struct OfflineBannerView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineBannerView()
    }
}

