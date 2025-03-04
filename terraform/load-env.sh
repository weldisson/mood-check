#!/bin/bash

# Load environment variables from .env file
set -a
source .env
set +a

# Run terraform command
terraform "$@"