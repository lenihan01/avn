# (C) Copyright 2025-2026 Hewlett Packard Enterprise Development LP
check_response_code () {
  case "$1" in
    200) echo "200: OK"; exit 0 ;;
    302) echo "302!" ;;
    400) echo "400: Bad Request" ;;
    401) echo "401: Unauthorized" ; exit 1 ;;
    403) echo "403: Forbidden" ;;
    404) echo "404: Not Found" ;;
    500) echo "500: Internal Server Error" ;;
    503) echo "503: Server Unavailable" ;;
    *) echo "Some other code: $response" ;;
  esac
}
