# 🎬 LumiList

LumiList is a modern, cross-platform movie marking and discovery application built with Flutter. It provides a clean, user-friendly interface to help cinephiles quickly evaluate films, track their viewing history, and build personalized watchlists.

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](#)

---

## ✨ Key Features

* **Real-time Discovery**: Explore and stay updated with the most popular movies currently trending.
* **Intelligent Search**: Find movies by title using fuzzy search logic, providing detailed info including posters, synopses, cast, and directors.
* **External Ratings Integration**: Instantly view ratings from authoritative sources like **IMDb**, **Rotten Tomatoes**, and **Metascore** via public APIs.
* **Personal Collection Management**: 
    * **Favorites**: Heart your top picks to save them to your personal database.
    * **Watchlist**: Save movies to a "See Later" list with a single tap.
    * **Personal Ratings**: Rate movies you've watched to keep a record of your personal taste.
* **Recommendations System**: Get suggestions for classic movies tailored to your specific taste.
* **Adaptive UI**: Optimized layouts for both mobile phones and tablets, ensuring a seamless experience across different screen sizes.Dark and Light modes with the system.

---

## 📂 Repository Organization

The project follows a modular structure to separate data logic from the user interface:

### `/database`
Defines the local data persistence layer using **Firebase** , achieve real-time update and synchronous across devices:
* **`user`**: Info of the users email, password, username and profile.
* **`favorite`**: Manages movies marked with the ❤ button.
* **`personal_rating`**: Stores movies with user-assigned scores.
* **`see_later`**: Manages the "Watch Later" list.

### `/pages`
Contains the primary application screens and business logic:
* **`search_page`**: Integrated with the **OMDB API** to support title-based fuzzy search.
* **`movie_detail`**: Displays comprehensive movie metadata and cast info; allows users to rate or add movies to favorites.

### `/widgets`
* Contains reusable components and defines the global format styles for the application.

---

## 🛠️ Technical Stack

* **Framework**: Flutter (SDK 3.3.0+)
* **Networking**: `dio` for API interactions
* **Database**: `Firebase` for cloud data persistence
* **Assets**: Custom icons and launcher configurations for Android/iOS

---

## 🚀 Getting Started

1.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run the application**:
    ```bash
    flutter run
    ```

---

## 📝 Future Work

- [ ] Support searching by actors or movie genres.
- [ ] Perfect recommand system.
- [ ] Enhanced search relevance sorting.

---
*Created for the DIMA25 Project.*
