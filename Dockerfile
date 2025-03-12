# Use a specific Python version for better reproducibility
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Create a non-root user to run the application
RUN groupadd -r django && useradd -r -g django django

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy and install requirements first for better caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project into the container
COPY . .

# Change ownership of the application files to the non-root user
RUN chown -R django:django /app

# Switch to the non-root user
USER django

# Expose the port the app will run on
EXPOSE 8000

# Use an entrypoint script for more flexibility
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Ensure correct line endings for entrypoint.sh if built on Windows
RUN sed -i 's/\r$//' /entrypoint.sh