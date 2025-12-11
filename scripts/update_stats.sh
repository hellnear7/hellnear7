#!/bin/bash

USER="hellnear7"
README="README.md"

# 日付計算（Linux用）
TODAY=$(date -u +%Y-%m-%d)
WEEK_AGO=$(date -u -d '7 days ago' +%Y-%m-%d)
MONTH_AGO=$(date -u -d '1 month ago' +%Y-%m-%d)

echo "DEBUG: TODAY=$TODAY, WEEK_AGO=$WEEK_AGO, MONTH_AGO=$MONTH_AGO"

# GitHub API で統計取得（デバッグ出力追加）
get_count() {
  local query="$1"
  echo "DEBUG: Query=$query" >&2
  local result=$(gh api search/issues -X GET -f q="$query" --jq '.total_count' 2>&1)
  echo "DEBUG: Result=$result" >&2
  echo "${result:-0}"
}

# 今日
TODAY_PR=$(get_count "author:$USER is:pr created:$TODAY")
TODAY_REVIEW=$(get_count "reviewed-by:$USER is:pr -author:$USER")
TODAY_COMMENT=$(get_count "commenter:$USER is:pr -author:$USER")

# 今週
WEEK_PR=$(get_count "author:$USER is:pr created:>=$WEEK_AGO")
WEEK_REVIEW=$(get_count "reviewed-by:$USER is:pr -author:$USER created:>=$WEEK_AGO")
WEEK_COMMENT=$(get_count "commenter:$USER is:pr -author:$USER created:>=$WEEK_AGO")

# 今月
MONTH_PR=$(get_count "author:$USER is:pr created:>=$MONTH_AGO")
MONTH_REVIEW=$(get_count "reviewed-by:$USER is:pr -author:$USER created:>=$MONTH_AGO")
MONTH_COMMENT=$(get_count "commenter:$USER is:pr -author:$USER created:>=$MONTH_AGO")

# README を更新
update_value() {
  local tag="$1"
  local value="$2"
  sed -i "s|<!--${tag}-->[^<]*<!--/${tag}-->|<!--${tag}-->${value}<!--/${tag}-->|g" "$README"
}

update_value "today_pr_created" "$TODAY_PR"
update_value "today_pr_reviewed" "$TODAY_REVIEW"
update_value "today_commented" "$TODAY_COMMENT"

update_value "week_pr_created" "$WEEK_PR"
update_value "week_pr_reviewed" "$WEEK_REVIEW"
update_value "week_commented" "$WEEK_COMMENT"

update_value "month_pr_created" "$MONTH_PR"
update_value "month_pr_reviewed" "$MONTH_REVIEW"
update_value "month_commented" "$MONTH_COMMENT"

echo "Stats updated!"
echo "Today: PR=$TODAY_PR, Review=$TODAY_REVIEW, Comment=$TODAY_COMMENT"
echo "Week:  PR=$WEEK_PR, Review=$WEEK_REVIEW, Comment=$WEEK_COMMENT"
echo "Month: PR=$MONTH_PR, Review=$MONTH_REVIEW, Comment=$MONTH_COMMENT"
