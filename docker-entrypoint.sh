#!/bin/bash

set -e

cp --archive /config/s6 /run

exec "$@"
