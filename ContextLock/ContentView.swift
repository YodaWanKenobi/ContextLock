import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContextViewModel
    @State private var inputBuffer: String = ""

    var body: some View {
        ZStack {
            // Premium OLED Midnight Aesthetic
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Branding Header Module
                HStack {
                    Text("CONTEXT//LOCK")
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .tracking(3)
                    Spacer()
                    Circle()
                        .fill(viewModel.activeSnapshot != nil ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                }
                .padding(.horizontal)

                if let active = viewModel.activeSnapshot {
                    // LOCKED STATE DISPLAY
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ACTIVE THOUGHT MEMORY")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.orange)
                            .tracking(1)

                        Text("\"\(active.thoughtText)\"")
                            .font(.system(.body, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Locked at: \(active.timestamp.formatted(date: .omitted, time: .shortened))")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)

                        Button(action: { viewModel.clearAndResume() }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Restore Train of Thought")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .bold()
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)

                } else {
                    // INTERCEPT STANDBY INPUT MODE
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Drop your current brain state before switching tabs or stepping away:")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)

                        TextField("e.g., Working on bug fix at line 143 in API controller...", text: $inputBuffer)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.04))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )

                        Button(action: {
                            viewModel.cacheCurrentContext(text: inputBuffer)
                            inputBuffer = ""
                        }) {
                            Text("Commit Brain Freeze")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.black)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(inputBuffer.isEmpty ? Color.gray : Color.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(inputBuffer.isEmpty)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Footer System Metrics
                HStack {
                    Text("Total Context Resets: \(viewModel.totalLocksCompleted)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    #if os(macOS)
                    Text("Hotkey  \(GlobalHotKeyMonitor.displayChord)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                    #endif
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
