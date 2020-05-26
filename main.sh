#!/bin/bash
IFS=$'\n'

labtoken='FILL'
hubtoken='FILL'
hubusername='FILL'

content=$(curl -s -L "https://gitlab.com/api/v4/projects/?simple=yes&private=true&per_page=100&page=1&owned=yes" -H "PRIVATE-TOKEN: $labtoken")

items=$(jq -n -c -r --arg x "$content" '$x | fromjson | .[] | {name: .name, path_with_namespace: .path_with_namespace'})

for item in $items; do
	
	name=$(jq -n -r --arg y "$item" '$y | fromjson | .name')
	oldrepo=$(jq -n -r --arg b "$item" '$b | fromjson | .path_with_namespace')
	
	# getting old repo
	
	git clone --mirror "https://oauth2:$labtoken@gitlab.com/$oldrepo" ".temp"
	cd ".temp"
	
	# creating new repo
	
	payload=$(jq -n --arg n "$name" '{name: $n, private: "true", visibility: "private"}')
	created=$(curl -s -L "https://api.github.com/user/repos" -H "Authorization: token $hubtoken" -H "Content-Type:application/json" -d "$payload")
	newrepo=$(jq -n -r --arg o "$created" '$o | fromjson | .full_name')
	echo $newrepo
	
	# pushing old repo to new repo
	
	git push --no-verify --mirror "https://$hubusername:$hubtoken@github.com/$newrepo"
	cd "../"
	rm -rf ".temp"
done

unset IFS