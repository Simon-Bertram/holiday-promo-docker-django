#!/bin/bash
set -e

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

# Create superuser if needed (optional)
# python manage.py createsuperuser --noinput

# Collect static files (uncomment in production)
# python manage.py collectstatic --noinput

# Execute the command passed to docker
exec "$@" 