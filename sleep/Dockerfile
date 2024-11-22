# Use the official Python image as the base
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN pip install --upgrade pip
RUN pip install dbt-core dbt-postgres

# Copy the dbt project into the container
COPY . .

# Expose ports if needed for dbt docs
EXPOSE 8888

# Default command (override in docker-compose.yml if needed)
CMD ["dbt", "--version"]
