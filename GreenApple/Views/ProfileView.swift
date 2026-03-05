//
//  ProfileView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showSignOutAlert = false
    @State private var isEditingUsername = false
    @State private var newUsername = ""
    @State private var usernameAvailable: Bool? = nil
    @State private var isCheckingUsername = false
    @State private var isSavingUsername = false
    @State private var usernameError = ""
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var profileImageURL: String? = nil
    @State private var isUploadingPhoto = false
    
    @State private var selectedRecipe: Recipe? = nil
    @State private var showReviewsSheet = false
    @State private var recipeToDelete: Recipe? = nil
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Kullanıcının yazdığı tüm yorumlar
    private var myReviews: [(recipe: Recipe, review: Review)] {
        viewModel.recipes.flatMap { recipe in
            recipe.reviews
                .filter { $0.authorName == viewModel.username }
                .map { (recipe, $0) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Profile Header
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let image = profileImage {
                                    Image(uiImage: image).resizable().scaledToFill()
                                } else if let urlStr = profileImageURL, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let img): img.resizable().scaledToFill()
                                        default:
                                            Circle().fill(Color("AppGreen").opacity(0.15))
                                                .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(Color("AppGreen")))
                                        }
                                    }
                                } else {
                                    Circle().fill(Color("AppGreen").opacity(0.15))
                                        .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(Color("AppGreen")))
                                }
                            }
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("AppGreen"), lineWidth: 2))
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                ZStack {
                                    Circle().fill(Color("AppGreen")).frame(width: 28, height: 28)
                                    if isUploadingPhoto {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "camera.fill").font(.system(size: 12)).foregroundColor(.white)
                                    }
                                }
                            }
                            .disabled(isUploadingPhoto)
                        }
                        
                        if isEditingUsername {
                            editUsernameView
                        } else {
                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(viewModel.username.isEmpty ? "Set username" : "@\(viewModel.username)")
                                        .font(.system(size: 18, weight: .bold))
                                    Button {
                                        newUsername = viewModel.username
                                        usernameAvailable = nil
                                        isEditingUsername = true
                                    } label: {
                                        Image(systemName: "pencil").font(.system(size: 13)).foregroundColor(Color("AppGreen"))
                                    }
                                }
                                Text(viewModel.currentUser?.email ?? "").font(.system(size: 13)).foregroundColor(.secondary)
                                Text("Member since \(memberSince)").font(.system(size: 12)).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Stats
                    HStack(spacing: 0) {
                        statTile(value: "\(viewModel.recipes.count)", title: "Recipes")
                        Divider().frame(height: 40)
                        Button {
                            // favorites zaten aşağıda görünüyor
                        } label: {
                            statTile(value: "\(viewModel.favoriteRecipes.count)", title: "Favorites")
                        }
                        Divider().frame(height: 40)
                        Button {
                            showReviewsSheet = true
                        } label: {
                            statTile(value: "\(myReviews.count)", title: "Reviews")
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    
                    // MARK: - My Favorites
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
                                                case .success(let image): image.resizable().scaledToFill()
                                                default: Color("AppGreen").opacity(0.3)
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
                                        .onTapGesture { selectedRecipe = recipe }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // MARK: - My Recipes
                    if !viewModel.userRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Recipes")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                ForEach(viewModel.userRecipes) { recipe in
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: recipe.imageName)) { phase in
                                            switch phase {
                                            case .success(let image): image.resizable().scaledToFill()
                                            default: Color("AppGreen").opacity(0.3)
                                            }
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(recipe.name).font(.system(size: 15, weight: .semibold)).lineLimit(1)
                                            Text(recipe.formattedTotalTime).font(.system(size: 12)).foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            recipeToDelete = recipe

                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .background(Color.red.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .onTapGesture { selectedRecipe = recipe }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Sign Out
                    Button { showSignOutAlert = true } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out").font(.system(size: 16, weight: .semibold))
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
                    Button("Done") { dismiss() }.foregroundColor(Color("AppGreen"))
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) { signOut() }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipeId: recipe.id)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showReviewsSheet) {
                MyReviewsView(myReviews: myReviews)
                    .environmentObject(viewModel)
            }
            .alert("Delete Recipe", isPresented: Binding(
                get: { recipeToDelete != nil },
                set: { if !$0 { recipeToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { recipeToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let r = recipeToDelete { viewModel.deleteUserRecipe(r) }
                    recipeToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this recipe?")
            }
            .onChange(of: selectedPhoto) { _, item in
                Task { await loadAndUploadPhoto(item: item) }
            }
            .onAppear { loadProfileImageURL() }
        }
    }
    
    // MARK: - Edit Username View
    private var editUsernameView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text("@").font(.system(size: 16, weight: .semibold)).foregroundColor(Color("AppGreen"))
                TextField("username", text: $newUsername)
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: newUsername) { _, val in checkUsername(val) }
                
                if isCheckingUsername {
                    ProgressView().scaleEffect(0.8)
                } else if let available = usernameAvailable {
                    Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(available ? Color("AppGreen") : .red)
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            if !usernameError.isEmpty {
                Text(usernameError).font(.system(size: 12)).foregroundColor(.red)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") { isEditingUsername = false; usernameError = "" }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color(.systemGray6)).clipShape(Capsule())
                
                Button { saveNewUsername() } label: {
                    HStack(spacing: 4) {
                        if isSavingUsername {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                        } else {
                            Text("Save")
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(usernameAvailable == true ? Color("AppGreen") : Color.gray)
                    .clipShape(Capsule())
                }
                .disabled(usernameAvailable != true || isSavingUsername)
            }
        }
    }
    
    // MARK: - Helpers
    private var memberSince: String {
        guard let date = viewModel.currentUser?.metadata.creationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func statTile(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .bold))
            Text(title).font(.system(size: 12)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func checkUsername(_ value: String) {
        usernameError = ""; usernameAvailable = nil
        guard value.count >= 3 else { usernameError = "At least 3 characters required"; return }
        guard value == value.lowercased(), !value.contains(" ") else { usernameError = "Lowercase letters only, no spaces"; return }
        if value == viewModel.username { usernameAvailable = true; return }
        isCheckingUsername = true
        db.collection("users").whereField("username", isEqualTo: value).getDocuments { snapshot, _ in
            DispatchQueue.main.async {
                isCheckingUsername = false
                usernameAvailable = snapshot?.documents.isEmpty == true
                if usernameAvailable == false { usernameError = "This username is already taken" }
            }
        }
    }
    
    private func saveNewUsername() {
        guard let uid = viewModel.currentUser?.uid else { return }
        isSavingUsername = true
        db.collection("users").document(uid).setData(["username": newUsername], merge: true) { error in
            DispatchQueue.main.async {
                isSavingUsername = false
                if error == nil { viewModel.username = newUsername; isEditingUsername = false }
            }
        }
    }
    
    private func loadAndUploadPhoto(item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let uid = viewModel.currentUser?.uid else { return }
        await MainActor.run { isUploadingPhoto = true; profileImage = image }
        guard let compressed = image.jpegData(compressionQuality: 0.6) else { return }
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        do {
            _ = try await ref.putDataAsync(compressed)
            ref.downloadURL { url, error in
                guard let url = url else { return }
                self.db.collection("users").document(uid).setData(["profileImageURL": url.absoluteString], merge: true)
                DispatchQueue.main.async { self.profileImageURL = url.absoluteString; self.isUploadingPhoto = false }
            }
        } catch {
            await MainActor.run { isUploadingPhoto = false }
        }
    }
    
    private func loadProfileImageURL() {
        guard let uid = viewModel.currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data(), let url = data["profileImageURL"] as? String {
                DispatchQueue.main.async { profileImageURL = url }
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            viewModel.currentUser = nil
            viewModel.isLoggedIn = false
            viewModel.username = ""
            dismiss()
        } catch { print("Sign out error: \(error)") }
    }
}

// MARK: - My Reviews View
struct MyReviewsView: View {
    let myReviews: [(recipe: Recipe, review: Review)]
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if myReviews.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "star").font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No reviews yet").font(.headline).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(myReviews, id: \.review.id) { item in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: item.recipe.imageName)) { phase in
                                        switch phase {
                                        case .success(let image): image.resizable().scaledToFill()
                                        default: Color("AppGreen").opacity(0.3)
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.recipe.name).font(.system(size: 15, weight: .semibold)).lineLimit(1)
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= item.review.rating ? "star.fill" : "star")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.yellow)
                                            }
                                            Text("\(item.review.rating)/5")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                
                                Text(item.review.comment)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("My Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("AppGreen"))
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
}
