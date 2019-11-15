#!/bin/bash
sed 's/#/\\#/g' \
| sed 's/&/\\& /g' \
| sed 's/%/\\% /g' \
| sed 's/\$/\\$ /g' \
| sed 's/«/"</g' \
| sed 's/»/">/g' \
| sed 's/LaTeX/\\LaTeX/g' \
| sed 's/\.\.\./\\ldots/g' \
| sed 's/€/\\euro/g'
