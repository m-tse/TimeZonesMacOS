import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TimezoneStore
    @State private var now = Date()
    @State private var showingAdd = false
    @State private var panelHeight: CGFloat = {
        let saved = UserDefaults.standard.double(forKey: "worldclock_panelHeight")
        return CGFloat(saved > 0 ? saved : 500).clamped(min: 300, max: 900)
    }()
    @State private var isDragging = false

    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var selectedDate: Date {
        now.addingTimeInterval(store.hourOffset * 3600)
    }

    var body: some View {
        VStack(spacing: 0) {
            if showingAdd {
                AddTimezoneView(isShowing: $showingAdd)
                    .environmentObject(store)
            } else {
                mainView
            }
        }
        .frame(width: 360, height: panelHeight)
        .onReceive(timer) { _ in
            now = Date()
        }
    }

    @ViewBuilder
    var mainView: some View {
        // Scrollable content: slider + timezone list
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Slider
                HStack(spacing: 8) {
                    Text("-12h")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 28, alignment: .trailing)
                    Slider(value: $store.hourOffset, in: -12...12, step: 0.25)
                    Text("+12h")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 28, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Offset indicator
                if store.hourOffset != 0 {
                    HStack {
                        Text(offsetLabel)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Reset") {
                            withAnimation(.easeOut(duration: 0.3)) { store.hourOffset = 0 }
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                    .padding(.top, 2)
                }

                Divider()
                    .padding(.top, 8)

                // Timezone list
                LazyVStack(spacing: 0) {
                    ForEach(store.sortedTimezones(for: selectedDate)) { tz in
                        let isLocal = tz.timeZone.identifier == TimeZone.current.identifier
                        TimezoneRowView(
                            timezone: tz,
                            selectedDate: selectedDate,
                            localTimeZone: TimeZone.current,
                            hourOffset: $store.hourOffset,
                            isHighlighted: isLocal
                        )
                        .contextMenu {
                            if !isLocal {
                                Button("Remove") { store.remove(tz) }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }

        Divider()

        // Footer
        HStack {
            Button { showingAdd = true } label: {
                Label("Add Timezone", systemImage: "plus")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)

        // Resize handle
        ResizeHandle(isDragging: $isDragging) { delta in
            let newHeight = (panelHeight + delta).clamped(min: 300, max: 900)
            panelHeight = newHeight
            UserDefaults.standard.set(Double(newHeight), forKey: "worldclock_panelHeight")
        }
    }

    var offsetLabel: String {
        let h = Int(store.hourOffset)
        let m = Int((store.hourOffset - Double(h)) * 60)
        let sign = store.hourOffset >= 0 ? "+" : ""
        if m == 0 {
            return "\(sign)\(h)h from now"
        } else {
            return "\(sign)\(h)h \(abs(m))m from now"
        }
    }
}
