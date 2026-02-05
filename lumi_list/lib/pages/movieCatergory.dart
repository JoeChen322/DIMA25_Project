/*store top10 movies of several categories as static data for category detail page*/
/*not change frequently, small data size,
so no need to fetch from API, and can be easily updated by editing this statistic file*/

class MovieCategoryData {
  static const Map<String, List<Map<String, String>>> categories = {
    'Fiction': [
      {
        'id': 'tt1375666',
        'title': 'Inception',
        'year': '2010',
        'director': 'Christopher Nolan',
        'summary': 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_SX300.jpg'
      },
      {
        'id': 'tt0816692',
        'title': 'Interstellar',
        'year': '2014',
        'director': 'Christopher Nolan',
        'summary': 'When Earth becomes uninhabitable, a farmer and ex-pilot is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BYzdjMDAxZGItMjI2My00ODA1LTlkNzItOWFjMDU5ZDJlYWY3XkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0133093',
        'title': 'The Matrix',
        'year': '1999',
        'director': 'Lana Wachowski, Lilly Wachowski',
        'summary': 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNzQzOTk3OTAtNDQ0Zi00ZTVkLWI0MTEtMDllZjNkYzNjNTc4L2ltYWdlXkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_SX300.jpg'
      },
      {
        'id': 'tt1856101',
        'title': 'Blade Runner 2049',
        'year': '2017',
        'director': 'Denis Villeneuve',
        'summary': 'Young Blade Runner K\'s discovery of a long-buried secret leads him to track down former Blade Runner Rick Deckard, who\'s been missing for thirty years.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNzI2NjU0MjY4MF5BMl5BanBnXkFtZTgwMjM0NDQzNjE@._V1_SX300.jpg'
      },
      {
        'id': 'tt1160419',
        'title': 'Dune',
        'year': '2021',
        'director': 'Denis Villeneuve',
        'summary': 'A noble family becomes embroiled in a war for control over the galaxy\'s most valuable asset while its heir becomes troubled by visions of a dark future.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BN2FjNmEyNWMtYzM0ZS00NjIyLTg5YzYtYThlMGVjNzE1OGViXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_SX300.jpg'
      },
    ],
    'Action': [
      {
        'id': 'tt0468569',
        'title': 'The Dark Knight',
        'year': '2008',
        'director': 'Christopher Nolan',
        'summary': 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg'
      },
      {
        'id': 'tt0103064',
        'title': 'Terminator 2: Judgment Day',
        'year': '1991',
        'director': 'James Cameron',
        'summary': 'A cyborg, identical to the one who failed to kill Sarah Connor, must now protect her ten year old son John from a more advanced and powerful cyborg.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMGU2NzRmZjUtOGUxYS00ZjdjLWEwZWItY2NlM2JhNjkxNTFmXkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_SX300.jpg'
      },
      {
        'id': 'tt0172495',
        'title': 'Gladiator',
        'year': '2000',
        'director': 'Ridley Scott',
        'summary': 'A former Roman General sets out to exact vengeance against the corrupt emperor who murdered his family and sent him into slavery.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BYWQ4YmNjYjEtOWE1Zi00Y2U4LWI4NTAtMTU0MjkxNWQ1ZmJiXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt1745960',
        'title': 'Top Gun: Maverick',
        'year': '2022',
        'director': 'Joseph Kosinski',
        'summary': 'After thirty years, Maverick is still pushing the envelope as a top naval aviator, but must confront ghosts of his past when he leads TOP GUN\'s elite graduates on a mission.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMDBkZDNjMWEtOTdmMi00NmExLTg5MmMtNTFlYTJlNWY5YTdmXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt1981115',
        'title': 'Mad Max: Fury Road',
        'year': '2015',
        'director': 'George Miller',
        'summary': ' An apocalyptic story set in the furthest reaches of our planet, in a stark desert landscape where humanity is broken, and almost everyone is crazed fighting for the necessities of life. Within this world exist two rebels on the run who just might be able to restore order.'
        ' There is Max, a man of action and a man of few words, who seeks peace of mind following the loss of his wife and child in the aftermath of the chaos. And Furiosa, a woman of action and a woman who believes her path to survival may be achieved if she can make it across the desert back to her childhood homeland.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BZDRkODJhOTgtOTc1OC00NTgzLTk4NjItNDgxZDY4YjlmNDY2XkEyXkFqcGc@._V1_SX300.jpg'
      },
    ],
    'Horror': [
      {
        'id': 'tt0081505',
        'title': 'The Shining',
        'year': '1980',
        'director': 'Stanley Kubrick',
        'summary': 'A family heads to an isolated hotel for the winter where a sinister presence influences the father into violence, while his psychic son sees horrific forebodings from both past and future.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNmM5ZThhY2ItOGRjOS00NzZiLWEwYTItNDgyMjFkOTgxMmRiXkEyXkFqcGc@._V1_SX300.jpg'},
      {
        'id': 'tt0078748',
        'title': 'Alien',
        'year': '1979',
        'director': 'Ridley Scott',
        'summary': 'The crew of a commercial spacecraft encounter a deadly lifeform after investigating an unknown transmission.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BN2NhMDk2MmEtZDQzOC00MmY5LThhYzAtMDdjZGFjOGZjMjdjXkEyXkFqcGc@._V1_SX300.jpg'},
      {
        'id': 'tt0102926',
        'title': 'The Silence of the Lambs',
        'year': '1991',
        'director': 'Jonathan Demme',
        'summary': 'A young F.B.I. cadet must receive the help of an incarcerated and manipulative cannibal killer to help catch another serial killer, a madman who skins his victims.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNDdhOGJhYzctYzYwZC00YmI2LWI0MjctYjg4ODdlMDExYjBlXkEyXkFqcGc@._V1_SX300.jpg'},
      {
        'id': 'tt5052448',
        'title': 'Get Out',
        'year': '2017',
        'director': 'Jordan Peele',
        'summary': 'A young African-American visits his white girlfriend\'s parents for the weekend, where his simmering uneasiness about their reception of him eventually reaches a boiling point.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMjUxMDQwNjcyNl5BMl5BanBnXkFtZTgwNzcwMzc0MTI@._V1_SX300.jpg'},
      {
        'id': 'tt7784604',
        'title': 'Hereditary',
        'year': '2018',
        'director': 'Ari Aster',
        'summary': 'A grieving family is haunted by tragic and disturbing occurrences after the death of their secretive grandmother.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNTEyZGQwODctYWJjZi00NjFmLTg3YmEtMzlhNjljOGZhMWMyXkEyXkFqcGc@._V1_SX300.jpg'
      },
    ],
    'Drama': [
      {
        'id': 'tt0068646',
        'title': 'The Godfather',
        'year': '1972',
        'director': 'Francis Ford Coppola',
        'summary': 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNGEwYjgwOGQtYjg5ZS00Njc1LTk2ZGEtM2QwZWQ2NjdhZTE5XkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0110912',
        'title': 'Pulp Fiction',
        'year': '1994',
        'director': 'Quentin Tarantino',
        'summary': 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BYTViYTE3ZGQtNDBlMC00ZTAyLTkyODMtZGRiZDg0MjA2YThkXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0099685',
        'title': 'Goodfellas',
        'year': '1990',
        'director': 'Martin Scorsese',
        'summary': 'The story of Henry Hill and his life in the mob, covering his relationship with his wife Karen Hill and his mob partners Jimmy Conway and Tommy DeVito in the Italian-American crime syndicate.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BN2E5NzI2ZGMtY2VjNi00YTRjLWI1MDUtZGY5OWU1MWJjZjRjXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0114369',
        'title': 'Se7en',
        'year': '1995',
        'director': 'David Fincher',
        'summary': 'Two detectives, a rookie and a veteran, hunt a serial killer who uses the seven deadly sins as his motives.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BY2IzNzMxZjctZjUxZi00YzAxLTk3ZjMtODFjODdhMDU5NDM1XkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0407887',
        'title': 'The Departed',
        'year': '2006',
        'director': 'Martin Scorsese',
        'summary': 'An undercover cop and a mole in the police attempt to identify each other while infiltrating an Irish gang in South Boston.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMTI1MTY2OTIxNV5BMl5BanBnXkFtZTYwNjQ4NjY3._V1_SX300.jpg'
      },
    ],
    'Romance': [
      {
        'id': 'tt0120338',
        'title': 'Titanic',
        'year': '1997',
        'director': 'James Cameron',
        'summary': 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BYzYyN2FiZmUtYWYzMy00MzViLWJkZTMtOGY1ZjgzNWMwN2YxXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt3783958',
        'title': 'La La Land',
        'year': '2016',
        'director': 'Damien Chazelle',
        'summary': 'While navigating their careers in Los Angeles, a pianist and an actress fall in love while attempting to reconcile their aspirations for the future.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMzUzNDM2NzM2MV5BMl5BanBnXkFtZTgwNTM3NTg4OTE@._V1_SX300.jpg'
      },
      {
        'id': 'tt0338013',
        'title': 'Eternal Sunshine of the Spotless Mind',
        'year': '2004',
        'director': 'Michel Gondry',
        'summary': 'When their relationship turns sour, a couple undergoes a medical procedure to have each other erased from their memories.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMTY4NzcwODg3Nl5BMl5BanBnXkFtZTcwNTEwOTMyMw@@._V1_SX300.jpg'
      },
      {
        'id': 'tt2194499',
        'title': 'About Time',
        'year': '2013',
        'director': 'Richard Curtis',
        'summary': 'At the age of 21, Tim Lake (Domhnall Gleeson) discovers he can travel in time... The night after another unsatisfactory New Year party, Tim father tells his son that the men in his family have always had the ability to travel through time. Tim can not change history, but he can change what happens and has happened in his own life-so he decides to make his world a better place...by getting a girlfriend.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMTA1ODUzMDA3NzFeQTJeQWpwZ15BbWU3MDgxMTYxNTk@._V1_SX300.jpg'
      },
      {
        'id': 'tt5288320',
        'title': 'Call Me by Your Name',
        'year': '2017',
        'director': 'Luca Guadagnino',
        'summary': 'In 1980s Italy, romance blossoms between a seventeen-year-old student and the older man hired as his father\'s research assistant.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNDk3NTEwNjc0MV5BMl5BanBnXkFtZTgwNzYxNTMwMzI@._V1_SX300.jpg'
      },
    ],
    'Comedy': [
      {
        'id': 'tt2278388',
        'title': 'The Grand Budapest Hotel',
        'year': '2014',
        'director': 'Wes Anderson',
        'summary': 'A writer encounters the owner of a declining high-class hotel, who tells him of his early years serving as a lobby boy in the hotel\'s glorious years under an exceptional concierge.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMzM5NjUxOTEyMl5BMl5BanBnXkFtZTgwNjEyMDM0MDE@._V1_SX300.jpg'
      },
      {
        'id': 'tt1119646',
        'title': 'The Hangover',
        'year': '2009',
        'director': 'Todd Phillips',
        'summary': 'Three buddies wake up from a bachelor party in Las Vegas, with no memory of the previous night and the bachelor missing. They make their way around the city in order to find their friend before his wedding.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNDI2MzBhNzgtOWYyOS00NDM2LWE0OGYtOGQ0M2FjMTI2NTllXkEyXkFqcGc@._V1_SX300.jpg'
      },
      {
        'id': 'tt0827137',
        'title': 'Superbad',
        'year': '2007',
        'director': 'Greg Mottola',
        'summary': 'Two co-dependent high school seniors are forced to deal with separation anxiety after their plan to stage a booze-soaked party goes awry.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BMTc0NjIyMjA2OF5BMl5BanBnXkFtZTcwMzIxNDE1MQ@@._V1_SX300.jpg'
      },
      {
        'id': 'tt0088763',
        'title': 'Back to the Future',
        'year': '1985',
        'director': 'Robert Zemeckis',
        'summary': 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BZmU0M2Y1OGUtZjIxNi00ZjBkLTg1MjgtOWIyNThiZWIwYjRiXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg'
      },
      {
        'id': 'tt0365748',
        'title': 'Shaun of the Dead',
        'year': '2004',
        'director': 'Edgar Wright',
        'summary': 'The uneventful, aimless lives of a London electronics salesman and his layabout roommate are disrupted by the zombie apocalypse.',
        'poster': 'https://m.media-amazon.com/images/M/MV5BNzNjZGE4YTUtOWU3OC00Mzg2LThjNWItMzUwYzEwMDgxYmVjXkEyXkFqcGc@._V1_SX300.jpg'
      },
    ],
  };
}