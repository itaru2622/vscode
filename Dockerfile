From debian:bullseye

RUN apt update
RUN apt install -y curl apt-transport-https gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ;\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list;
RUN apt update
RUN apt install -y code git make python3 python3-pip bash-completion jq \
                   task-japanese locales-all locales ibus-mozc sudo

ARG uid=1000
ARG uname=vscode
ARG workdir=/work
RUN mkdir -p ${workdir} ; \
    addgroup --system --gid ${uid} ${uname} ; \
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash ${uname} ; \
    echo "${uname}:${uname}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user; \
    chown -R ${uname} /home/${uname} ${workdir}; \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"


# install nlp things and etc.
RUN pip3 install spacy pandas flask fastapi uvicorn[standard] q; \
    python3 -m spacy download    en_core_web_lg;


USER ${uname}

# install vscode plugin...
RUN code --install-extension  ms-python.python; \
    code --install-extension  MS-CEINTL.vscode-language-pack-ja

VOLUME  ${workdir}
WORKDIR ${workdir}

CMD code
