import SwiftUI

struct DayNightBar: View {
    let timeZone: TimeZone
    let selectedDate: Date
    @Binding var hourOffset: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 24-hour colored bar (48 segments = 30min each)
                HStack(spacing: 0) {
                    ForEach(0..<48, id: \.self) { segment in
                        Rectangle()
                            .fill(colorForHour(Double(segment) / 2.0))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))

                // Selected time marker (red line)
                let pos = markerPosition(in: geo.size.width)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.red)
                    .frame(width: 2.5, height: geo.size.height)
                    .offset(x: max(0, min(pos - 1.25, geo.size.width - 2.5)))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let fraction = max(0, min(value.location.x / geo.size.width, 1.0))
                        let targetHour = fraction * 24.0

                        // Current hour in this timezone (without offset)
                        let now = Date()
                        var cal = Calendar.current
                        cal.timeZone = timeZone
                        let currentHour = Double(cal.component(.hour, from: now)) + Double(cal.component(.minute, from: now)) / 60.0

                        // Calculate offset needed
                        var diff = targetHour - currentHour
                        // Clamp to slider range
                        diff = max(-12, min(12, diff))
                        hourOffset = (diff * 4).rounded() / 4 // snap to 15min
                    }
            )
            .cursor(.resizeLeftRight)
        }
    }

    private func colorForHour(_ hour: Double) -> Color {
        // Light grey for day, dark grey for night (matching time.fyi style)
        // Dawn: 5-7, Day: 7-18, Dusk: 18-21, Night: 21-5
        let t: Double // 0 = night, 1 = day
        if hour < 5 || hour >= 21 {
            t = 0
        } else if hour < 7 {
            t = (hour - 5) / 2.0
        } else if hour < 18 {
            t = 1
        } else {
            t = 1.0 - (hour - 18) / 3.0
        }
        // Night: ~0.20 grey, Day: ~0.58 grey
        let v = 0.20 + 0.38 * t
        return Color(white: v)
    }

    private func markerPosition(in width: CGFloat) -> CGFloat {
        var cal = Calendar.current
        cal.timeZone = timeZone
        let hour = cal.component(.hour, from: selectedDate)
        let minute = cal.component(.minute, from: selectedDate)
        let fraction = (Double(hour) + Double(minute) / 60.0) / 24.0
        return fraction * width
    }
}
