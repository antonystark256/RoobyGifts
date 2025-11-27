import SwiftUI

// MARK: - ONBOARDING DATA MODEL
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let mascot: Image
    let iconName: String
}

// MARK: - ONBOARDING VIEW
struct OnboardingView: View {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted = false
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Organize Your\nWishes",
            subtitle: "Create beautiful wishlists, track prices, and share what you really want.",
            mascot: Kangaroo.waving.image,
            iconName: "heart.fill"
        ),
        OnboardingPage(
            title: "AI Gift\nGenius",
            subtitle: "Stuck on ideas? Let our AI suggest the perfect gift based on personality & interests.",
            mascot: Kangaroo.idea.image,
            iconName: "sparkles"
        ),
        OnboardingPage(
            title: "Never Miss a\nMoment",
            subtitle: "Track birthdays, organize Secret Santa, and keep your certificates ready.",
            mascot: Kangaroo.withTablet.image,
            iconName: "calendar.badge.clock"
        ),
        OnboardingPage(
            title: "Become a\nGifting Legend",
            subtitle: "Unlock achievements and master the art of giving. Let's get started!",
            mascot: Kangaroo.winner.image,
            iconName: "trophy.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND
            Color.appBackground.ignoresSafeArea()
            
            // Atmospheric Glows
            ZStack {
                Circle()
                    .fill(Color.appPurple.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -100, y: -200)
                
                Circle()
                    .fill(Color.appYellow.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 120, y: 150)
            }
            
            // 2. CONTENT TAB VIEW
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isCurrent: currentPage == index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // 3. BOTTOM CONTROLS
            VStack {
                Spacer()
                
                VStack(spacing: 30) {
                    // Custom Page Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.appPurple : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Action Button
                    Button {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                completeOnboarding()
                            }
                        }
                    } label: {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [.appPurple, .appPurple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: .appPurple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
        .animation(.default, value: currentPage)
    }
    
    private func completeOnboarding() {
        withAnimation {
            isOnboardingCompleted = true
        }
    }
}

// MARK: - SINGLE PAGE SUBVIEW
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isCurrent: Bool
    
    @State private var animateImage = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            
            // Icon Badge
            if isCurrent {
                Image(systemName: page.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.appPurple)
                    .padding(20)
                    .background(Color.appCard)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 20)
            }
            
            // Mascot Image
            page.mascot
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .scaleEffect(animateImage ? 1.0 : 0.8)
                .opacity(animateImage ? 1.0 : 0.0)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

            Spacer().frame(height: 5)
            
            // Texts
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineLimit(3)
            }
            .offset(y: animateText ? 0 : 20)
            .opacity(animateText ? 1.0 : 0.0)
            .padding(.bottom, 20)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            // Trigger animations when this page appears
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateImage = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateText = true
            }
        }
        .onDisappear {
            animateImage = false
            animateText = false
        }
    }
}
