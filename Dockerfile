FROM --platform=x86_64 python:3.8 as development

ENV SAP_AHOST=
ENV SAP_SYSNR=
ENV SAP_CLIENT=
ENV SAP_USER=
ENV SAP_PASSWD=

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

# ================= SAP RFC Configuration ======================
RUN mkdir -p /usr/local/sap
COPY ./sap-nw-sdk.tar.gz .
RUN tar -zxf sap-nw-sdk.tar.gz --directory /usr/local/sap
RUN rm sap-nw-sdk.tar.gz
ENV SAPNWRFC_HOME=/usr/local/sap/nwrfcsdk
RUN echo "/usr/local/sap/nwrfcsdk/lib" > /etc/ld.so.conf.d/nwrfcsdk.conf
RUN ldconfig -v | grep sap
# ==============================================================

COPY ./pyproject.toml ./poetry.lock* /tmp/
WORKDIR /tmp
RUN poetry install --no-root

RUN mkdir -p /app
RUN mkdir -p /data
WORKDIR /app

FROM --platform=x86_64 tiangolo/uvicorn-gunicorn-fastapi:python3.8 as production

ENV SAP_AHOST=
ENV SAP_SYSNR=
ENV SAP_CLIENT=
ENV SAP_USER=
ENV SAP_PASSWD=

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

# ================= SAP RFC Configuration ======================
RUN mkdir -p /usr/local/sap
COPY ./sap-nw-sdk.tar.gz .
RUN tar -zxf sap-nw-sdk.tar.gz --directory /usr/local/sap
RUN rm sap-nw-sdk.tar.gz
ENV SAPNWRFC_HOME=/usr/local/sap/nwrfcsdk
RUN echo "/usr/local/sap/nwrfcsdk/lib" > /etc/ld.so.conf.d/nwrfcsdk.conf
RUN ldconfig -v | grep sap
# ==============================================================

COPY ./pyproject.toml ./poetry.lock* /tmp/
WORKDIR /tmp
RUN poetry install --no-root --no-dev

COPY ./ /app
RUN mkdir -p /data
WORKDIR /app
EXPOSE 80