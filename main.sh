#!/bin/bash

search() {
    local query
    local result
    
    read -rp "Enter title (enter nothing to exit): " query
    echo ""
    if [[ -z "$query" ]]; then
	    echo "Returning to main menu..."
	    return
    else
	    result=$(curl -s -G "https://api.themoviedb.org/3/search/multi" \
  		    --data-urlencode "api_key=$TMDB_API_KEY" \
		    --data-urlencode "query=$query")
    fi
    echo "$result" | jq -r '.results[] | select(.media_type == "movie" or .media_type == "tv")  | "\(.title // .name) (\((.release_date // .first_air_date // "")[:4])) - \(.media_type) - \(if .vote_count == 0 then "Unrated" else "\(.vote_average * 10 | round / 10)/10 - \(.vote_count) votes" end)"' | nl -ba
}




echo "Welcome to Watchlist!"

if [[ -f ".env" ]]; then
    echo "Config file exists"
    source ./.env
    if  [[ -z "$TMDB_API_KEY" ]]; then
	    echo "Key cannot be empty."
	    while true; do
		    read -rsp "Enter replacement API key: " TMDB_API_KEY
            	    echo ""
            	    if  [[ -z "$TMDB_API_KEY" ]]; then
                    	    echo "Key cannot be empty."
            	    else
                    	    response=$(curl -s -o /dev/null -w "%{http_code}" "https://api.themoviedb.org/3/search/movie?api_key=$TMDB_API_KEY&query=Interstellar")
                    	    if [[ "$response" == 200 ]]; then
                            	    break
                            elif [[ "$response" == 401 ]]; then
                                    echo "Invalid API key."
                            else
                                    echo "Unable to validate API key."
                            fi
                    fi
            done
            echo "Key Received!"
            umask 077
            echo "TMDB_API_KEY=$TMDB_API_KEY" > .env
            chmod 600 .env
    else
	    echo "Key Loaded!"
    fi

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
		    response=$(curl -s -o /dev/null -w "%{http_code}" "https://api.themoviedb.org/3/search/movie?api_key=$TMDB_API_KEY&query=Interstellar")
                    if [[ "$response" == 200 ]]; then
			    break
		    elif [[ "$response" == 401 ]]; then
			    echo "Invalid API key."
		    else
			    echo "Unable to validate API key."
		    fi
            fi
    done
    echo "Key Received!"
    umask 077
    echo "TMDB_API_KEY=$TMDB_API_KEY" > .env
    chmod 600 .env
fi

while true; do
	echo ""
	echo "----------------------------------------------------------------"
	echo ""
cat << EOF
================================
	   WATCHLIST
================================
1. Search
2. View watchlist
3. Exit

EOF
	read -rp "Enter a command (#): " choice
	echo ""
	case "$choice" in
	1)
		search
		;;
	2)
		echo "Option 2"
		;;
	3)
		echo "Goodbye!"
		break
		;;
	*)
		echo "Invalid Option"
		;;
	esac
done








