FROM python:3.12-slim

# Чтоб логи сразу летели в stdout/stderr
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Рабочая директория внутри контейнера
WORKDIR /app

# Зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Код приложения
COPY app.py .

# Порт приложения
EXPOSE 8181

# Команда запуска (наш app.py уже слушает 0.0.0.0:8181)
CMD ["python", "app.py"]
