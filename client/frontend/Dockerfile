FROM python:3.6.15

WORKDIR /usr/src/app

COPY frontend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY frontend .
COPY config.py .
COPY csgo.py .
COPY messagequeue.py .

CMD [ "python", "./webserver.py" ]
