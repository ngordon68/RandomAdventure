//
//  PlaceCardCell.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 9/26/25.
//

import SwiftUI


struct PlaceCard: View {
    let title: String
    let subtitle: String
    var actionTitle: String = "Show on Map"
    var actionIcon: String = "map"
    var accessoryIcon: String? = "trash.circle.fill" // set to nil to hide
    var accessoryRole: ButtonRole? = .destructive

    var onPrimaryAction: () -> Void
    var onAccessoryAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Optional top row with accessory action
            HStack(alignment: .top) {
                Spacer()

                if let accessoryIcon, let onAccessoryAction {
                    Button(role: accessoryRole) {
                        onAccessoryAction()
                    } label: {
                        Image(systemName: accessoryIcon)
                            .font(.title3.weight(.semibold))
                            .padding(6)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .accessibilityLabel(Text("Remove"))
                }
            }

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

            Button(action: onPrimaryAction) {
                Label(actionTitle, systemImage: actionIcon)
                    .font(.caption)
            }
            .foregroundStyle(Color(.customComponent))
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(.accentColor)
            .accessibilityHint(Text("Shows this place on the map"))
        }
        .padding(12)
        .frame(width: 220, height: 180) // tweak as desired
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .hoverEffect(.lift)
        .accessibilityElement(children: .combine)
    }
}


#Preview("Default") {
    PlaceCard(
        title: "Central Park",
        subtitle: "New York, NY",
        onPrimaryAction: {
            print("Show on Map tapped")
        },
        onAccessoryAction: {
            print("Accessory tapped")
        }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

#Preview("No Accessory") {
    PlaceCard(
        title: "Eiffel Tower",
        subtitle: "Paris, France",
        accessoryIcon: nil,
        onPrimaryAction: {
            print("Show on Map tapped")
        },
        onAccessoryAction: nil
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

#Preview("Dark • Large Text • Scroller") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            PlaceCard(
                title: "Golden Gate Bridge",
                subtitle: "San Francisco, CA",
                onPrimaryAction: {},
                onAccessoryAction: {}
            )
            PlaceCard(
                title: "Mount Fuji",
                subtitle: "Fujinomiya, Japan",
                accessoryIcon: nil,
                onPrimaryAction: {},
                onAccessoryAction: nil
            )
            PlaceCard(
                title: "Very long place name that might wrap across multiple lines",
                subtitle: "A subtitle that is also quite long to test wrapping and line limits",
                onPrimaryAction: {},
                onAccessoryAction: {}
            )
        }
        .padding(.horizontal)
    }
    .padding(.vertical)
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

