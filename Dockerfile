FROM python:3.8.9

RUN python -m pip install --upgrade pip
RUN apt-get update
RUN apt-get install vim -y
# INSTALL AND CONFIGURE POETRY
ENV PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.1.5 \
    POETRY_HOME=/opt/poetry \
    POETRY_EXPERIMENTAL_NEW_INSTALLER=false \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    PATH=/opt/poetry/bin:${PATH}
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

RUN poetry new app
WORKDIR app/
COPY requirements.txt .

#RUN awk -F '==' '{print $1}' requirements.txt | xargs -n1 poetry add
RUN awk '{print $1}' requirements.txt | xargs -n1 poetry add
RUN poetry install --no-interaction

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 /usr/bin/tini

RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--NotebookApp.allow_remote_access=True", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
