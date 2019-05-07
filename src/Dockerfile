FROM python:3.7

# setup the default port and environment variable to override on build time
ARG PORT_VAR=8080
ENV port_override=$PORT_VAR

#copy the contents of the current directory 
COPY . /app

#set the working directory
WORKDIR /app

#install packages/dependencies
RUN pip install --trusted-host pypi.python.org -r requirements.txt

#allows linux images built on windows to be run properly
RUN chmod 644 app.py

#expose the port for the web application
EXPOSE $PORT_VAR

#set the worker and thread variables and bind entrypoint to port
# ENTRYPOINT [ "exec gunicorn --bind :8080 --workers 1 --threads 8 app:app" ] 

#run the web application
CMD ["python", "app.py"]