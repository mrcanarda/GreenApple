//
//  RecipeRow.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    var onFavoriteTap: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 14) {
            // Photo
            AsyncImage(url: URL(string: recipe.imageName)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Color("AppGreen").opacity(0.3)
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                
                Text(recipe.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppGreen"))
                        Text(recipe.formattedTotalTime)
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppGreen"))
                        Text("\(recipe.servings)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    Text(recipe.difficulty.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("AppGreen"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color("AppGreen").opacity(0.1))
                        .clipShape(Capsule())
                        .fixedSize()
                }
            }
            
            Spacer()
            
            // Favori
            Button {
                onFavoriteTap()
            } label: {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundColor(recipe.isFavorite ? .red : .secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}
