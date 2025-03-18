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

# Make sure Django is installed
RUN pip install --no-cache-dir Django==5.1.7

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Ensure correct line endings for entrypoint.sh if built on Windows
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# Copy the Django project into the container
COPY . .

# Create staticfiles directory and set permissions
RUN mkdir -p /app/staticfiles && chown -R django:django /app/staticfiles

# Change ownership of the application files to the non-root user
RUN chown -R django:django /app /entrypoint.sh

# Switch to the non-root user
USER django

# Expose the port the app will run on
EXPOSE 8000

# Start the Django development server
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]