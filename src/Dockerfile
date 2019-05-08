FROM python:3.7

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . .

#install packages/dependencies
RUN pip install --trusted-host pypi.python.org -r requirements.txt

#allows linux images built on windows to be run properly
RUN chmod 644 app.py

#expose the port for the web application
EXPOSE $PORT

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# https://community.plot.ly/t/error-with-gunicorn/8247
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app.server