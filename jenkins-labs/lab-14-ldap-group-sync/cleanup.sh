#!/bin/bash
set -e

echo "Cleaning up Lab 14: LDAP Group Sync..."

cd "$(dirname "$0")"

docker compose down -v 2>/dev/null || true
docker rm -f jenkins-ldap-lab openldap-lab phpldapadmin-lab 2>/dev/null || true

echo "Lab 14 cleaned up successfully."
