From debian:bullseye

RUN apt update
RUN apt install -y curl apt-transport-https gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ;\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list;
RUN apt update
RUN apt install -y code git make python3 python3-pip bash-completion jq \
                   task-japanese locales-all locales ibus-mozc

ARG uid=1000
ARG uname=vscode
RUN addgroup --system --gid ${uid} ${uname} ;\
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash ${uname} ;\
    echo "${uname}:${uname}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ;

RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"


ARG vsExtDir=/opt/vscode-extensions
ARG workdir=/work
RUN mkdir -p ${vsExtDir} ${workdir} ; chown ${uname} ${vsExtDir} ${workdir}

USER ${uname}

# install vscode plugin...
RUN code --install-extension  MS-CEINTL.vscode-language-pack-ja --extensions-dir ${vsExtDir}; \
    code --install-extension  ms-python.python                  --extensions-dir ${vsExtDir}

ENV vslocale=ja
ENV vsExtDir=${vsExtDir}
VOLUME ${vsExtDir} ${workdir}
WORKDIR ${workdir}

CMD code --locale ${vslocale}  --extensions-dir ${vsExtDir}
