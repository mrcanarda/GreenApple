//
//  AddRecipeView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

import SwiftUI
import Combine

struct AddRecipeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: RecipeCategory = .breakfast
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var servings = ""
    @State private var calories = ""
    @State private var imageURL = ""
    
    @State private var ingredients: [IngredientInput] = [IngredientInput()]
    @State private var steps: [String] = [""]
    
    @State private var isSaved = false
    @State private var showValidationError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Basic Info
                    sectionHeader("Basic Info")
                    
                    VStack(spacing: 14) {
                        inputField(icon: "fork.knife", placeholder: "Recipe name", text: $name)
                        inputField(icon: "text.alignleft", placeholder: "Short description", text: $description)
                        inputField(icon: "photo", placeholder: "Image URL (Unsplash etc.)", text: $imageURL)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Category
                    sectionHeader("Category")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(RecipeCategory.allCases.filter { $0 != .all }) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color("AppGreen") : Color(.systemGray6))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Difficulty
                    sectionHeader("Difficulty")
                    
                    HStack(spacing: 12) {
                        ForEach([Difficulty.easy, .medium, .hard], id: \.self) { diff in
                            Button {
                                selectedDifficulty = diff
                            } label: {
                                Text(diff.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedDifficulty == diff ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedDifficulty == diff ? Color("AppGreen") : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Time & Servings
                    sectionHeader("Details")
                    
                    HStack(spacing: 12) {
                        miniField(icon: "clock", placeholder: "Prep (min)", text: $prepTime)
                        miniField(icon: "flame", placeholder: "Cook (min)", text: $cookTime)
                        miniField(icon: "person.2", placeholder: "Servings", text: $servings)
                        miniField(icon: "heart", placeholder: "Calories", text: $calories)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Ingredients
                    sectionHeader("Ingredients")
                    
                    VStack(spacing: 10) {
                        ForEach(ingredients.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                TextField("Name", text: $ingredients[index].name)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(maxWidth: .infinity)
                                
                                TextField("Amount", text: $ingredients[index].amount)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(width: 70)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Unit", text: $ingredients[index].unit)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(width: 60)
                                
                                if ingredients.count > 1 {
                                    Button {
                                        ingredients.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                        }
                        
                        Button {
                            ingredients.append(IngredientInput())
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Ingredient")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color("AppGreen"))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Steps
                    sectionHeader("Instructions")
                    
                    VStack(spacing: 10) {
                        ForEach(steps.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color("AppGreen"))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.top, 8)
                                
                                TextField("Step \(index + 1)", text: $steps[index], axis: .vertical)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .lineLimit(3...)
                                
                                if steps.count > 1 {
                                    Button {
                                        steps.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.system(size: 20))
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                        
                        Button {
                            steps.append("")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Step")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color("AppGreen"))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Validation Error
                    if showValidationError {
                        Text("Please fill in all required fields.")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Save Button
                    Button {
                        saveRecipe()
                    } label: {
                        HStack {
                            if isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Recipe Added!")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Recipe")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("AppGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("AppGreen"))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    private func inputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color("AppGreen"))
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .autocorrectionDisabled()
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func miniField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color("AppGreen"))
            TextField(placeholder, text: text)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Save
    private func saveRecipe() {
        guard !name.isEmpty, !description.isEmpty,
              let prep = Int(prepTime), let cook = Int(cookTime),
              let serv = Int(servings), let cal = Int(calories),
              !ingredients.filter({ !$0.name.isEmpty }).isEmpty,
              !steps.filter({ !$0.isEmpty }).isEmpty else {
            showValidationError = true
            return
        }
        
        let newRecipe = Recipe(
            id: UUID(),
            name: name,
            description: description,
            category: selectedCategory.rawValue,
            imageName: imageURL.isEmpty ? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80" : imageURL,
            prepTime: prep,
            cookTime: cook,
            servings: serv,
            calories: cal,
            difficulty: selectedDifficulty,
            ingredients: ingredients.filter { !$0.name.isEmpty }.map {
                Ingredient(id: UUID(), name: $0.name, amount: $0.amount, unit: $0.unit)
            },
            steps: steps.filter { !$0.isEmpty },
            reviews: [],
            isFavorite: false
        )
              
        viewModel.saveRecipeToFirestore(newRecipe)
        withAnimation { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

// MARK: - Ingredient Input Model
struct IngredientInput: Identifiable {
    let id = UUID()
    var name = ""
    var amount = ""
    var unit = ""
}

#Preview {
    AddRecipeView()
        .environmentObject(AppViewModel())
}
