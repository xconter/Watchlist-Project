#!/bin/bash

echo "Welcome to Watchlist!"

if [[ -f ".env" ]]; then
    echo "Config file exists"
else
    echo "Config file does not exist"
    echo "It looks like you are new to Watchlist!"
    echo "In order to run the program, you need an API key from https://www.themoviedb.org/"
    echo "Simply create an account, go to your account settings, click API, then click create."
    echo 'From there, put the Application Name as "Watchlist", the Application URL as the GitHub repo URL, leave Type of Use as "Desktop Application", and type "Watchlist Program" in the application summary. Then put in your contact info, and you will have an API key!'
    while true; do
	    read -rsp "Enter your API key: " TMDB_API_KEY
	    echo ""
            if  [[ -z "$TMDB_API_KEY" ]]; then
                    echo "Key cannot be empty."
            else
		    response=$(curl -s "https://api.themoviedb.org/3/search/movie?api_key=$TMDB_API_KEY&query=Interstellar" | grep 'Invalid API key')
                    if [[ -z "$response" ]]; then
			    break
		    fi
		    echo "Invalid API key."
            fi
    done
    echo "Key Received!"




fi

