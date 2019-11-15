#!/usr/bin/env bash
# Original: http://willhaley.com/blog/generate-jwt-with-bash/

set -euo pipefail
IFS=$'\n\t'

SECRET='mecano y mercadona'
HEADER='{
    "typ": "JWT",
    "alg": "HS256",
    "kid": "0001",
    "iss": "Bash JWT Generator",
    "exp": '$(($(date +%s)+1))',
    "iat": '$(date +%s)'
}'
PAYLOAD='{
    "Id": 1,
    "Name": "Felix Anadon Trigo"
}'

#-------------------------------------------------------------------------------
function base64_encode() {
#-------------------------------------------------------------------------------
    declare INPUT=${1:-$(</dev/stdin)};
    echo -n "$INPUT" | openssl enc -base64 | tr '+\/' '-_' | tr -d '=' | tr -d '\r\n'
}
#-------------------------------------------------------------------------------
function json() {
# For some reason, probably bash-related, JSON that terminates with an integer
# must be compacted. So it must be something like `{"userId":1}` or else the
# signing gets screwed up. Weird, but using `jq -c` works to fix that.
#-------------------------------------------------------------------------------
    declare INPUT=${1:-$(</dev/stdin)};
    echo -n "$INPUT" | jq -c .
}
#------------------------------------------------------------------------------- 
function hmacsha256_sign() {
#-------------------------------------------------------------------------------
    declare INPUT=${1:-$(</dev/stdin)};
    echo -n "$INPUT" | openssl dgst -binary -sha256 -hmac "${SECRET}"
}
#-------------------------------------------------------------------------------

HEADER_BASE64=$(echo "${HEADER}" | json | base64_encode)
PAYLOAD_BASE64=$(echo "${PAYLOAD}" | json | base64_encode)

HEADER_PAYLOAD=$(echo "${HEADER_BASE64}.${PAYLOAD_BASE64}")
SIGNATURE=$(echo "${HEADER_PAYLOAD}" | hmacsha256_sign | base64_encode)

echo "${HEADER_PAYLOAD}.${SIGNATURE}"
