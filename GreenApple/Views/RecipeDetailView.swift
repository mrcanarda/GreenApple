//
//  RecipeDetailView.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipeId: UUID
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedServings: Int = 2
    @State private var showReviewSheet = false
    @State private var currentStep = 0
    @State private var editingReview: Review? = nil
    @State private var reviewToDelete: Review? = nil
    
    private var recipe: Recipe? {
        viewModel.recipes.first(where: { $0.id == recipeId })
    }
    
    var body: some View {
        if let recipe = recipe {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        heroSection(recipe: recipe)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            infoSection(recipe: recipe)
                            Divider()
                            ingredientsSection(recipe: recipe)
                            Divider()
                            stepsSection(recipe: recipe)
                            Divider()
                            reviewsSection(recipe: recipe)
                        }
                        .padding(24)
                        
                        Color.clear.frame(height: 40)
                    }
                }
                .scrollIndicators(.hidden)
                .navigationTitle(recipe.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.toggleFavorite(recipe)
                        } label: {
                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(recipe.isFavorite ? .red : .primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showReviewSheet) {
                AddReviewView(recipeId: recipeId)
                    .environmentObject(viewModel)
            }
            .sheet(item: $editingReview) { review in
                EditReviewView(review: review, recipeId: recipeId)
                    .environmentObject(viewModel)
            }
            .alert("Delete Review", isPresented: Binding(
                get: { reviewToDelete != nil },
                set: { if !$0 { reviewToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { reviewToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let r = reviewToDelete { viewModel.deleteReview(r, from: recipe) }
                    reviewToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this review?")
            }
            .onAppear {
                selectedServings = recipe.servings
            }
        }
    }
    
    // MARK: - Hero
    private func heroSection(recipe: Recipe) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: recipe.imageName)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color("AppGreen").opacity(0.3)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipped()
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill").font(.system(size: 13))
                    Text(recipe.formattedTotalTime).font(.system(size: 14))
                }
                .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 13))
                    Text("\(recipe.calories) cal").font(.system(size: 14))
                }
                .foregroundColor(.white.opacity(0.9))
                
                Text(recipe.difficulty.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
            .padding(20)
        }
    }
    
    // MARK: - Info
    private func infoSection(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.description)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            HStack(spacing: 0) {
                infoTile(icon: "clock", title: "Prep", value: "\(recipe.prepTime)m")
                Divider().frame(height: 40)
                infoTile(icon: "flame.fill", title: "Cook", value: "\(recipe.cookTime)m")
                Divider().frame(height: 40)
                infoTile(icon: "person.2.fill", title: "Serves", value: "\(recipe.servings)")
                Divider().frame(height: 40)
                infoTile(icon: "heart.fill", title: "Calories", value: "\(recipe.calories)")
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if !recipe.reviews.isEmpty {
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(recipe.averageRating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }
                    Text(String(format: "%.1f", recipe.averageRating))
                        .font(.system(size: 14, weight: .semibold))
                    Text("(\(recipe.reviews.count) reviews)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func infoTile(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(Color("AppGreen"))
            Text(value).font(.system(size: 15, weight: .bold))
            Text(title).font(.system(size: 11)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Ingredients
    private func ingredientsSection(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Ingredients").font(.system(size: 20, weight: .bold))
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        if selectedServings > 1 { withAnimation { selectedServings -= 1 } }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedServings == 1 ? .secondary : Color("AppGreen"))
                            .frame(width: 28, height: 28)
                            .background(Color("AppGreen").opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(selectedServings == 1)
                    
                    Text("\(selectedServings)").font(.system(size: 16, weight: .bold)).frame(minWidth: 20)
                    
                    Button {
                        withAnimation { selectedServings += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color("AppGreen"))
                            .clipShape(Circle())
                    }
                }
            }
            
            VStack(spacing: 10) {
                ForEach(recipe.ingredients) { ingredient in
                    HStack {
                        Circle().fill(Color("AppGreen")).frame(width: 8, height: 8)
                        Text(ingredient.name).font(.system(size: 15))
                        Spacer()
                        Text("\(viewModel.scaledAmount(amount: ingredient.amount, originalServings: recipe.servings, newServings: selectedServings)) \(ingredient.unit)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("AppGreen"))
                    }
                    .padding(.vertical, 4)
                    if ingredient.id != recipe.ingredients.last?.id { Divider() }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Steps
    private func stepsSection(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Instructions").font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 12) {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(index <= currentStep ? Color("AppGreen") : Color(.systemGray5))
                                .frame(width: 32, height: 32)
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(index <= currentStep ? .white : .secondary)
                        }
                        Text(step)
                            .font(.system(size: 15))
                            .foregroundColor(index <= currentStep ? .primary : .secondary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(14)
                    .background(index <= currentStep ? Color("AppGreen").opacity(0.05) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) { currentStep = index }
                    }
                }
            }
        }
    }
    
    // MARK: - Reviews
    private func reviewsSection(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Reviews").font(.system(size: 20, weight: .bold))
                Spacer()
                Button { showReviewSheet = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                        Text("Add Review").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color("AppGreen"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AppGreen").opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            if recipe.reviews.isEmpty {
                Text("No reviews yet. Be the first!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(recipe.reviews) { review in
                        ReviewCard(
                            review: review,
                            currentUsername: viewModel.username,
                            onDelete: {
                                reviewToDelete = review
                            },
                            onEdit: {
                                editingReview = review
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: Review
    let currentUsername: String
    var onDelete: () -> Void = {}
    var onEdit: () -> Void = {}
    
    var isOwner: Bool {
        !currentUsername.isEmpty && review.authorName == currentUsername
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: review.authorAvatar)
                    .font(.system(size: 24))
                    .foregroundColor(Color("AppGreen"))
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorName).font(.system(size: 14, weight: .semibold))
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                Spacer()
                if isOwner {
                    Menu {
                        Button { onEdit() } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) { onDelete() } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
            }
            Text(review.comment).font(.system(size: 14)).foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    RecipeDetailView(recipeId: Recipe.sampleRecipes[0].id)
        .environmentObject(AppViewModel())
}
