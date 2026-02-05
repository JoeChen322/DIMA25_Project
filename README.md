# **LumiList**

 A movie marking and discovery app. Goal is to create a clean, user-friendly interface that helps users quickly evaluate films and build their own watchlist.
## TODO
- make the main page adapt to landscape 
- pull down to show the complete poster?
- adjust search relevance
- light and dark modes
## Main Functions：
- Show the recently popular movies
- Searching for movies by title (support fuzzy search), and display the detailed information such as poster, synopsis, cast, director and release year
- Retrieving external ratings (e.g. IMDb, Rotten Tomatoes, Metascore) using publicly available APIs
- Allowing users to manage a personal list of favorite movies, and gives score.
- Generate the rank of the movie list based on some rules.
- Based on the taste of the user, recommend users the classic movies they may like.
## Adaptive
- adjust the different sccreen size
- have different widget distributions on phone and pad
## Repository Organization
### /database
- /database/app_database : to define the database using Sqlite 
- /database/favorite :  store the movies which users click the ❤ button to the favorite movie list
- /database/personal rating:  store the movies which users give a personal score
- /database/see later :  store the movies which users click the Later button to see later list
### /widgets
-  define the format style
### /pages
- /pages/search_page: using OMDB API (in /lib/service),  could search movie by its title, support fuzzy search (to do :return order by the similarity)
- /pages/movie_detail : show the movie info and the actors info, support to rating and add the movie to the favorite list
## Improvement 
- Support search by the actor or movie type