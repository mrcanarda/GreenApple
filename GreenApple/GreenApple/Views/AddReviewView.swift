//
//  AddReviewView.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct AddReviewView: View {
    let recipeId: UUID
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var authorName: String = ""
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitted = false
    
    private var recipe: Recipe? {
        viewModel.recipes.first(where: { $0.id == recipeId })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Recipe info
                    HStack(spacing: 14) {
                        AsyncImage(url: URL(string: recipe?.imageName ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Color("AppGreen").opacity(0.3)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe?.name ?? "")
                                .font(.system(size: 16, weight: .bold))
                            Text("Share your experience")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.system(size: 15, weight: .semibold))
                        TextField("Enter your name", text: $authorName)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .autocorrectionDisabled()
                    }
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                            .font(.system(size: 15, weight: .semibold))
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        rating = star
                                    }
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(star <= rating ? .yellow : .secondary)
                                        .scaleEffect(star == rating ? 1.2 : 1.0)
                                }
                            }
                        }
                    }
                    
                    // Comment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comment")
                            .font(.system(size: 15, weight: .semibold))
                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .autocorrectionDisabled()
                    }
                    
                    // Submit
                    Button {
                        submitReview()
                    } label: {
                        HStack {
                            if isSubmitted {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Review Submitted!")
                            } else {
                                Text("Submit Review")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(authorName.isEmpty || comment.isEmpty ? Color.gray : Color("AppGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(authorName.isEmpty || comment.isEmpty || isSubmitted)
                }
                .padding(20)
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("AppGreen"))
                }
            }
        }
    }
    
    private func submitReview() {
        guard let recipe = recipe else { return }
        let review = Review(
            id: UUID(),
            authorName: authorName,
            authorAvatar: "person.circle.fill",
            rating: rating,
            comment: comment,
            imageName: nil,
            date: Date()
        )
        viewModel.addReview(review, to: recipe)
        withAnimation { isSubmitted = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

#Preview {
    AddReviewView(recipeId: Recipe.sampleRecipes[0].id)
        .environmentObject(AppViewModel())
}
