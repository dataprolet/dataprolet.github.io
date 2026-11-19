#!/bin/bash

### https://github.com/orgs/awesome-jellyfin/discussions/778

set -eou pipefail

git clone https://github.com/awesome-jellyfin/awesome-jellyfin.git
cd awesome-jellyfin

# GitHub token so you won't get rate limited
TOKEN=""

domains=($(cat README.md | grep github.com | sed 's/.*(//g' | sed 's/).*//g' | grep github | sed 's|https://github.com/||g'))

table="table.md"
table_final="table-final.md"

for repo in ${domains[@]}; do

  if [[ -f $table ]] && grep -q $table -e $repo; then
    continue
  else

    if ! stars=$(curl -s -L \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $TOKEN" \
      -H "X-GitHub-Api-Version: 2026-03-10" \
      https://api.github.com/repos/$repo/stargazers/count \
      jq -r '.count'); then
      continue
    fi

    if ! commit_date=$(curl -s -L \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $TOKEN" \
      -H "X-GitHub-Api-Version: 2026-03-10" \
     "https://api.github.com/repos/$repo/commits?per_page=1" \
      | jq -r '.[0].commit.committer.date'); then
      continue
    fi
  fi

  echo "| https://github.com/${repo} | $stars | $commit_date |" >> $table
done

echo "| Repo | Stars | Last commit |" > $table_final
echo "|----------|----------|----------|" >> $table_final
cat $table >> $table_final
