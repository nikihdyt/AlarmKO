import SwiftUI

struct CircularSleepRing: View {
    @Binding var start: Date
    @Binding var end: Date

    @State private var ringSize: CGFloat = 200

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 20)
                .frame(width: ringSize, height: ringSize)
            
            Image("24Hours")
                .resizable()
                .frame(width: 155, height: 155)

            // Sleep interval arc (handles cross-midnight)
            if startAngleRatio <= endAngleRatio {
                // Draw single sleep arc (does not cross midnight)
                Circle()
                    .trim(from: startAngleRatio, to: endAngleRatio)
                    .stroke(Color(.prim), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
            } else {
                // Cross-midnight sleep: draw as two separate arcs
                Circle()
                    .trim(from: startAngleRatio, to: 1.0)
                    .stroke(Color(.prim), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0.0, to: endAngleRatio)
                    .stroke(Color(.prim), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
            }

            // Btn - Bedtime
            Image("CirBedtime")
                .resizable()
                .frame(width: 30, height: 30)
                .position(self.position(for: startAngleRatio))
                .gesture(DragGesture().onChanged { value in
                    self.start = self.angleToDate(from: value.location)
                })

            // Btn - Wakeup
            Image("CirAlarmIcon")
                .resizable()
                .frame(width: 30, height: 30)
                .position(self.position(for: endAngleRatio))
                .gesture(DragGesture().onChanged { value in
                    self.end = self.angleToDate(from: value.location)
                })

            // Timer
            VStack(spacing: 4) {
                HStack{
                    
                    Image(systemName: "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color(.prim))
                        .background(
                                Circle()
                                    .stroke(Color(.prim), lineWidth: 2)
                            )
                        
                    

                    Text("Sleep")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.prim))
                }
                Text(totalSleepDuration)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .foregroundColor(.white)
        }
        .frame(width: ringSize, height: ringSize)
    }

    // Convert time to angle ratio (range: 0 to 1)
    var startAngleRatio: CGFloat {
        CGFloat(Calendar.current.component(.hour, from: start)) / 24.0
        + CGFloat(Calendar.current.component(.minute, from: start)) / 1440.0
    }

    var endAngleRatio: CGFloat {
        CGFloat(Calendar.current.component(.hour, from: end)) / 24.0
        + CGFloat(Calendar.current.component(.minute, from: end)) / 1440.0
    }

    // Get XY position on ring based on angle
    func position(for ratio: CGFloat) -> CGPoint {
        let angle = 2 * .pi * ratio - .pi / 2
        let radius = ringSize / 2
        let x = radius + cos(angle) * radius
        let y = radius + sin(angle) * radius
        return CGPoint(x: x, y: y)
    }

    // Calculate time from drag gesture location
    func angleToDate(from point: CGPoint) -> Date {
        let center = CGPoint(x: ringSize / 2, y: ringSize / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) + .pi / 2
        if angle < 0 { angle += 2 * .pi }

        let totalMinutes = Int((angle / (2 * .pi)) * 1440) // 24hr * 60min
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60

        return Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }

    var totalSleepDuration: String {
        let interval = end.timeIntervalSince(start)
        let adjusted = interval < 0 ? interval + 86400 : interval // Handle time range that crosses midnight
        let hours = Int(adjusted) / 3600
        let minutes = (Int(adjusted) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
