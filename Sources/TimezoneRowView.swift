import SwiftUI

struct TimezoneRowView: View {
    let timezone: WorldTimezone
    let selectedDate: Date
    let localTimeZone: TimeZone
    @Binding var hourOffset: Double
    var isHighlighted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(timezone.label)
                            .font(.system(.body, weight: isHighlighted ? .bold : .medium))
                        if isHighlighted {
                            Text("(You)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack(spacing: 4) {
                        Text(abbreviation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("·")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(dateColor)
                    }
                }
                Spacer()
                Text(formattedTime)
                    .font(.system(.title3, design: .rounded, weight: isHighlighted ? .bold : .medium))
                    .monospacedDigit()
            }

            DayNightBar(timeZone: timezone.timeZone, selectedDate: selectedDate, hourOffset: $hourOffset)
                .frame(height: 14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isHighlighted ? Color.accentColor.opacity(0.1) : Color.clear)
    }

    private var hourInTimezone: Int {
        var cal = Calendar.current
        cal.timeZone = timezone.timeZone
        return cal.component(.hour, from: selectedDate)
    }

    private var isDaytime: Bool {
        let hour = hourInTimezone
        return hour >= 6 && hour < 20
    }

    private var formattedTime: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.timeZone = timezone.timeZone
        return fmt.string(from: selectedDate)
    }

    private var abbreviation: String {
        let offset = timezone.timeZone.secondsFromGMT(for: selectedDate)
        let h = offset / 3600
        let m = abs(offset % 3600) / 60
        if m == 0 {
            return "GMT\(h >= 0 ? "+" : "")\(h)"
        } else {
            return String(format: "GMT%+d:%02d", h, m)
        }
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        fmt.timeZone = timezone.timeZone
        return fmt.string(from: selectedDate)
    }

    private var dateColor: Color {
        let diff = dayOffset
        if diff < 0 { return .red }
        if diff > 0 { return Color(red: 0.0, green: 0.55, blue: 0.0) }
        return .secondary
    }

    private var dayOffset: Int {
        var localCal = Calendar.current
        localCal.timeZone = localTimeZone
        var remoteCal = Calendar.current
        remoteCal.timeZone = timezone.timeZone

        let localComps = localCal.dateComponents([.year, .month, .day], from: selectedDate)
        let remoteComps = remoteCal.dateComponents([.year, .month, .day], from: selectedDate)

        let localDate = localCal.date(from: localComps)!
        let remoteDate = localCal.date(from: remoteComps)!

        return localCal.dateComponents([.day], from: localDate, to: remoteDate).day ?? 0
    }

    private var isDifferentDay: Bool {
        var localCal = Calendar.current
        localCal.timeZone = localTimeZone
        var remoteCal = Calendar.current
        remoteCal.timeZone = timezone.timeZone

        let localDay = localCal.dateComponents([.year, .month, .day], from: selectedDate)
        let remoteDay = remoteCal.dateComponents([.year, .month, .day], from: selectedDate)

        return localDay.year != remoteDay.year ||
               localDay.month != remoteDay.month ||
               localDay.day != remoteDay.day
    }
}
