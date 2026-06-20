import SwiftUI

@main
struct MeridianApp: App {
    @StateObject private var store = TimezoneStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
        } label: {
            MenuBarLabel(store: store)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var store: TimezoneStore
    @State private var now = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if store.menuBarShowsTime {
                Text(timeString(for: store.referenceTimeZone))
                    .monospacedDigit()
            } else {
                Image(nsImage: makeGlobeAltIcon())
            }
        }
        .onReceive(timer) { _ in now = Date() }
    }

    private func timeString(for tz: TimeZone) -> String {
        var parts: [String] = []
        let fmt = DateFormatter()
        fmt.timeZone = tz

        if store.menuBarShowDayOfWeek {
            fmt.dateFormat = "EEE"
            parts.append(fmt.string(from: now))
        }

        if store.menuBarShowDate {
            fmt.dateFormat = "MMM d"
            parts.append(fmt.string(from: now))
        }

        fmt.dateFormat = store.use24Hour ? "HH:mm" : "h:mm a"
        parts.append(fmt.string(from: now))

        if store.menuBarShowAbbreviation {
            let abbr = tz.abbreviation(for: now) ?? ""
            parts.append(abbr)
        }

        return parts.joined(separator: "  ")
    }

    private func makeGlobeAltIcon() -> NSImage {
        let size: CGFloat = 18
        let s = size / 24.0

        let image = NSImage(size: NSSize(width: size, height: size), flipped: true) { _ in
            NSColor.black.setStroke()

            func pt(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
                NSPoint(x: x * s, y: y * s)
            }

            let circle = NSBezierPath(ovalIn: NSRect(x: 3 * s, y: 3 * s, width: 18 * s, height: 18 * s))
            circle.lineWidth = 1.5 * s
            circle.lineCapStyle = .round
            circle.lineJoinStyle = .round
            circle.stroke()

            let meridian = NSBezierPath(ovalIn: NSRect(x: 7.5 * s, y: 3 * s, width: 9 * s, height: 18 * s))
            meridian.lineWidth = 1.5 * s
            meridian.lineCapStyle = .round
            meridian.lineJoinStyle = .round
            meridian.stroke()

            let upper = NSBezierPath()
            upper.move(to: pt(4.157, 7.582))
            upper.curve(to: pt(19.843, 7.582),
                        controlPoint1: pt(6.26, 9.4),
                        controlPoint2: pt(9.0, 10.5))
            upper.lineWidth = 1.5 * s
            upper.lineCapStyle = .round
            upper.lineJoinStyle = .round
            upper.stroke()

            let lower = NSBezierPath()
            lower.move(to: pt(3.284, 14.253))
            lower.curve(to: pt(20.716, 14.253),
                        controlPoint1: pt(5.87, 15.685),
                        controlPoint2: pt(8.84, 16.5))
            lower.lineWidth = 1.5 * s
            lower.lineCapStyle = .round
            lower.lineJoinStyle = .round
            lower.stroke()

            return true
        }
        image.isTemplate = true
        return image
    }
}
