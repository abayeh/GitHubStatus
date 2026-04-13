//
//  ContentView.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import SwiftUI

struct GitHubView: View {
    @StateObject private var viewModel = ComponentViewModel()
    @State private var refreshRotation: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(formattedDate(lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    viewModel.fetchComponents()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(refreshRotation))
                        .animation(.easeInOut(duration: 0.3), value: refreshRotation)
                }
                .buttonStyle(.plain)
                .onReceive(viewModel.$lastUpdated) { _ in
                    withAnimation {
                        refreshRotation += 360
                    }
                }
                Spacer()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.components.filter { $0.name != "Visit www.githubstatus.com for more information" }, id: \.id) { component in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(component.status.color)
                                .frame(width: 10, height: 10)

                            Text(component.name)
                                .font(.subheadline)

                            Spacer()

                            Text(component.status.type)
                                .font(.caption)
                                .foregroundColor(component.status.color)
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.footnote)
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(minWidth: 280, idealWidth: 300, maxWidth: 360,
               minHeight: 200, idealHeight: 300, maxHeight: 500)
        .onAppear {
            viewModel.startTimers()
        }
        .onDisappear {
            viewModel.stopTimers()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

@MainActor
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubView()
    }
}
#Preview {
    GitHubView()
}

