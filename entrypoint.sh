#!/bin/bash
set -e

# Function to check if postgres is ready
postgres_ready() {
    python << END
import sys
import psycopg2
import os
import dj_database_url

try:
    db_url = os.environ.get('DATABASE_URL')
    if db_url:
        conn_params = dj_database_url.parse(db_url)
        conn = psycopg2.connect(
            dbname=conn_params['NAME'],
            user=conn_params['USER'],
            password=conn_params['PASSWORD'],
            host=conn_params['HOST'],
            port=conn_params['PORT']
        )
except psycopg2.OperationalError:
    sys.exit(1)
sys.exit(0)
END
}

# Wait for postgres
until postgres_ready; do
  echo "Waiting for PostgreSQL to become available..."
  sleep 2
done
echo "PostgreSQL is available"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if specified in environment variables
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
  echo "Creating superuser..."
  python manage.py createsuperuser --noinput
fi

# Execute the command passed to docker
exec "$@" 