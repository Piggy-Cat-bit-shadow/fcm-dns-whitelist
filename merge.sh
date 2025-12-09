#!/bin/bash
set -e

mkdir -p rules

tmp_upstream=$(mktemp)
tmp_combined=$(mktemp)

# 拉取 upstream 列表
while read -r url; do
  # 跳过空行和注释
  if [[ -z "$url" || "$url" == \#* ]]; then
    continue
  fi
  echo "Fetching $url"
  curl -fsSL "$url" >> "$tmp_upstream"
done < upstream.txt

# 先把你固定维护的白名单加进去
if [ -f base-whitelist.txt ]; then
  cat base-whitelist.txt >> "$tmp_combined"
fi

# 再从上游里筛选出和 Google / FCM / 微信相关的规则
cat "$tmp_upstream" \
  | grep -Ei 'google|mtalk|firebase|fcm|gcm|android\.googleapis\.com|gstatic|googleusercontent|weixin\.qq\.com|servicewechat\.com|mp\.weixin\.qq\.com' \
  | sed 's/\r//' \
  >> "$tmp_combined"

# 去重后生成最终规则文件
sort -u "$tmp_combined" > rules/fcm-whitelist.txt

rm -f "$tmp_upstream" "$tmp_combined"
