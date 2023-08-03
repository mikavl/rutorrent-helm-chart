#!/bin/bash

set -e

cp --archive /etc/s6 /run

exec "$@"
