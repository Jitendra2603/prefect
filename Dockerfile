FROM python:3.6-slim
LABEL maintainer="help@prefect.io"

WORKDIR /app


RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Copy all project files
COPY . .
# Upgrade pip and install dependencies
RUN pip install --upgrade pip && \
    pip install setuptools==57.5.0 versioneer==0.18

# Install compatible versions of packages
RUN pip install typed-ast==1.3.5 mypy==0.670 
RUN pip install mypy==0.670 --no-deps 
RUN pip install click==7.0 importlib-metadata==4.8.3 zipp==3.6.0 typing-extensions==3.7.4.3 platformdirs==2.4.0

# Install black separately with a compatible version
RUN pip install black==19.10b0 --no-deps

# Install additional dependencies
RUN pip install marshmallow-oneofschema==2.0.0b2 PyYAML==5.3.1 tornado==5.1.1

# Install testfixtures and other missing dependencies
RUN pip install testfixtures boto3 azure-storage-blob google-cloud-storage airtable dropbox psycopg2-binary redis feedparser snowflake-connector-python spacy tweepy jira PyGithub

# Install GCP-specific dependencies
RUN pip install google-cloud-bigquery

# Install dask and distributed with specific versions
RUN pip install dask==2.30.0 distributed==2.30.1 toolz==0.11.2 dask-kubernetes==0.11.0

# Install dev and viz dependencies separately
RUN pip install "pytest>=3.8,<4.0" pytest-cov==2.9.0 pytest-env kubernetes pytest-asyncio

RUN pip install bokeh==0.13.0 graphviz>=0.8.3

# Install project dependencies
RUN pip install -e .

# Set PYTHONPATH to include the current directory
ENV PYTHONPATH="/app"

# Make sure the local bin directory is in PATH
ENV PATH="/app/.local/bin:${PATH}"

# Run the specified test file with verbose output, detailed tracebacks, and no caching
ENTRYPOINT ["pytest"]
CMD ["-vv", "-rA", "--tb=long", "-p", "no:cacheprovider", "--disable-warnings", "-s", "tests/environments/storage/test_github_storage.py"]