# 1. Use a lightweight Python base image
FROM python:3.9-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy the dependency file
COPY requirements.txt .

# 4. Install dependencies
# We add --no-cache-dir to keep the image small
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the app code (backend.py, model, csv)
COPY . .

# 6. Expose the port Flask runs on
EXPOSE 5000

# 7. Command to run the app
CMD ["python", "backend.py"]