# Use the official Python image as the base
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y git
RUN pip install --upgrade pip
RUN pip install dbt-core dbt-postgres


# Expose ports if needed for dbt docs
EXPOSE 8888

COPY entrypoint.sh /app/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
