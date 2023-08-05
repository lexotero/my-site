# Get exported requirements from poetry
FROM python:3.11-bookworm AS poetry

ARG POETRY_VERSION=1.5.1

RUN pip install poetry==${POETRY_VERSION}

WORKDIR /app
COPY pyproject.toml poetry.lock ./

RUN poetry export -f requirements.txt --output requirements.txt

# Main image
FROM python:3.11-bookworm

# If set to 1, the image build will be for development purposes
ARG BUILD_DEVELOPMENT

# Use Django dev settings when building for dev, and prod settings otherwise
ENV DJANGO_SETTINGS_MODULE=${BUILD_DEVELOPMENT:+"my_site.settings.dev"}
ENV DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-"my_site.settings.prod"}

RUN apt-get update && apt-get upgrade -y

ADD . /app
WORKDIR /app

COPY --from=poetry /app/requirements.txt ./
RUN pip install -r requirements.txt
RUN pip install uvicorn

EXPOSE 8000

CMD ["uvicorn", "--workers", "1", "--host", "0.0.0.0", "--port", "8000", "my_site.asgi:application"]