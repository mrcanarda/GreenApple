//
//  EditReviewView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

import SwiftUI

struct EditReviewView: View {
    let review: Review
    let recipeId: UUID
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Int
    @State private var comment: String
    @State private var isSaved = false
    
    init(review: Review, recipeId: UUID) {
        self.review = review
        self.recipeId = recipeId
        _rating = State(initialValue: review.rating)
        _comment = State(initialValue: review.comment)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
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
                    
                    // Save Button
                    Button {
                        saveEdit()
                    } label: {
                        HStack {
                            if isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Saved!")
                            } else {
                                Text("Save Changes")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(comment.isEmpty ? Color.gray : Color("AppGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(comment.isEmpty || isSaved)
                }
                .padding(20)
            }
            .navigationTitle("Edit Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("AppGreen"))
                }
            }
        }
    }
    
    private func saveEdit() {
        viewModel.editReview(review, rating: rating, comment: comment, recipeId: recipeId)
        withAnimation { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}
