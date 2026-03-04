//
//  ProfileView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

//
//  ProfileView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Avatar
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color("AppGreen").opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color("AppGreen"))
                        }
                        
                        Text(viewModel.currentUser?.email ?? "User")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Member since \(memberSince)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stats
                    HStack(spacing: 0) {
                        statTile(value: "\(viewModel.recipes.count)", title: "Recipes")
                        Divider().frame(height: 40)
                        statTile(value: "\(viewModel.favoriteRecipes.count)", title: "Favorites")
                        Divider().frame(height: 40)
                        statTile(value: "\(totalReviews)", title: "Reviews")
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    
                    // Favorites Section
                    if !viewModel.favoriteRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Favorites")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.favoriteRecipes) { recipe in
                                        VStack(alignment: .leading, spacing: 6) {
                                            AsyncImage(url: URL(string: recipe.imageName)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image.resizable().scaledToFill()
                                                default:
                                                    Color("AppGreen").opacity(0.3)
                                                }
                                            }
                                            .frame(width: 130, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Text(recipe.name)
                                                .font(.system(size: 13, weight: .semibold))
                                                .lineLimit(1)
                                                .frame(width: 130, alignment: .leading)
                                            
                                            Text(recipe.formattedTotalTime)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Sign Out
                    Button {
                        showSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AppGreen"))
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private var memberSince: String {
        guard let date = viewModel.currentUser?.metadata.creationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private var totalReviews: Int {
        viewModel.recipes.reduce(0) { $0 + $1.reviews.count }
    }
    
    private func statTile(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .bold))
            Text(title).font(.system(size: 12)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            viewModel.currentUser = nil
            viewModel.isLoggedIn = false
            dismiss()
        } catch {
            print("Sign out error: \(error)")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
}
