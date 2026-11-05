#!/bin/bash
set -euo pipefail

security find-generic-password -s "ai-deepseek" -a "DEEPSEEK_API_KEY" -w 2>/dev/null
