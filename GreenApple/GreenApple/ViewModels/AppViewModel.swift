//
//  AppViewModel.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recipes: [Recipe] = Recipe.sampleRecipes
    @Published var searchText: String = ""
    @Published var selectedCategory: RecipeCategory = .all
    @Published var showFavoritesOnly: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    init() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    // MARK: - Filtered Recipes
    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesCategory = selectedCategory == .all || recipe.recipeCategory == selectedCategory
            let matchesSearch = searchText.isEmpty || recipe.name.localizedCaseInsensitiveContains(searchText) || recipe.description.localizedCaseInsensitiveContains(searchText)
            let matchesFavorite = !showFavoritesOnly || recipe.isFavorite
            return matchesCategory && matchesSearch && matchesFavorite
        }
    }
    
    // MARK: - Favorite Recipes
    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
            objectWillChange.send()
        }
    }
    
    // MARK: - Add Review
    func addReview(_ review: Review, to recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].reviews.append(review)
        }
    }
    
    // MARK: - Scale Servings
    func scaledAmount(amount: String, originalServings: Int, newServings: Int) -> String {
        guard let value = Double(amount) else { return amount }
        let scaled = value * Double(newServings) / Double(originalServings)
        if scaled == scaled.rounded() {
            return String(Int(scaled))
        }
        return String(format: "%.1f", scaled)
    }
}
