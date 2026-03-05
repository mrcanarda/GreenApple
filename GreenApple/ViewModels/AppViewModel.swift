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
import FirebaseFirestore

class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recipes: [Recipe] = Recipe.sampleRecipes
    @Published var userRecipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: RecipeCategory = .all
    @Published var showFavoritesOnly: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    @Published var username: String = ""
    
    private let db = Firestore.firestore()
    
    init() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isLoggedIn = true
            fetchUsername(uid: user.uid)
            fetchUserRecipes(uid: user.uid)
        }
    }
    
    // MARK: - Fetch Username
    func fetchUsername(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let name = data["username"] as? String {
                DispatchQueue.main.async {
                    self.username = name
                }
            }
        }
    }
    
    // MARK: - Save Username
    func saveUsername(uid: String, username: String) {
        db.collection("users").document(uid).setData(["username": username]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.username = username
                }
            }
        }
    }
    
    // MARK: - Fetch User Recipes from Firestore
    func fetchUserRecipes(uid: String) {
        db.collection("users").document(uid).collection("recipes").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let fetched: [Recipe] = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let idStr = data["id"] as? String, let id = UUID(uuidString: idStr),
                    let name = data["name"] as? String,
                    let description = data["description"] as? String,
                    let category = data["category"] as? String,
                    let imageName = data["imageName"] as? String,
                    let prepTime = data["prepTime"] as? Int,
                    let cookTime = data["cookTime"] as? Int,
                    let servings = data["servings"] as? Int,
                    let calories = data["calories"] as? Int,
                    let difficultyRaw = data["difficulty"] as? String,
                    let difficulty = Difficulty(rawValue: difficultyRaw),
                    let stepsRaw = data["steps"] as? [String]
                else { return nil }
                
                let ingredientsRaw = data["ingredients"] as? [[String: String]] ?? []
                let ingredients = ingredientsRaw.compactMap { d -> Ingredient? in
                    guard let name = d["name"], let amount = d["amount"], let unit = d["unit"] else { return nil }
                    return Ingredient(id: UUID(), name: name, amount: amount, unit: unit)
                }
                
                return Recipe(
                    id: id,
                    name: name,
                    description: description,
                    category: category,
                    imageName: imageName,
                    prepTime: prepTime,
                    cookTime: cookTime,
                    servings: servings,
                    calories: calories,
                    difficulty: difficulty,
                    ingredients: ingredients,
                    steps: stepsRaw,
                    reviews: [],
                    isFavorite: false
                )
            }
            DispatchQueue.main.async {
                self.userRecipes = fetched
                self.recipes = fetched + Recipe.sampleRecipes
                // Favorites'i recipes güncellendikten sonra uygula
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchFavorites(uid: uid)
                }
            }
        }
    }
    
    // MARK: - Save Recipe to Firestore
    func saveRecipeToFirestore(_ recipe: Recipe) {
        guard let uid = currentUser?.uid else { return }
        let data: [String: Any] = [
            "id": recipe.id.uuidString,
            "name": recipe.name,
            "description": recipe.description,
            "category": recipe.category,
            "imageName": recipe.imageName,
            "prepTime": recipe.prepTime,
            "cookTime": recipe.cookTime,
            "servings": recipe.servings,
            "calories": recipe.calories,
            "difficulty": recipe.difficulty.rawValue,
            "ingredients": recipe.ingredients.map { ["name": $0.name, "amount": $0.amount, "unit": $0.unit] },
            "steps": recipe.steps
        ]
        db.collection("users").document(uid).collection("recipes").document(recipe.id.uuidString).setData(data) { _ in
            DispatchQueue.main.async {
                self.userRecipes.insert(recipe, at: 0)
                self.recipes.insert(recipe, at: 0)
            }
        }
    }
    
    // MARK: - Delete User Recipe
    func deleteUserRecipe(_ recipe: Recipe) {
        guard let uid = currentUser?.uid else { return }
        db.collection("users").document(uid).collection("recipes").document(recipe.id.uuidString).delete()
        recipes.removeAll { $0.id == recipe.id }
        userRecipes.removeAll { $0.id == recipe.id }
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
    // MARK: - Toggle Favorite
    func toggleFavorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
            objectWillChange.send()
            saveFavorites()
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
    
    // MARK: - Delete Review
    func deleteReview(_ review: Review, from recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].reviews.removeAll { $0.id == review.id }
        }
    }
    
    // MARK: - Save Favorites
    func saveFavorites() {
        guard let uid = currentUser?.uid else { return }
        let favoriteIds = recipes.filter { $0.isFavorite }.map { $0.id.uuidString }
        db.collection("users").document(uid).setData(["favorites": favoriteIds], merge: true)
    }

    // MARK: - Fetch Favorites
    func fetchFavorites(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, _ in
            guard let ids = snapshot?.data()?["favorites"] as? [String] else { return }
            DispatchQueue.main.async {
                for id in ids {
                    if let index = self.recipes.firstIndex(where: { $0.id.uuidString == id }) {
                        self.recipes[index].isFavorite = true
                    }
                }
            }
        }
    }
    
    // MARK: - Edit Review
    func editReview(_ review: Review, rating: Int, comment: String, recipeId: UUID) {
        if let recipeIndex = recipes.firstIndex(where: { $0.id == recipeId }),
           let reviewIndex = recipes[recipeIndex].reviews.firstIndex(where: { $0.id == review.id }) {
            recipes[recipeIndex].reviews[reviewIndex].rating = rating
            recipes[recipeIndex].reviews[reviewIndex].comment = comment
        }
    }
}
