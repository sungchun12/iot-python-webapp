FROM python:3.7

COPY . /app

WORKDIR /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

RUN chmod 644 app.py

EXPOSE 8080

CMD ["python", "app.py"]