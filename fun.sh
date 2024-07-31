#!/bin/bash

# ----------------------------
# Author: Digglega
# Description: Script to add, commit, and push changes to the 'develop' branch with a timestamp.
# ----------------------------


# Функция для вывода анимации
display_cheshire_cat_smile() {
    sleep 0.5
    echo -e "              "
    echo -e "              "
    echo -e "              "
    sleep 0.5
    clear
    echo -e "       .'''.  "
    echo -e "      '     ' "
    echo -e "       '...'  "
    sleep 0.5
    clear
    echo -e "       .'''.  "
    echo -e "     .'     '."
    echo -e "    '         '"
    echo -e "     ' .   . ' "
    echo -e "      '.....'  "
    sleep 0.5
    clear
    echo -e "       .'''.   "
    echo -e "    .'       '."
    echo -e "   '  .     .  '"
    echo -e "    ' . \\ / . ' "
    echo -e "     ' .   . '  "
    echo -e "      '.....'   "
    sleep 0.5
    clear
    echo -e "       .'''.    "
    echo -e "    .'       '. "
    echo -e "   '  .     .  '"
    echo -e "  ' .   \\ /   . '"
    echo -e "   ' .       . ' "
    echo -e "    '.........'  "
}


# Добавляем все изменения
git add .

# Проверяем наличие изменений
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
    exit 0
fi

# Получаем текущую ветку
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch is $current_branch"

# Если текущая ветка master, запрашиваем подтверждение
if [ "$current_branch" = "master" ]; then
    echo "You are about to push to the master branch. Are you sure? (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
        # Предлагаем список веток
        echo "Available branches:"
        git branch -a | grep -v "master"
        echo "Please enter the branch you wish to push to:"
        read branch
        if [ -z "$branch" ]; then
            echo "No branch selected, aborting."
            exit 1
        else
            current_branch=$branch
        fi
    fi
fi

# Коммитим изменения с текущей датой и временем
commit_message=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "$commit_message"

# Пушим изменения
if git push origin $current_branch; then
    # Rainbow color sequence
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    PURPLE="\033[0;35m"
    CYAN="\033[0;36m"
    NC="\033[0m" # No Color

 # Выводим анимацию
    display_cheshire_cat_smile
    # Printing each letter in a different color
    echo -e "${RED}C${GREEN}h${YELLOW}a${BLUE}n${PURPLE}g${CYAN}e${NC}s ${RED}p${GREEN}u${YELLOW}s${BLUE}h${PURPLE}e${CYAN}d ${RED}s${GREEN}u${YELLOW}c${BLUE}c${PURPLE}e${CYAN}s${RED}s${GREEN}f${YELLOW}u${BLUE}l${PURPLE}l${CYAN}y${NC}."

else
    echo "Failed to push changes."
    exit 1
fi

# ----------------------------
# Script executed by Digglega
# ----------------------------
