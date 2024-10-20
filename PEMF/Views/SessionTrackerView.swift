
import SwiftUI
import SwiftData

struct SessionTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TherapySession.order) private var sessions: [TherapySession]
    @Environment(ToneGenerator.self) private var toneGenerator
    @State private var showingAddSession = false
    @State private var selectedSession: TherapySession?
    
    var body: some View {
        NavigationStack {
            VStack {
                if sessions.isEmpty {
                    ContentUnavailableView("No sessions", systemImage: "tray.fill")
                } else {
                    sessionsList
                }
            }
            .navigationTitle("Sessions")
        }
    }
    
    private var sessionsList: some View {
        List {
            ForEach(sessions) { session in
                sessionRow(for: session)
            }
            .onMove(perform: moveSession)
            .onDelete(perform: deleteSessions)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Manual Entry") {
                        showingAddSession = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSession) {
            AddSessionView(duration: 0)
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
        }
    }
    
    private func sessionRow(for session: TherapySession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(session.date, style: .date)
                    .font(.headline)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.green)
                Text("Duration: \(formatDuration(session.duration))")
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "waveform.path")
                    .foregroundStyle(.orange)
                Text("Frequencies: \(session.frequency1, specifier: "%.1f") Hz, \(session.frequency2, specifier: "%.1f") Hz")
                    .font(.subheadline)
            }
            
            if let preset = session.preset {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.purple)
                    Text("Preset: \(preset)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .onTapGesture {
            selectedSession = session
        }
    }
    
    private func moveSession(from source: IndexSet, to destination: Int) {
        var mutableSessions = sessions
        mutableSessions.move(fromOffsets: source, toOffset: destination)
        
        // Update the order in SwiftData
        for (index, session) in mutableSessions.enumerated() {
            session.order = Int16(index)
        }
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        if duration < 60 {
            formatter.allowedUnits = [.second]
            formatter.unitsStyle = .full
        } else if duration < 3600 {
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        } else {
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        }
        return formatter.string(from: duration) ?? ""
    }
}


struct AddSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ToneGenerator.self) private var toneGenerator
    
    var duration: TimeInterval
    @State private var notes = ""
    @State private var manualDuration: Double = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Session Details")) {
                    if duration == 0 {
                        HStack {
                            Text("Duration (minutes)")
                            Spacer()
                            TextField("Duration", value: $manualDuration, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text(formatDuration(duration))
                        }
                    }
                    HStack {
                        Text("Frequency 1")
                        Spacer()
                        Text("\(toneGenerator.frequency1, specifier: "%.1f") Hz")
                    }
                    HStack {
                        Text("Frequency 2")
                        Spacer()
                        Text("\(toneGenerator.frequency2, specifier: "%.1f") Hz")
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let sessionDuration = duration == 0 ? (manualDuration * 60) : duration
                        let newSession = TherapySession(
                            date: Date(),
                            duration: sessionDuration,
                            frequency1: toneGenerator.frequency1,
                            frequency2: toneGenerator.frequency2,
                            preset: nil,
                            notes: notes
                        )
                        modelContext.insert(newSession)
                        dismiss()
                    }
                }
            }
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

struct SessionDetailView: View {
    @Bindable var session: TherapySession
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Session Details")) {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(session.date, style: .date)
                    }
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formatDuration(session.duration))
                    }
                    HStack {
                        Text("Frequency 1")
                        Spacer()
                        Text("\(session.frequency1, specifier: "%.1f") Hz")
                    }
                    HStack {
                        Text("Frequency 2")
                        Spacer()
                        Text("\(session.frequency2, specifier: "%.1f") Hz")
                    }
                    if let preset = session.preset {
                        HStack {
                            Text("Preset")
                            Spacer()
                            Text(preset)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $session.notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        if duration < 60 {
            formatter.allowedUnits = [.second]
            formatter.unitsStyle = .full
        } else if duration < 3600 {
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        } else {
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        }
        return formatter.string(from: duration) ?? ""
    }
}

#Preview {
    SessionTrackerView()
        .modelContainer(for: TherapySession.self, inMemory: true)
        .environment(ToneGenerator())
}
