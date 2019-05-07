FROM python:3.7

# setup the default port and environment variable to override on build time
ARG port_var=8080
ENV port_override=$port_var

#copy the contents of the current directory 
COPY . /app

#set the working directory
WORKDIR /app

#install packages/dependencies
RUN pip install --trusted-host pypi.python.org -r requirements.txt

#allows linux images built on windows to be run properly
RUN chmod 644 app.py

#expose the port for the web application
EXPOSE $port_var

#set the worker and thread variables and bind entrypoint to port
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app

#run the web application
CMD ["python", "app.py"]