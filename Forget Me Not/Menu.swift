import SwiftUI
import AVFoundation
import UIKit
import UserNotifications



struct MenuView: View {
    @StateObject private var reminderVM = ReminderViewModel()
    @StateObject private var moodStore = LastMoodStore()


    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var buttons: [(label: String, imageName: String, destination: (ReminderViewModel) -> AnyView)] {
        [
            ("Task", "task", { vm in AnyView(Screen2().environmentObject(vm)) }),
            ("AboutMe", "aboutme", { _ in AnyView(Screen1()) }),
            ("lost", "lost", { _ in AnyView(Screen3()) }),
            ("item", "item", { _ in AnyView(Screen4()) }),
            ("hazard", "hazard", { _ in AnyView(Screen5()) }),
            ("Object Identifier", "objectfinder", { _ in AnyView(TapTapGoView()) }),
            ("Mood", "moodicon", { _ in AnyView(MoodLoggerView(moodStore: moodStore)) })
        ]
    }



    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 50) {
                    Text("Menu")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    // Upcoming Events Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Events")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)

                        if reminderVM.sortedTasks.isEmpty {
                            Text("No upcoming tasks.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(reminderVM.sortedTasks.prefix(3)) { task in
                                HStack(spacing: 16) {
                                    Image(systemName: task.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50) // slightly increased icon size
                                        .padding()
                                        .background(colorFromHex(task.colorHex))
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
 
                                    Text("Menu")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(.top)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(task.title)
                                            .font(.title) // ⬅️ made this MUCH larger
                                            .bold()

                                        Text(task.timeRange)
                                            .font(.title2) // Bigger font
                                            .bold()        // Emphasize
                                            .foregroundColor(.primary) // Dark text for visibility

                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color.teal.opacity(0.2))
                                .cornerRadius(20)
                                .padding(.horizontal, 10)
                            }

                            
                        }
                    }
                    //.padding(.bottom)
                    if !moodStore.lastMoodEmoji.isEmpty {
                        VStack(spacing: 4) {
                            Text("Last Logged Mood")
                                .font(.title)
                                .bold()
                                .padding(.bottom, 4)

                            Text(moodStore.lastMoodEmoji)
                                .font(.system(size: 50)) // Make the emoji very large
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(20)
                    }



                    LazyVGrid(columns: columns, spacing: 80) { // <- Increase vertical spacing
                        ForEach(buttons, id: \.label) { button in
                            NavigationLink(destination: button.destination(reminderVM)) {
                                Image(button.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(20)
                                    .frame(width: 285, height: 280)
                                    .shadow(radius: 5)
                                    .padding(30) // Optional: add spacing *within* the image frame
                            }
                            .frame(height: 210) // Consistent button height
                            .padding(.horizontal, 4) // Slight spacing between columns
                        }
                    }
                    .padding(.horizontal, 30) // Outer padding


                    Spacer()
                }
            }
        }
    }
}



// MARK: - Reusable Button View
struct MenuButton: View {
    let label: String
    let imageName: String

    var body: some View {
        HStack { /// arranges in side by side view
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)  // Increase size of the icon
                .padding(.leading)

            Text(label)
                .font(.title2) // This will automatically scale based on the user’s preference
                .bold()
                .padding()
                .foregroundColor(.primary)  // Ensure contrast for readability

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 100)  // Increase the button size
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
    }
}


#Preview {
    MenuView()
}
// ... all your MenuView and MenuButton code above
struct PersonalFact: Identifiable, Codable {
    let id: UUID
    var category: String
    var value: String
    var colorHex: String
}

struct FamilyMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var photoData: Data?
}

class PersonalStore: ObservableObject {
    @Published var facts: [PersonalFact] = []
    private let key = "personalFacts"

    init() {
        load()
    }

    func add(fact: PersonalFact) {
        facts.append(fact)
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(facts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PersonalFact].self, from: data) {
            facts = decoded
        }
    }
}

class FamilyStore: ObservableObject {
    @Published var members: [FamilyMember] = []
    private let key = "familyMembersData"

    init() {
        load()
    }

    func add(member: FamilyMember) {
        members.append(member)
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FamilyMember].self, from: data) {
            members = decoded
        }
    }
}

struct Screen1: View {
    @StateObject private var store = PersonalStore()
    @StateObject private var familyStore = FamilyStore()
    @State private var showAddSheet = false
    @State private var showAddFamily = false
    @State private var selectedFact: PersonalFact? = nil

    var groupedFacts: [String: [PersonalFact]] {
        Dictionary(grouping: store.facts, by: { $0.category })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                  

                    ForEach(groupedFacts.keys.sorted(), id: \.self) { category in

                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            // Inside each category section
                            FlowLayoutView(items: groupedFacts[category] ?? []) { fact in
                                Text(fact.value)
                                    .font(.title3) // Upgrade from .headline or .body
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 15)
                                    .background(colorFromHex(fact.colorHex).opacity(0.3))
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedFact = fact
                                    }
                            }

                            .padding(.horizontal)

                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Text("Family Members")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                        ForEach(familyStore.members) { member in
                            VStack(spacing: 8) {
                                if let data = member.photoData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 140, height: 140)
                                        .overlay(Image(systemName: "person.fill").font(.largeTitle))
                                }
                                Text(member.name)
                                    .font(.title3.bold())
                            }
                        }// images stored in user data and loops through for each checkking
                    }
                    // turns binary data into actual image uiimage if no data then place hodler shwos up
                    .padding(.horizontal)

  

                    HStack {
                        Button(action: {
                            showAddSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Info")
                                    .font(.title3.bold()) // larger text
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60) // make button taller
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }

                        Button(action: {
                            showAddFamily = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Family")
                                    .font(.title3.bold())
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60) // make button taller
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("About Me")
        }
        .sheet(isPresented: $showAddSheet) {
            AddInfoView(store: store)// opens a form ontop of the screen
        }
        .sheet(isPresented: $showAddFamily) {
            AddFamilyMemberView(store: familyStore)
        }
        .sheet(item: $selectedFact) { fact in
            EditInfoView(store: store, fact: fact)
        }
    }
}
// Simple flow layout view that wraps items in horizontal flow
struct FlowLayoutView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let items: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items) { item in
                content(item)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3))
                    )
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item.id == items.last?.id {
                            width = 0 // reset at end
                        } else {
                            width -= dimension.width + 8
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item.id == items.last?.id {
                            height = 0 // reset at end
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { binding.wrappedValue = $0 }
    }

    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 } // ✅ Use computed property

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

}

struct AddInfoView: View {
    @Environment(\ .dismiss) var dismiss
    @ObservedObject var store: PersonalStore

    @State private var category = ""
    @State private var value = ""
    @State private var selectedColor: Color = .blue

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Information")
                .font(.title.bold())

            TextField("Category (e.g., Favorite Food)", text: $category)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Your Answer", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Text("Choose a Color")
            HStack {
                ForEach([Color.red, .green, .blue, .orange, .purple, .pink], id: \ .self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            Button("Save") {
                let fact = PersonalFact(
                    id: UUID(),
                    category: category,
                    value: value,
                    colorHex: hexString(from: selectedColor)
                )
                store.add(fact: fact)
                dismiss()
            }
            .disabled(category.isEmpty || value.isEmpty)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}

struct EditInfoView: View {
    @Environment(\ .dismiss) var dismiss
    @ObservedObject var store: PersonalStore

    @State var fact: PersonalFact
    @State private var selectedColor: Color

    init(store: PersonalStore, fact: PersonalFact) {
        self.store = store
        _fact = State(initialValue: fact)
        _selectedColor = State(initialValue: colorFromHex(fact.colorHex))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Info")
                .font(.title.bold())

            TextField("Category", text: $fact.category)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Value", text: $fact.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Choose a Color")
            HStack {
                ForEach([Color.red, .green, .blue, .orange, .purple, .pink], id: \ .self) { color in
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

            Button("Save Changes") {
                let updated = PersonalFact(id: fact.id, category: fact.category, value: fact.value, colorHex: hexString(from: selectedColor))
                if let index = store.facts.firstIndex(where: { $0.id == fact.id }) {
                    store.facts[index] = updated
                    store.save()
                }
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Delete") {
                store.facts.removeAll { $0.id == fact.id }
                store.save()
                dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}

struct AddFamilyMemberView: View {
    @Environment(\ .dismiss) var dismiss
    @ObservedObject var store: FamilyStore
    @State private var name = ""
    @State private var image: UIImage?
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 20) {
            Text("New Family Member")
                .font(.title.bold())

            TextField("Enter name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Choose Photo") {
                showPicker = true
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }

            Button("Save") {
                let newMember = FamilyMember(id: UUID(), name: name, photoData: image?.jpegData(compressionQuality: 0.8))
                store.add(member: newMember)
                dismiss()
            }
            .disabled(name.isEmpty)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(selectedImage: $image, isImagePickerPresented: $showPicker)
        }
        .padding()
    }
}

// MARK: - Helper
func hexString(from color: Color) -> String {
    let uiColor = UIColor(color)
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
}

func colorFromHex(_ hex: String) -> Color {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r = Double((int >> 16) & 0xFF) / 255.0
    let g = Double((int >> 8) & 0xFF) / 255.0
    let b = Double(int & 0xFF) / 255.0
    return Color(red: r, green: g, blue: b)
}



struct Task: Identifiable, Codable {
    let id: UUID
    let timeRange: String
    let title: String
    let duration: String
    let iconName: String
    var isCompleted: Bool
    let scheduledTime: Date
    let colorHex: String  // Store as a hex string like "#FF0000"

}



class ReminderViewModel: ObservableObject {
    @Published var tasks: [Task] = []

    init() {
        loadTasks()
    }

    func addTask(timeRange: String, title: String, duration: String, iconName: String, scheduledTime: Date, colorHex: String) {
        let newTask = Task(
            id: UUID(),
            timeRange: timeRange,
            title: title,
            duration: duration,
            iconName: iconName,
            isCompleted: false,
            scheduledTime: scheduledTime,
            colorHex: colorHex
        )

        tasks.append(newTask)
        saveTasks()

        // ✅ Schedule notification here
        NotificationManager.shared.scheduleNotification(
            id: newTask.id.uuidString,
            title: "Time for your task!",
            body: newTask.title,
            date: scheduledTime
        )
    }

    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }

    var sortedTasks: [Task] {
        tasks.sorted(by: { $0.scheduledTime < $1.scheduledTime })
    }
}



struct Screen2: View {
    @EnvironmentObject var viewModel: ReminderViewModel
    @State private var showNewTaskSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.sortedTasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                        }
                    }
                    .padding()
                }

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
                    NewTaskView(viewModel: viewModel)
                }
            }
            .navigationTitle("Upcoming Events")
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
                    .background(colorFromHex(task.colorHex))
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.timeRange)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)

                Text(task.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .strikethrough(task.isCompleted)

                Text(task.duration)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.tasks[index].isCompleted.toggle()
                    if viewModel.tasks[index].isCompleted {
                        viewModel.tasks.remove(at: index)
                    }
                    viewModel.saveTasks()
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
    @State private var taskIcon = "alarm.fill"
    @State private var selectedColor: Color = .green

    let durations = [15, 30, 45, 60, 90]
    let availableIcons = ["alarm.fill", "sun.max.fill", "heart.fill", "book.fill", "bed.double.fill", "leaf.fill"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                        

                    TextField("e.g. Read a Book", text: $taskTitle)
                        .font(.title3)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    VStack(alignment: .leading) {
                        Text("When?")
                            .font(.title3)
                            .foregroundColor(.gray)
                        DatePicker("Start Time", selection: $taskTimeRange, displayedComponents: [.hourAndMinute, .date])
                            .labelsHidden()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    VStack(alignment: .leading) {
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

                    VStack(alignment: .leading) {
                        Text("Icon")
                            .font(.title3)
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(taskIcon == icon ? .white : .primary)
                                        .padding()
                                        .background(taskIcon == icon ? selectedColor : Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            taskIcon = icon
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Color")
                            .font(.title3)
                            .foregroundColor(.gray)
                        HStack {
                            ForEach([Color.pink, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                    .padding(.top)

                    Button(action: {
                        viewModel.addTask(
                            timeRange: formatTime(taskTimeRange),
                            title: taskTitle,
                            duration: "\(taskDuration) min",
                            iconName: taskIcon,
                            scheduledTime: taskTimeRange,
                            colorHex: hexString(from: selectedColor)
                        )
                        dismiss()
                    }) {
                        Text("Create Task")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
            .background(Color.gray.opacity(0.1))
            .navigationTitle("New Task")
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func hexString(from color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

  


struct Screen3: View {
    @State private var name = UserDefaults.standard.string(forKey: "name") ?? ""
    @State private var phone = UserDefaults.standard.string(forKey: "phone") ?? ""
    @State private var medical = UserDefaults.standard.string(forKey: "medical") ?? ""
    @State private var caretaker = UserDefaults.standard.string(forKey: "caretaker") ?? ""
    @State private var homeAddress = UserDefaults.standard.string(forKey: "homeAddress") ?? ""

    @State private var isEditing = false
    @State private var showPasscodePrompt = false
    @State private var enteredPasscode = ""

    private let correctPasscode = "1234"  // You can change this

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                  
                    Text("⚠️ I may be lost. Please help me get home.")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(15)

                    // INFO FIELDS
                    InfoField(title: "Name", text: $name, editable: isEditing)
                    InfoField(title: "Home Address", text: $homeAddress, editable: isEditing)
                    InfoField(title: "Caretaker Emergency Phone", text: $caretaker, editable: isEditing)
                    InfoField(title: "Medical Info", text: $medical, editable: isEditing)

                    // Save Button
                    if isEditing {
                        Button("Save Info") {
                            saveData()
                            isEditing = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    // Edit Button with Passcode
                    Button(action: {
                        showPasscodePrompt = true
                    }) {
                        Text("Edit Info")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Lost Info")
            .alert("Enter Passcode", isPresented: $showPasscodePrompt) {
                SecureField("Passcode", text: $enteredPasscode)
                Button("OK") {
                    if enteredPasscode == correctPasscode {
                        isEditing = true
                    }
                    enteredPasscode = ""
                }
                Button("Cancel", role: .cancel) {
                    enteredPasscode = ""
                }
            }
        }
    }

    func saveData() {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(medical, forKey: "medical")
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.set(caretaker, forKey: "caretaker")
        UserDefaults.standard.set(homeAddress, forKey: "homeAddress")
    }
}

// MARK: - Info Display Field
struct InfoField: View {
    let title: String
    @Binding var text: String
    let editable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            if editable {
                TextField("Enter \(title)", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(text.isEmpty ? "Not set" : text)
                    .font(.headline)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
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

    func saveItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try? data.write(to: url)
        }
    }

    func loadItems() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedItems = try? decoder.decode([LostItem].self, from: data) {
                self.items = decodedItems
            }
        }
    }

    func deleteItem(_ item: LostItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            saveItems()
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


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
        picker.sourceType = .photoLibrary
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
                                    if let data = item.photoData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(15)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .aspectRatio(1, contentMode: .fit)
                                            .cornerRadius(15)
                                    }

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

                            Button(role: .destructive) {
                                lostItemStore.deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.caption)
                            }
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
                AddRecordingView { name, audioFile, photoData in
                    saveOrUpdateItem(name: name, audioFileName: audioFile, photoData: photoData)
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

    func saveOrUpdateItem(name: String, audioFileName: String, photoData: Data?) {
        if let index = lostItemStore.items.firstIndex(where: { $0.name == name }) {
            lostItemStore.items[index].audioFileName = audioFileName
            lostItemStore.items[index].photoData = photoData
        } else {
            let newItem = LostItem(id: UUID(), name: name, imageName: "", audioFileName: audioFileName, photoData: photoData)
            lostItemStore.items.append(newItem)
        }
        lostItemStore.saveItems()
    }
}

// MARK: - AddRecordingView

struct AddRecordingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var recorder = AudioRecorder()
    @State private var fileName = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    var onSave: (String, String, Data?) -> Void

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
                onSave(fileName, fileName + ".m4a", selectedImage?.jpegData(compressionQuality: 0.8))
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


struct Screen5: View {
    struct UnsafeItem: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let color: Color
        let image: UIImage?
    }
    
    // Replace with your actual images or load them from asset names
    let items: [UnsafeItem] = [
        // 🔥 Hot
        UnsafeItem(name: "Stove Top", category: "Hot", color: .red, image: UIImage(named: "stovetop")),
        UnsafeItem(name: "Iron", category: "Hot", color: .red, image: UIImage(named: "iron")),
        
        // 🔪 Sharp
        UnsafeItem(name: "Knife", category: "Sharp", color: .orange, image: UIImage(named: "knife")),
        UnsafeItem(name: "Scissors", category: "Sharp", color: .orange, image: UIImage(named: "scissors")),
        
        // 🧪 Chemical
        UnsafeItem(name: "Laundry Pods", category: "Chemical", color: .purple, image: UIImage(named: "laundrypods")),
        UnsafeItem(name: "Cleaner Spray", category: "Chemical", color: .purple, image: UIImage(named: "cleaner")),
        UnsafeItem(name: "Gasoline", category: "Chemical", color: .purple, image: UIImage(named: "gasoline"))
    ]
    
    var groupedItems: [String: [UnsafeItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Unsafe Items")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category)
                            .font(.title)
                            .bold()
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(groupedItems[category]!) { item in
                                VStack(spacing: 10) {
                                    if let image = item.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .shadow(radius: 4)
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 120)
                                            .overlay(Text("No Image").foregroundColor(.gray))
                                    }
                                    
                                    Text(item.name)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(item.color.opacity(0.1))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Mood Logger

struct MoodEntry: Identifiable, Codable {
    let id = UUID()
    var mood: String
    var emoji: String
    var reason: String
    var timestamp: Date
}

class MoodLoggerViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    private let key = "moodEntries"

    init() {
        load()
    }

    func add(_ entry: MoodEntry) {
        entries.append(entry)
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            entries = decoded
        }
    }
}

struct MoodLoggerView: View {
    @StateObject private var viewModel = MoodLoggerViewModel()
    @ObservedObject var moodStore: LastMoodStore
    @State private var selectedMood: (emoji: String, label: String, color: Color)? = nil
    @State private var reason = ""
    @State private var showConfirmation = false

    let moods = [
        ("😄", "Happy", Color.yellow),
        ("😠", "Angry", Color.red),
        ("😢", "Sad", Color.blue),
        ("😐", "Okay", Color.gray),
        ("😨", "Scared", Color.purple)
    ]

    let needs = [
        "I'm hungry", "I need the bathroom", "I'm tired", "I want to talk", "I need help"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How are you feeling?")
                    .font(.largeTitle)
                    .bold()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(moods, id: \.1) { mood in
                            VStack {
                                Text(mood.0)
                                    .font(.system(size: 60))
                                Text(mood.1)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(width: 120, height: 120)
                            .background(mood.2.opacity(selectedMood?.label == mood.1 ? 0.5 : 0.2))
                            .cornerRadius(20)
                            .onTapGesture {
                                selectedMood = mood
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("What do you need?")
                        .font(.headline)
                        .padding(.leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(needs, id: \.self) { need in
                                Button(action: {
                                    reason = need
                                }) {
                                    Text(need)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.teal.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                TextField("Other reason...", text: $reason)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: logMood) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Log Mood")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedMood == nil ? Color.gray : Color.green)
                    .cornerRadius(14)
                }
                .disabled(selectedMood == nil)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Current Mood")
            .alert("Mood Saved!", isPresented: $showConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func logMood() {
        guard let mood = selectedMood else { return }
        let entry = MoodEntry(
            mood: mood.label,
            emoji: mood.0,
            reason: reason,
            timestamp: Date()
        )
        viewModel.add(entry)
        moodStore.lastMoodEmoji = mood.0
        reason = ""
        selectedMood = nil
        showConfirmation = true
    }

}

class LastMoodStore: ObservableObject {
    @Published var lastMoodEmoji: String {
        didSet {
            UserDefaults.standard.set(lastMoodEmoji, forKey: "lastMoodEmoji")
        }
    }

    init() {
        self.lastMoodEmoji = UserDefaults.standard.string(forKey: "lastMoodEmoji") ?? ""
    }
}

struct MoodBannerView: View {
    @ObservedObject var moodStore: LastMoodStore

    var body: some View {
        if !moodStore.lastMoodEmoji.isEmpty {
            VStack(spacing: 4) {
                Text("Last Logged Mood")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)

                Text(moodStore.lastMoodEmoji)
                    .font(.system(size: 80))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}
