# 🍏 GreenApple

A modern recipe discovery iOS app built with **Swift & SwiftUI**, featuring Firebase authentication, 40+ recipes across 6 categories, user-generated content, and clean MVVM architecture.

---

## 📱 Screenshots

> _Add your screenshots here_

---

## ✨ Features

- 🔐 **Firebase Authentication** — Email/password sign up & sign in
- 👤 **User Profiles** — Custom username, member since date, stats overview
- 🍽️ **40+ Recipes** — Across 6 categories: Breakfast, Lunch, Dinner, Snacks, Desserts, Drinks
- ➕ **Add Recipes** — Users can create and publish their own recipes
- ❤️ **Favorites** — Save and manage favorite recipes (persisted via Firestore)
- ⭐ **Reviews** — Add, edit, and delete reviews with star ratings
- 🔍 **Search & Filter** — Real-time search and category filtering
- 📏 **Portion Scaling** — Dynamically scale ingredient amounts by servings
- ☁️ **Firestore Integration** — User recipes and favorites stored in the cloud
- 🌙 **Dark Mode** — Full dark mode support

---

## 🏗️ Architecture

```
GreenApple/
├── Models/
│   └── RecipeModel.swift       # Recipe, Ingredient, Review structs
├── ViewModels/
│   └── AppViewModel.swift      # Business logic, Firebase calls
└── Views/
    ├── Components/
    │   ├── CategoryPill.swift
    │   ├── FeaturedCard.swift
    │   └── RecipeRow.swift
    ├── HomeView.swift
    ├── RecipeDetailView.swift
    ├── AddRecipeView.swift
    ├── AddReviewView.swift
    ├── EditReviewView.swift
    ├── ProfileView.swift
    └── AuthView.swift
```

**Pattern:** MVVM (Model-View-ViewModel)

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| Swift 5 | Primary language |
| SwiftUI | UI framework |
| Firebase Auth | User authentication |
| Cloud Firestore | Database |
| MVVM | Architecture pattern |

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- A Firebase project

### Setup

1. Clone the repository
```bash
git clone https://github.com/mrcanarda/GreenApple.git
cd GreenApple
```

2. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

3. Enable **Authentication** (Email/Password) and **Firestore Database**

4. Download `GoogleService-Info.plist` and add it to the `GreenApple/` folder

5. Open `GreenApple.xcodeproj` in Xcode

6. Build and run ▶️

---

## 📦 Dependencies

- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) — Authentication & Firestore

Added via Swift Package Manager.

---

## 👨‍💻 Author

**Can Arda**
- GitHub: [@mrcanarda](https://github.com/mrcanarda)
- LinkedIn: [linkedin.com/in/can-arda](https://linkedin.com/in/can-arda)
- Portfolio: [canarda.com](https://canarda.com)

---

## 📄 License

This project is licensed under the MIT License.
