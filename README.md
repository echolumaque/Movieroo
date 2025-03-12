# Movieroo – a movie catalog iOS application

**Movieroo** is a simple yet feature-rich iOS application that allows users to discover and bookmark their favorite movies effortlessly. Upon launching the app, users are greeted with lots of movie data that loads seamlessly from a remote API.

The main screen presents a searchable and filterable list of movies, enabling users to quickly find films by name or genre. Selecting a movie displays its details, where users can add movies to their personalized bookmarks. The bookmarked movies are neatly organized on a dedicated screen, ensuring quick access to users’ favorites.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Room for Improvement](#room-for-improvement)

---

## Overview
**Purpose**: This project is designed to showcase a wide variety of fundamental iOS development skills, including:
- Networking with `URLSession`
- Swift structured concurrency (`async`/`await`)
- Decoding JSON via `Codable`
- UIKit 
- `AutoLayout` for stunning user interface design
- Basic data persistence using `UserDefaults`
- Proper separation of responsibilities as per `VIPER`, and `MVVM-C` architecture design pattern
- Dependency Injection using `Swinject`
- `Cocoapods` for package management

**Core functionalities**:
1. 📋 Movie List Screen
- Displays a scrollable list of movies.
	- Each movie cell includes:
	  - ✅ Movie trailer (poster image if not available)
	  - ✅ Movie Title
	  - ✅ Movie Runtime
	  - ✅ Movie recommendations based on the seleccted movie
	  - ✅ Movie Genre
	  - ✅ Movie Review
	- Provides search functionality by movie title.
	- Offers filter functionality by movie genre.
2. 🎞️ Movie Detail Screen
   - Opens upon selecting a movie from the list.
   - Plays the movie trailer from inside Movieroo
   - Shows detailed information about the movie.
   - Includes a button to bookmark or save the movie.
3. 🔖 Bookmarks Screen
   - Lists all bookmarked movies.
   - Each bookmarked movie cell shows:
      - ✅ Movie trailer (poster image if not available)
	  - ✅ Movie Title
	  - ✅ Movie Runtime
	  - ✅ Movie recommendations based on the seleccted movie
	  - ✅ Movie Genre
	  - ✅ Movie Review
   - No search or filter functionality (simple, quick access).
---

## Features
- **Movie Catalog**  
  Fetched from [The Movie Database](https://developer.themoviedb.org/reference/intro/getting-started) using `URLSession`
- **Swift Concurrency**  
  Utilizes `async/await` to simplify network call syntax and handle concurrency safely.

---

## Architecture
This app is created with clear separation of responsibilities in mind. The movies tab is architected using the [VIPER pattern](https://medium.com/@pinarkocak/understanding-viper-pattern-619fa9a0b1f1), while the bookmarks tab is architected using [MVVM-C pattern](https://medium.com/sudo-by-icalia-labs/ios-architecture-mvvm-c-introduction-1-6-815204248518).

---

## Requirements
1. Xcode **16** or higher.
2. iOS **18** or higher.

---

## Getting Started

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/echolumaque/Movieroo.git
   cd your-movieroo-project-path
   
2. **Open the Project**
   - Double-click on Movieroo.xcworkspace or open it via Xcode.

3.	**Build & Run**
  - Select the appropriate iOS Simulator or a real device in Xcode’s scheme.
  - Press ⌘ + R (Run).


## Usage
1.	Launch the App
  - You’ll see lots of movies in the movies tab
2.	Tap a movie
  - Tapping a movie shows its details like the trailer, runtime, synopsis, recommendations, and reviews.
3.	Enjoy the Movie Facts
  - Use it as a fun reference, or just amuse yourself with random movie content.
  
  
## Room for Improvement
- Better Error Handling: Show a user-friendly message if the network fails.
- Caching: Implement image or fact caching to reduce repetitive network calls.
- Offline Mode: Persist previously loaded data so the user sees something if offline.
- Testing & Mocks: Expand unit test coverage, especially around network failures or decoding edge cases.
- UI Enhancements: Animate transitions between images and facts.
