import SwiftUI
import AVFoundation
import UIKit

struct MenuView: View {
    let buttons: [(label: String, imageName: String, destination: AnyView)] = [
        ("About Me", "user", AnyView(Screen1())),
        ("Task", "task", AnyView(Screen2())),
        ("lost", "information", AnyView(Screen3())),
        ("Item", "lostitems", AnyView(Screen4()))
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Menu")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<buttons.count, id: \.self) { index in
                        let button = buttons[index]
                        
                        NavigationLink(destination: button.destination) {
                            VStack(spacing: 10) {
                                Image(button.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // fill the space instead of fitting inside
                                    .frame(width: 100, height: 100)
                                    .clipped() // ensures it doesn't overflow

                                
                                Text(button.label)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}


// MARK: - Reusable Button View
struct MenuButton: View {
    let label: String
    let imageName: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.leading)

            Text(label)
                .font(.title2)
                .bold()
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    MenuView()
}
// ... all your MenuView and MenuButton code above

#Preview {
    MenuView()
}
 

struct Screen1: View {
    @State private var name = UserDefaults.standard.string(forKey: "name") ?? ""
    @State private var favoriteSongs: [String] = UserDefaults.standard.object(forKey: "favoriteSongs") as? [String] ?? []
    @State private var favoriteMovies: [String] = UserDefaults.standard.object(forKey: "favoriteMovies") as? [String] ?? []
    @State private var familyMembers: [String] = UserDefaults.standard.object(forKey: "familyMembers") as? [String] ?? []
    @State private var showAddItemSheet = false
    @State private var currentItem = ""
    @State private var currentCategory = "Song"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    VStack {
                        Text("Hello, \(name)!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Welcome to your customizable page")
                            .font(.title2)
                            .padding(.top, 5)
                    }

                    // Favorite Songs Section
                    VStack(alignment: .leading) {
                        Text("Favorite Songs")
                            .font(.title)
                            .fontWeight(.bold)

                        ForEach(favoriteSongs, id: \.self) { song in
                            Text(song)
                                .font(.headline)
                        }

                        Button(action: {
                            currentCategory = "Song"
                            showAddItemSheet = true
                        }) {
                            Text("Add Song")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()

                    // Favorite Movies Section
                    VStack(alignment: .leading) {
                        Text("Favorite Movies")
                            .font(.title)
                            .fontWeight(.bold)

                        ForEach(favoriteMovies, id: \.self) { movie in
                            Text(movie)
                                .font(.headline)
                        }

                        Button(action: {
                            currentCategory = "Movie"
                            showAddItemSheet = true
                        }) {
                            Text("Add Movie")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()

                    // Family Members Section
                    VStack(alignment: .leading) {
                        Text("Family Members")
                            .font(.title)
                            .fontWeight(.bold)

                        ForEach(familyMembers, id: \.self) { member in
                            Text(member)
                                .font(.headline)
                        }

                        Button(action: {
                            currentCategory = "Family"
                            showAddItemSheet = true
                        }) {
                            Text("Add Family Member")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Personalized Page")
            .sheet(isPresented: $showAddItemSheet) {
                AddItemSheet(currentCategory: $currentCategory, item: $currentItem, addItemAction: saveItem)
            }
        }
    }

    // Save item function
    func saveItem() {
        switch currentCategory {
        case "Song":
            favoriteSongs.append(currentItem)
            UserDefaults.standard.set(favoriteSongs, forKey: "favoriteSongs")
        case "Movie":
            favoriteMovies.append(currentItem)
            UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
        case "Family":
            familyMembers.append(currentItem)
            UserDefaults.standard.set(familyMembers, forKey: "familyMembers")
        default:
            break
        }
        currentItem = ""
    }
}

// Add Item Sheet for adding songs, movies, or family members
struct AddItemSheet: View {
    @Binding var currentCategory: String
    @Binding var item: String
    var addItemAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a New \(currentCategory)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            TextField("Enter \(currentCategory.lowercased())", text: $item)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addItemAction()
                item = ""
            }) {
                Text("Save \(currentCategory)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()

            Button(action: {
                item = ""
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct Screen1_Previews: PreviewProvider {
    static var previews: some View {
        Screen1()
    }
}




// MARK: - Task Model
struct Task: Identifiable, Codable {  // Make sure Task conforms to Codable
    let id = UUID()
    let timeRange: String
    let title: String
    let duration: String
    let iconName: String
    var isCompleted: Bool
}

// MARK: - ReminderViewModel for Managing Tasks
class ReminderViewModel: ObservableObject {
    @Published var tasks: [Task] = []

    init() {
        loadTasks() // Load tasks from UserDefaults when initializing
    }

    // Add a new task
    func addTask(timeRange: String, title: String, duration: String, iconName: String) {
        let newTask = Task(timeRange: timeRange, title: title, duration: duration, iconName: iconName, isCompleted: false)
        tasks.append(newTask)
        saveTasks() // Save tasks after adding a new task
    }

    // Save tasks to UserDefaults
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    // Load tasks from UserDefaults
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
    }
}


// MARK: - Screen2 (Reminder Screen)
struct Screen2: View {
    @StateObject var viewModel = ReminderViewModel()  // This will hold and manage tasks
    @State private var showNewTaskSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.tasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                        }
                    }
                    .padding()
                }
                
                // Floating "+" Button
                Button(action: {
                    showNewTaskSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
                .sheet(isPresented: $showNewTaskSheet) {
                    NewTaskView(viewModel: viewModel) // Passing the viewModel to the NewTaskView
                }

            }
            .navigationTitle("Reminders")
        }
    }
}

struct TaskRow: View {
    var task: Task
    @ObservedObject var viewModel: ReminderViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Image(systemName: task.iconName)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.timeRange)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)

                Text(task.duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                // Toggle task completion status and remove if completed
                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.tasks[index].isCompleted.toggle()

                    // If the task is completed, remove it from the list
                    if viewModel.tasks[index].isCompleted {
                        viewModel.tasks.remove(at: index)
                    }

                    viewModel.saveTasks()  // Save the updated tasks
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}




struct NewTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReminderViewModel
    
    @State private var taskTitle = ""
    @State private var taskTimeRange = Date()
    @State private var taskDuration = 30
    @State private var taskIcon = "alarm.fill"  // Default icon
    @State private var selectedColor: Color = .green
    
    let durations = [15, 30, 45, 60, 90]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title Section
                Text("New Task")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Task Name
                TextField("e.g. Read a Book", text: $taskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)

                // Start Time Picker
                VStack {
                    Text("When?")
                        .font(.title3)
                        .foregroundColor(.gray)
                    DatePicker(
                        "Start Time",
                        selection: $taskTimeRange,
                        displayedComponents: [.hourAndMinute, .date]
                    )
                    .labelsHidden()
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                // Duration Picker
                VStack {
                    Text("Duration")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Picker("Select Duration", selection: $taskDuration) {
                        ForEach(durations, id: \.self) { value in
                            Text("\(value)m").tag(value)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                
                // Color Selection
                VStack {
                    Text("Color")
                        .font(.title3)
                        .foregroundColor(.gray)
                    HStack {
                        ForEach([Color.pink, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                .padding()

                // Create Task Button
                Button(action: {
                    // Add the new task to the view model
                    viewModel.addTask(timeRange: formatTime(taskTimeRange), title: taskTitle, duration: "\(taskDuration) min", iconName: taskIcon)
                    dismiss()  // Close the sheet after saving
                }) {
                    Text("Create Task")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.title2)
                }
                .padding()

                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1)) // Background for the whole screen
            .cornerRadius(15)
            .shadow(radius: 10)
            .navigationTitle("New Task")
        }
    }
    
    // Helper to format time as HH:mm
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    Screen2()
}




struct Screen3: View {
    @State private var name = UserDefaults.standard.string(forKey: "name") ?? ""
    @State private var phone = UserDefaults.standard.string(forKey: "phone") ?? ""
    @State private var medical = UserDefaults.standard.string(forKey: "medical") ?? ""
    @State private var caretaker = UserDefaults.standard.string(forKey: "caretaker") ?? ""
    @State private var homeAddress = UserDefaults.standard.string(forKey: "homeAddress") ?? ""
    @State private var showCallAlert = false
    @State private var isEditing = false // Toggle edit mode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Name Field
                    Group {
                        Text("Name")
                            .font(.headline)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .disabled(!isEditing)  // Disable editing when not in edit mode
                    }
                    
                    // Medical Info Field
                    Group {
                        Text("Medical Info")
                            .font(.headline)
                        TextField("Enter your medical records", text: $medical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .disabled(!isEditing)
                    }
                    
                    // Home Address Field (replacing Medication Taken)
                    Group {
                        Text("Home Address")
                            .font(.headline)
                        TextField("Enter your home address", text: $homeAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .disabled(!isEditing)
                    }
                    
                    // Caretaker Phone Field
                    Group {
                        Text("Caretaker Phone")
                            .font(.headline)
                        TextField("Caretaker phone number", text: $caretaker)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .keyboardType(.phonePad)
                            .disabled(!isEditing)
                    }
                    
                    // Save Button
                    Button(action: {
                        saveData()  // Save data when the user presses Save
                    }) {
                        Text("Save Info")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                    }
                    .padding(.top, 30)
                    .disabled(!isEditing) // Disable save button when not in edit mode
                    
                    // Edit Button (Toggle between Edit and View modes)
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit Info")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isEditing ? Color.green : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Medical ID Info")
        }
    }

    // Save function to store data into UserDefaults
    func saveData() {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(medical, forKey: "medical")
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.set(caretaker, forKey: "caretaker")
        UserDefaults.standard.set(homeAddress, forKey: "homeAddress")  // Save the home address
    }
    
    // Function to make phone calls (not used in this code but can be implemented if needed)
    func makePhoneCall(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}



// MARK: - LostItem and AudioRecorder

struct LostItem: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var imageName: String
    var audioFileName: String
    var photoData: Data?  // Store the photo data as an optional field
}

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false

    func startRecording(fileName: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// MARK: - LostItemStore (Persistent Storage)

class LostItemStore: ObservableObject {
    @Published var items: [LostItem] = []

    private let fileName = "lostItems.json"
    
    init() {
        loadItems()
    }
    
    // Save LostItems to a JSON file
    func saveItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try? data.write(to: url)
        }
    }
    
    // Load LostItems from a JSON file
    func loadItems() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedItems = try? decoder.decode([LostItem].self, from: data) {
                self.items = decodedItems
            }
        }
    }
    
    // Get the documents directory URL
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// MARK: - ImagePicker for Taking Photos

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isImagePickerPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }

    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera // Use camera for capturing photos
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Screen4 (Lost Items)

struct Screen4: View {
    @StateObject private var lostItemStore = LostItemStore()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showRecordingSheet = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(lostItemStore.items) { item in
                        VStack {
                            Button(action: {
                                playAudio(named: item.audioFileName)
                            }) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(item.imageName)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)

                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                        .padding(8)
                                }
                            }
                            Text(item.name)
                                .font(.headline)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
            }

            Button(action: {
                showRecordingSheet = true
            }) {
                Text("Add / Edit Item Recording")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
            }
            .sheet(isPresented: $showRecordingSheet) {
                AddRecordingView { name, audioFile in
                    saveOrUpdateItem(name: name, audioFileName: audioFile)
                }
            }
            .navigationTitle("Lost Items")
        }
    }

    func playAudio(named name: String) {
        let fileURL: URL
        if let bundleURL = Bundle.main.url(forResource: name, withExtension: nil) {
            fileURL = bundleURL
        } else {
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func saveOrUpdateItem(name: String, audioFileName: String) {
        if let index = lostItemStore.items.firstIndex(where: { $0.name == name }) {
            lostItemStore.items[index].audioFileName = audioFileName
        } else {
            let newItem = LostItem(id: UUID(), name: name, imageName: "placeholder", audioFileName: audioFileName)
            lostItemStore.items.append(newItem)
        }
        lostItemStore.saveItems() // Save the updated list
    }
}

// MARK: - AddRecordingView

struct AddRecordingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var recorder = AudioRecorder()
    @State private var fileName = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    var onSave: (String, String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Record Audio for Item")
                .font(.title2)
                .padding(.top)

            TextField("Item name (e.g., Keys)", text: $fileName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if recorder.isRecording {
                    recorder.stopRecording()
                } else {
                    recorder.startRecording(fileName: fileName + ".m4a")
                }
            }) {
                Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(recorder.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: {
                showImagePicker = true
            }) {
                Text("Take a Photo of the Item")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $showImagePicker)
            }

            Spacer()

            Button("Save") {
                if recorder.isRecording {
                    recorder.stopRecording()
                }
                onSave(fileName, fileName + ".m4a")
                dismiss()
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    Screen4()
}
