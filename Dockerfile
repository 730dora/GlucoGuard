# lightweight Python base image
FROM python:3.9-slim

# set the working directory inside the container
WORKDIR /app

# copy the dependency file
COPY requirements.txt .

# install dependencies
# --no-cache-dir is to keep the image small
RUN pip install --no-cache-dir -r requirements.txt

# copy the rest of the app code (backend.py, model, csv)
COPY . .

# expose the port Flask runs on
EXPOSE 5000

# command to run the app
CMD ["python", "backend.py"]