


import SwiftUI
import SwiftData
struct ContentView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Who are you?")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.bottom, 10)
                LazyVGrid(columns: columns, spacing: 20) {
                    NavigationLink(destination: LoginView()) {
                        VStack {
                            Image("caregiver")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 120)
                            Text("Caregiver")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    NavigationLink(destination: MenuView()) {
                        VStack {
                            Image("client")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 120)
                            Text("Client")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}
struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
#Preview {
    ContentView()
}
