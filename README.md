# **LumiList**

 A movie marking and discovery app. Goal is to create a clean, user-friendly interface that helps users quickly evaluate films and build their own watchlist.

## **Main Functions：**

- Searching for movies by title/actor/type...
- Displaying detailed information such as poster, synopsis, cast, and release year
- Retrieving external ratings (e.g., IMDb, Rotten Tomatoes, Metascore) using publicly available APIs and gives a overall score
- Allowing users to manage a personal list of favorite movies, and gives score and film Review.
- Generate the rank of the movie list based on some rules.
- Based on the taste of the user, recommend users the movies they may like.
## FOR THE FILE
- /database/app_database : to define the database using Sqlite 
- /database/favorite :  add the movies which users click the ❤ button to the davorite movie list.
- /pages/widgets : define the format style (not used yet)
- /pages/search_page: using OMDB api,  could search movie by its title, support uzzy search (to do :return order by the similrity)
- /pages/movie_detail : show the movie info and the actors info, support to rating and add the movie to the favorite list

