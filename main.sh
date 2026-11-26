#!/bin/bash

search() {
    local query
    local result
    local filtered_results
    local title
    local count

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
    filtered_results=$(echo "$result" | jq '[.results[] | select(.media_type == "movie" or .media_type == "tv")]')
    echo "$filtered_results" | jq -r '.[] | "\(.title // .name) (\((.release_date // .first_air_date // "")[:4])) - \(.media_type) - \(if .vote_count == 0 then "Unrated" else "\(.vote_average * 10 | round / 10)/10 - \(.vote_count) votes" end)"' | nl -ba
    count=$(echo "$filtered_results" | jq 'length')
    echo ""
    read -rp "Select a title # (enter 0 to exit): " title
    echo ""
    if [[ "$title" == 0 ]]; then
	    echo "Returning to main menu..."
	    return
    elif [[ ! "$title" =~ ^[1-9][0-9]*$ ]]; then
	    echo "Invalid Selection"
	    return
    elif [[ "$title" -gt "$count" ]]; then
	    echo "Invalid Selection"
	    return
    else
	    selected=$(echo "$filtered_results" | jq --argjson i "$((title - 1))" '.[$i]')
	    add_to_watchlist "$selected"
    fi
}

add_to_watchlist() {
	local selected="$1"
	local entry=$(echo "$selected" | jq '{
	id: .id,
    	title: (.title // .name),
	media_type: .media_type,
	year: (.release_date // .first_air_date // "")[:4],
	rating: .vote_average,
	votes: .vote_count,
	watched: false
	}')
	if jq --argjson new "$entry" '. + [$new]' data/watchlist.json > data/watchlist.tmp; then
		if mv data/watchlist.tmp data/watchlist.json; then
			echo "Successfully added to watchlist!"
		else
			echo "Failed to save watchlist. (mv failure)"
		fi
	else
		echo "Failed to process watchlist. (jq failure)"
	fi
}

view_watchlist() {
	local count
	count=$(jq 'length' data/watchlist.json)
	if [[ "$count" -eq 0 ]]; then
		echo "Your watchlist is empty!"
	else
		jq -r '.[] | "\(.title) (\(.year)) - \(.media_type) - \(if .votes == 0 then "Unrated" else "\(.rating * 10 | round / 10)/10 - \(.votes) votes" end) - \(if .watched then "Watched" else "Unwatched" end)"' data/watchlist.json | nl -ba
		echo ""
		echo "Total: $count"
		echo ""
		read -rp "Press Enter to return to the main menu."
	fi
}

echo "Welcome to Watchlist!"


if [[ ! -s "data/watchlist.json" ]]; then
	echo "[]" > data/watchlist.json
fi


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
		view_watchlist
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








