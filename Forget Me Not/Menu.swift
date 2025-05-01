import SwiftUI

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

// Add this after the preview:
struct Screen1: View {
    var body: some View {
        Text("Screen 1")
            .font(.largeTitle)
    }
}

struct Task: Identifiable {
    let id = UUID()
    let timeRange: String
    let title: String
    let duration: String
    let iconName: String
    var isCompleted: Bool
    
}
    struct Screen2: View {
        @State private var tasks: [Task] = [
            Task(timeRange: "08:30 – 08:45", title: "Rise and Shine", duration: "15 min", iconName: "alarm.fill", isCompleted: true),
            Task(timeRange: "10:00 – 10:15", title: "Take a Shower", duration: "15 min", iconName: "drop.fill", isCompleted: false),
            Task(timeRange: "10:15 – 10:30", title: "Have a Coffee", duration: "15 min", iconName: "cup.and.saucer.fill", isCompleted: false),
            Task(timeRange: "10:30 – 11:00", title: "Bike to Office", duration: "30 min", iconName: "bicycle", isCompleted: false),
            Task(timeRange: "11:00 – 12:30", title: "Prepare Presentation", duration: "1 hr 30 min", iconName: "doc.text.fill", isCompleted: false)
        ]
        
        @State private var showNewTaskSheet = false
        // ... existing code ...
        
        var body: some View {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(tasks.indices, id: \.self) { index in
                                TaskRow(task: $tasks[index])
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
                        NewTaskView()
                    }
                }
                .navigationTitle("Reminders")
            }
        }
    }
    
    struct TaskRow: View {
        @Binding var task: Task
        
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
                    task.isCompleted.toggle()
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
        
        @State private var title: String = ""
        @State private var selectedTime = Date()
        @State private var duration: Int = 30
        @State private var selectedColor: Color = .green
        
        let durations = [15, 30, 45, 60, 90]
        
        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("Task Name")) {
                        TextField("e.g. Read a Book", text: $title)
                    }
                    
                    Section(header: Text("When?")) {
                        DatePicker("Start Time", selection: $selectedTime, displayedComponents: [.hourAndMinute, .date])
                    }
                    
                    Section(header: Text("Duration")) {
                        Picker("Select Duration", selection: $duration) {
                            ForEach(durations, id: \.self) { value in
                                Text("\(value)m").tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Color")) {
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
                    
                    Button(action: {
                        // Add your save logic here
                        dismiss()
                    }) {
                        Text("Create Task")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .navigationTitle("New Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    
    struct Screen3: View {
        var body: some View {
            Text("Screen 3")
                .font(.largeTitle)
        }
    }
    
    struct Screen4: View {
        var body: some View {
            Text("Screen 4")
                .font(.largeTitle)
        }
    }
