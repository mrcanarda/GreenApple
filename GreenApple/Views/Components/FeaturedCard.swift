//
//  FeaturedCard.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct FeaturedCard: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
            .frame(width: 280, height: 180)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(recipe.formattedTotalTime)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                        Text("\(recipe.calories) cal")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    
                    // Difficulty badge
                    Text(recipe.difficulty.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                }
            }
            .padding(14)
        }
        .frame(width: 280, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .overlay(alignment: .topTrailing) {
            // Favori butonu
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 14))
                .foregroundColor(recipe.isFavorite ? .red : .white)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(10)
        }
    }
}
