//
//  RoomInviteTopBannerView.swift
//  The Social Deck
//
//  Compact top banner for pending room invites (shortcut vs Friends tab).
//

import SwiftUI

struct RoomInviteTopBannerView: View {
    @EnvironmentObject private var authManager: AuthManager
    @ObservedObject private var onlineManager = OnlineManager.shared

    /// Called on main thread after a successful accept (room joined).
    var onAcceptedRoomInvite: () -> Void

    @State private var inviterProfile: UserProfile?
    @State private var isLoadingProfile = false
    @State private var isProcessing = false

    /// Invite document IDs hidden by swipe-up only (still pending in Firestore / Room Invites tab).
    @State private var bannerOnlyDismissedInviteIds: Set<String> = []
    @State private var dragOffset: CGFloat = 0

    private var pendingIds: Set<String> {
        Set(onlineManager.pendingRoomInvites.compactMap(\.id))
    }

    /// Stable signature so we can prune swipe-dismiss state when the pending list changes.
    private var pendingInviteIdsKey: String {
        onlineManager.pendingRoomInvites.compactMap(\.id).sorted().joined(separator: "|")
    }

    /// First pending invite we are not hiding locally via swipe.
    private var visibleTopInvite: RoomInvite? {
        onlineManager.pendingRoomInvites.first { invite in
            guard let id = invite.id else { return true }
            return !bannerOnlyDismissedInviteIds.contains(id)
        }
    }

    var body: some View {
        Group {
            if authManager.isAuthenticated,
               onlineManager.currentRoom == nil,
               let invite = visibleTopInvite {
                bannerContent(invite: invite)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: visibleTopInvite?.id)
        .task(id: visibleTopInvite?.id) {
            await loadInviterProfile(for: visibleTopInvite)
        }
        .onChange(of: pendingInviteIdsKey) { _, _ in
            // Drop swipe-dismiss entries for invites that are no longer pending (e.g. declined in Room Invites).
            bannerOnlyDismissedInviteIds = bannerOnlyDismissedInviteIds.intersection(pendingIds)
        }
        .onChange(of: visibleTopInvite?.id) { _, _ in
            dragOffset = 0
        }
    }

    @ViewBuilder
    private func bannerContent(invite: RoomInvite) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                if let profile = inviterProfile {
                    AvatarView(
                        avatarType: profile.avatarType,
                        avatarColor: profile.avatarColor,
                        size: 48
                    )
                } else if isLoadingProfile {
                    ProgressView()
                        .scaleEffect(0.9)
                        .frame(width: 48, height: 48)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.secondaryText.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(inviterProfile?.username ?? "Friend")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text("Invited you · \(invite.roomName)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 10) {
                Button {
                    Task { await decline(invite) }
                } label: {
                    Text("Decline")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isProcessing)

                Button {
                    Task { await accept(invite) }
                } label: {
                    Group {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.9)
                                .tint(.white)
                        } else {
                            Text("Accept")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primaryAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isProcessing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .offset(y: dragOffset)
        .opacity(1.0 - min(1.0, abs(dragOffset) / 120.0))
        // simultaneousGesture keeps Decline / Accept tappable while allowing swipe-up to hide locally.
        .simultaneousGesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged { value in
                    let dy = value.translation.height
                    if dy < 0 {
                        dragOffset = dy
                    }
                }
                .onEnded { value in
                    let dy = value.translation.height
                    let predicted = value.predictedEndTranslation.height
                    let shouldDismiss = dy < -56 || predicted < -120
                    if shouldDismiss, let id = invite.id {
                        HapticManager.shared.lightImpact()
                        onlineManager.pinRoomInviteForBadgeAfterBannerSwipeDismiss(inviteId: id)
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                            bannerOnlyDismissedInviteIds.insert(id)
                            dragOffset = 0
                        }
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    private func loadInviterProfile(for invite: RoomInvite?) async {
        guard let invite else {
            await MainActor.run { inviterProfile = nil }
            return
        }
        await MainActor.run {
            isLoadingProfile = true
            inviterProfile = nil
        }
        do {
            let profile = try await FriendService.shared.getUserProfile(userId: invite.fromUserId)
            await MainActor.run {
                inviterProfile = profile
                isLoadingProfile = false
            }
        } catch {
            await MainActor.run { isLoadingProfile = false }
        }
    }

    private func decline(_ invite: RoomInvite) async {
        guard let id = invite.id else { return }
        isProcessing = true
        HapticManager.shared.lightImpact()
        await onlineManager.declineRoomInvite(id)
        isProcessing = false
    }

    private func accept(_ invite: RoomInvite) async {
        guard let id = invite.id else { return }
        isProcessing = true
        HapticManager.shared.mediumImpact()
        await onlineManager.acceptRoomInvite(id)
        await MainActor.run {
            isProcessing = false
            if onlineManager.currentRoom != nil {
                bannerOnlyDismissedInviteIds.remove(id)
                onAcceptedRoomInvite()
            } else {
                HapticManager.shared.error()
            }
        }
    }
}
