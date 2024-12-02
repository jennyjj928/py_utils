#!/bin/bash

# 定义最大请求次数
max_requests=3
# 初始化请求计数器
count=0
# 数组存储每次请求的总耗时
declare -a request_times

# 无限循环调用 curl
while [ $count -lt $max_requests ]; do
  curlstr=`curl -w 'Total: %{time_total} sec\n' -o /dev/null -s --location 'https://ent.tiktok-row.net/api/platform/v2/module/selection' \
  --header 'x-jwt-token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwYWFzLnBhc3Nwb3J0LmF1dGgiLCJleHAiOjE3MzIyMDI0MDEsImlhdCI6MTczMjE5ODc0MSwidXNlcm5hbWUiOiJodWFuZ2Nhbi45MjgiLCJ0eXBlIjoicGVyc29uX2FjY291bnQiLCJyZWdpb24iOiJpMThuIiwidHJ1c3RlZCI6dHJ1ZSwidXVpZCI6IjdhNzA1MDgxLWY0Y2MtNDU4Yy04YjNjLWEwNmVjZWE4N2E4OCIsInNpdGUiOiJpMThuIiwiYnl0ZWNsb3VkX3RlbmFudF9pZF9vcmciOiJieXRlZGFuY2UiLCJzY29wZSI6ImJ5dGVkYW5jZSIsInNlcXVlbmNlIjoiUkQiLCJvcmdhbml6YXRpb24iOiJUaWtUb2sg56CU5Y-RLemakOengeWuieWFqC1EYXRhIExpZmVjeWNsZSBNYW5hZ2VtZW50LU9ubGluZSBJbmZyYSIsIndvcmtfY291bnRyeSI6IkNITiIsImF2YXRhcl91cmwiOiJodHRwczovL3MxNi1pbWZpbGUtc2cuZmVpc2h1Y2RuLmNvbS9zdGF0aWMtcmVzb3VyY2UvdjEvdjNfMDBna183NGY2ODI5OS1jY2UyLTQ0NzktYTZlYS0yMTEwOGVkYTdhaHV-P2ltYWdlX3NpemU9bm9vcFx1MDAyNmN1dF90eXBlPVx1MDAyNnF1YWxpdHk9XHUwMDI2Zm9ybWF0PXBuZ1x1MDAyNnN0aWNrZXJfZm9ybWF0PS53ZWJwIiwiZW1haWwiOiJodWFuZ2Nhbi45MjhAYnl0ZWRhbmNlLmNvbSIsImVtcGxveWVlX2lkIjo1MDEyODA5LCJvZ19saW1pdCI6ImxpbWl0In0.IbCaY1GLec35Yhxd0aBGxR7Inyb_qi--0STMswQlcuh2A3qk5QKDRUTFltxCPmvNxkGYxUqWp9tNFmXvsQOMgQJbHPk6pddMkgbzf61vt_caLAZd8vnRUWMCO7f_ServUv1LGnHq25yzE60EpMX-hXt24ACpcBFj2s0nfjaMwyw' \
  --header 'x-tt-env: ppe_ems' \
  --header 'x-use-ppe: 1' \
  --header 'Content-Type: application/json' \
  --data '{"use_saved_draft":true,"module_types":["iac","data_retention","data_encryption","des","change_region","purpose_limitation"],"resource_name":"tiktok/mysql__elva_iac_db4__test_selection","draft_update_time":1732199678,"resource_type":1}'`

  cmd='echo $curlstr'

    total_time=$(eval $cmd)
    
    # 将总耗时记录到数组中
    request_times+=("$total_time")
  
    # 打印请求次数和总耗时
    echo "Request $((count + 1)): Total time: $total_time sec"

    # 增加计数器
    count=$((count + 1))

    # 等待 2 秒
    sleep 1
done
 


# 输出所有请求的总耗时
echo "All request times: ${request_times[@]}"

# 将请求时间排序并计算 p90
sorted_times=($(for t in "${request_times[@]}"; do echo $t; done | sort -n))
index=$(echo "(${#sorted_times[@]} * 0.9 + 0.5) / 1" | bc)
p90=${sorted_times[$index-1]}

echo "===================================="
echo "Statistics:"
echo "Total requests: $max_requests"
echo "sorted_times: ${sorted_times[@]}"
echo "90th percentile time (p90): $p90 sec"