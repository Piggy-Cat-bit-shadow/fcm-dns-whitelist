#!/bin/bash
set -e

mkdir -p rules
tmpfile=$(mktemp)

while read -r url; do
  # 跳过空行和注释
  if [[ -z "$url" || "$url" == \#* ]]; then
    continue
  fi
  echo "Fetching $url"
  curl -fsSL "$url" >> "$tmpfile"
done < upstream.txt

# 只保留和 Google / FCM 相关的规则，去重后输出
cat "$tmpfile" \
| grep -Ei 'google|mtalk|firebase|fcm|gcm|android\.googleapis\.com|gstatic|googleusercontent' \
| sed 's/\r//' \
| sort -u \
> rules/fcm-whitelist.txt

rm -f "$tmpfile"
