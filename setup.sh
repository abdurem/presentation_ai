#!/bin/sh
# setup.sh - Setup script for ALLWEONE® AI Presentation Generator
# This script installs dependencies, starts the database, and sets up the schema.

set -e

# 1. Install pnpm if not present
if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm not found. Installing..."
  npm install -g pnpm
else
  echo "pnpm is already installed."
fi

# 2. Install project dependencies
pnpm install

# 3. Check for .env file, copy from example if missing
if [ ! -f .env ]; then
  echo ".env file not found. Copying from .env.example (if exists)..."
  if [ -f .env.example ]; then
    cp .env.example .env
    echo ".env created from .env.example. Please update it with your secrets."
  else
    echo "No .env.example found. Please create a .env file manually."
  fi
else
  echo ".env file already exists."
fi

# 4. Start PostgreSQL with docker-compose
if command -v docker-compose >/dev/null 2>&1; then
  echo "Starting PostgreSQL with docker-compose..."
  docker-compose up -d postgres
else
  echo "docker-compose not found. Please install Docker and docker-compose."
  exit 1
fi

# 5. Wait for PostgreSQL to be ready
printf "Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker exec postgres15 pg_isready -U postgres >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  printf "."
  sleep 1
  RETRIES=$((RETRIES-1))
done
if [ $RETRIES -eq 0 ]; then
  echo "\nPostgreSQL did not become ready in time."
  exit 1
fi
printf " done!\n"

# 6. Run Prisma migrations and generate client
echo "Running Prisma migrations..."
pnpm exec prisma migrate dev --name init || true
pnpm exec prisma generate

echo "Setup complete!"
echo "You can now run: pnpm dev"
