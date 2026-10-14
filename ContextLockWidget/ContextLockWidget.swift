import SwiftUI
import WidgetKit

struct ThoughtEntry: TimelineEntry {
    let date: Date
    let snapshot: ContextSnapshot?
    let totalLocks: Int

    var isLocked: Bool {
        snapshot?.isActive == true
    }
}

struct ThoughtProvider: TimelineProvider {
    func placeholder(in context: Context) -> ThoughtEntry {
        ThoughtEntry(
            date: Date(),
            snapshot: ContextSnapshot(
                thoughtText: "Working on bug fix at line 143 in API controller",
                timestamp: Date(),
                isActive: true
            ),
            totalLocks: 4
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ThoughtEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThoughtEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .never))
    }

    private func currentEntry() -> ThoughtEntry {
        ThoughtEntry(
            date: Date(),
            snapshot: AppGroupStore.loadSnapshot(),
            totalLocks: AppGroupStore.loadTotalLocks()
        )
    }
}

struct ContextLockWidget: Widget {
    let kind = "ContextLockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThoughtProvider()) { entry in
            ContextLockWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.black
                }
        }
        .configurationDisplayName("Active Thought")
        .description("Shows the thought you locked before switching context.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct ContextLockWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ThoughtEntry

    var body: some View {
        ZStack {
            Color.black
            switch family {
            case .systemMedium:
                mediumLayout
            case .accessoryRectangular:
                accessoryLayout
            default:
                smallLayout
            }
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            header(compact: true)
            statusHeadline
            if entry.isLocked, let snapshot = entry.snapshot {
                Text("\"\(snapshot.thoughtText)\"")
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .foregroundStyle(.white)
                    .lineLimit(4)
                Spacer(minLength: 0)
                Text(snapshot.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.gray)
            } else {
                standbyMessage
                    .font(.system(.caption2, design: .rounded))
                Spacer(minLength: 0)
            }
        }
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(compact: false)
            statusHeadline
            if entry.isLocked, let snapshot = entry.snapshot {
                Text("\"\(snapshot.thoughtText)\"")
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(.white)
                    .lineLimit(3)
                Spacer(minLength: 0)
                HStack {
                    Text("Locked \(snapshot.timestamp.formatted(date: .omitted, time: .shortened))")
                    Spacer()
                    Text("Resets \(entry.totalLocks)")
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.gray)
            } else {
                standbyMessage
                    .font(.system(.footnote, design: .rounded))
                Spacer(minLength: 0)
                Text("Total Context Resets: \(entry.totalLocks)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.gray)
            }
        }
    }

    private var accessoryLayout: some View {
        VStack(alignment: .leading, spacing: 2) {
            statusHeadline
            if entry.isLocked, let snapshot = entry.snapshot {
                Text(snapshot.thoughtText)
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .lineLimit(2)
            } else {
                standbyMessage
                    .font(.system(.caption2, design: .rounded))
                    .lineLimit(2)
            }
        }
    }

    private var statusHeadline: some View {
        Text(entry.isLocked ? "FOCUS ACTIVE" : "CORE STANDBY")
            .font(.system(.caption2, design: .monospaced))
            .fontWeight(.bold)
            .foregroundStyle(entry.isLocked ? Color.orange : Color.gray)
            .tracking(1)
    }

    private var standbyMessage: some View {
        Text("Workspace clear. Ready for the next deep block.")
            .foregroundStyle(.gray)
    }

    private func header(compact: Bool) -> some View {
        HStack {
            Text("CONTEXT//LOCK")
                .font(.system(compact ? .caption2 : .caption, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .tracking(1)
            Spacer()
            Circle()
                .fill(entry.isLocked ? Color.orange : Color.green)
                .frame(width: 7, height: 7)
        }
    }
}

#Preview("Small locked", as: .systemSmall) {
    ContextLockWidget()
} timeline: {
    ThoughtEntry(
        date: .now,
        snapshot: ContextSnapshot(thoughtText: "Auth token refresh race in login flow", timestamp: .now, isActive: true),
        totalLocks: 7
    )
}

#Preview("Medium standby", as: .systemMedium) {
    ContextLockWidget()
} timeline: {
    ThoughtEntry(date: .now, snapshot: nil, totalLocks: 7)
}
