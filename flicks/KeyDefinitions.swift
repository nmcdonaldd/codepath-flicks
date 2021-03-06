//
//  KeyDefinitions.swift
//  flicks
//
//  Created by Nick McDonald on 1/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//


// MARK: - MoviesDB constants

let moviesDBAPIKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
let moviesDBBaseImagePath = "https://image.tmdb.org/t/p/w500"
let moviesDBNowPlayingEndpoint = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(moviesDBAPIKey)"
let moviesDBTopRatedEndpoint = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(moviesDBAPIKey)"
let moviesTitlePropertyIdentifier = "title"
let moviesBackdropPathPropertyIdentifier = "backdrop_path"
let moviesPosterPathPropertyIdentifier = "poster_path"
let moviesReleaseDatePropertyIdentifier = "release_date"
let moviesVoteAveragePropertyIdentifier = "vote_average"
let moviesResultsPropertyIdentifier = "results"
let moviesOverviewPropertyIdentifier = "overview"
let moviesNavigationControllerIdentififer = "moviesNavigationController"
let moviesNowPlayingEndpoint = "now_playing"
let moviesTopRatedEndpoint = "top_rated"
let moviesVoteCountPropertyIdentifier = "vote_count"
let moviesPopularityPropertyIdentifier = "popularity"



// MARK: - Reusable IDs

let moviesCellReusableIdentifier = "MovieCell"


// MARK: - Presented strings
let moviesNowPlayingForSearchBar = "Search for now playing movies"
