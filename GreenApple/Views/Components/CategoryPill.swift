//
//  CategoryPill.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct CategoryPill: View {
    let category: RecipeCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color("AppGreen") : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}
