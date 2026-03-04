//
//  HomeView.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedRecipe: Recipe? = nil
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    searchBar
                    categorySection
                    
                    if viewModel.filteredRecipes.isEmpty {
                        emptyView
                    } else {
                        featuredSection
                        recipesGrid
                    }
                }
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("GreenApple 🍏")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color("AppGreen"))
                    }
                }
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipeId: recipe.id)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search recipes...", text: $viewModel.searchText)
                .font(.system(size: 15))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: viewModel.searchText.isEmpty)
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RecipeCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.filteredRecipes.prefix(3)) { recipe in
                        FeaturedCard(recipe: recipe)
                            .onTapGesture {
                                selectedRecipe = recipe
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recipes Grid
    private var recipesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Recipes")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    RecipeRow(recipe: viewModel.recipes.first(where: { $0.id == recipe.id }) ?? recipe, onFavoriteTap: {
                        viewModel.toggleFavorite(recipe)
                    })
                    .onTapGesture {
                        selectedRecipe = recipe
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No recipes found")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
