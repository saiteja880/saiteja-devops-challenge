FROM python:3.12-slim

RUN useradd --system --uid 10001 --create-home appuser

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

USER 10001

EXPOSE 8080

CMD ["python", "main.py"]
