#!/bin/bash

# Main menu
while true; do
    clear
    echo "--------------------------"
    echo "User Name: 장철희(ZHANG ZHEXI)"
    echo "Student Number: 12204400"
    echo "[ MENU ]"
    echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
    echo "2. Get the data of 'action' genre movies from 'u.item'"
    echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
    echo "4. Delete the 'IMDb URL' from 'u.item"
    echo "5. Get the data about users from 'u.user'"
    echo "6. Modify the format of 'release date' in 'u.item'"
    echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
    echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
    echo "9. Exit"
    echo "--------------------------"
    read -p "Enter your choice [1-9] " choice

    case $choice in
        1)
            read -p "Please enter 'movie id' (1~1682): " movie_id
            awk -F '|' -v id="$movie_id" '$1 == id' u.item
            read -p "Press Enter to continue..."
            ;;
        2)
            read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n): " action_choice
            if [ "$action_choice" = "y" ]; then
                echo "2. Get the data of 'action' genre movies from 'u.item'"
                awk -F '|' '$7 == 1' u.item | sort -R | head -n 10 | sort -t '|' -k 1,1n | awk -F '|' '{ printf "%s %s\n", $1, $2 }'
            fi
            read -p "Press Enter to continue..."
            ;;
        3)
            read -p "Please enter 'movie id' (1~1682): " movie_id
            average_rating=$(awk -F '\t' -v id="$movie_id" '$2 == id { sum+=$3; count++ } END { if (count > 0) printf "%.5f\n", sum/count }' u.data)
            echo "average rating of $movie_id: $average_rating"
            read -p "Press Enter to continue..."
            ;;
        4)
            read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n): " choice
            if [ "$choice" = "y" ]; then
                sed -E 's/http:[^\|]*//g' u.item | head -n 10
            fi
            read -p "Press Enter to continue..."
            ;;
        5)
            read -p "Do you want to get the data about users from 'u.user'?(y/n): " choice
            if [ "$choice" = "y" ]; then
                cat u.user | sed -E 's/\|/ /g' | sed -E 's/(\w+) (\w+) (\w+) (\w+).+/user \1 is \2 years old \3 \4/' | head -n 10 | sed -E 's/F/female/g' | sed -E 's/M/male/g'
            fi
            read -p "Press Enter to continue..."
            ;;
        6)
            read -p "Do you want to Modify the format of 'release date' in 'u.item'?(y/n): " choice
            if [ "$choice" = "y" ]; then
                cat u.item | sed -E 's/([0-9]{4})-(\w{3})-([0-9]{2})/\1\2\3/g' | tail -n 10 | sed -E 's/Jan/01/' | sed -E 's/Feb/02/' | sed -E 's/Mar/03/' | sed -E 's/Apr/04/' |
                sed -E 's/May/05/' | sed -E 's/Jun/06/' | sed -E 's/Jul/07/' | sed -E 's/Aug/08/' | sed -E 's/Sep/09/' | sed -E 's/Oct/10/' |
                sed -E 's/Nov/11/' | sed -E 's/Dec/12/' | tr -d '-'
            fi
            read -p "Press Enter to continue..."
            ;;
        7)
            read -p "Please enter 'user id' (1~943): " user_id
            awk -v UID=${user_id} '$1==UID {print $2}' u.data | sort -n | tr '\n' '|' | sed -E 's/\|$/\n/'
            file="rated_id.txt"
            awk -v UID=${user_id} '$1==UID {print $2}' u.data | sort -n > ${file}
            awk -F '\t' 'NR==FNR {a[$1]=$2} NR>FNR {printf("%d|%s\n", $0, a[$0])}' u.item ${file} | head -n 10
            if [ -f ${file} ]; then
                rm ${file}
            fi
            read -p "Press Enter to continue..."
            ;;
        8)
            echo ""
            read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" choice
            if [ ${choice} = "y" ]; then
                file="programmer_id.txt"
                awk -F'|' '$2>=20 && $2<=29 &&$4~"programmer" {print $1}' u.user > ${file}
                awk 'BEGIN{
                    for (i = 1; i < 1682; ++i)
                    {
                        sum[i] = 0;
                        cnt[i] = 0;
                    }
                }
                NR==FNR {status[$1]=1} NR>FNR && status[$1]==1 {sum[$2] += $3; cnt[$2]++;}
                END {
                    for (i = 1; i < 1682; ++i)
                        if (sum[i] != 0) printf("%d %g\n", i, sum[i] / cnt[i]);
                }' ${file} u.data
                echo ""
                if [ -f ${file} ]; then
                    rm ${file}
                fi
            fi
            read -p "Press Enter to continue..."
            ;;
        9)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option (1-9)."
            read -p "Press Enter to continue..."
            ;;
    esac
done
