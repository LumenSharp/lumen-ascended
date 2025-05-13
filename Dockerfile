FROM debian:bookworm-slim

USER root

# 'tiny' repo by 'krallin' found here: https://github.com/krallin/tini
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV USER="warden"
ENV GROUP="warden"
ENV PGID=1000
ENV PUID=1000
ENV USER_HOME=/home/${USER}
ENV SERVER_ROOT_DIR=${USER_HOME}/data
ENV SERVER_GAME_DIR=${SERVER_ROOT_DIR}/game
ENV STEAM_APP_ID="376030"

ENV SERVER_NAME=RandomGameServerFromDocker
ENV SERVER_MAP=TheIsland
ENV SERVER_MODS=
ENV SERVER_SAVE_NAME="GenericWorld"
ENV MAX_PLAYERS=4
ENV ADMIN_PASS=ChangeMe!SeriouslyDontLeaveMeLikeThiss5
ENV SERVER_PASS=xzdfvv11
ENV PORT_GAME=7777
ENV PORT_RCON=27020
ENV RCON_ON=true

# Boilerplate setup for our USER, GROUP, PUID, and PGID env vars
RUN addgroup --gid ${PGID} ${GROUP}
RUN adduser --home ${USER_HOME} --uid ${PUID} --gid ${PGID} ${USER}

# An annoying issue. The solution below was found on StackOverflow from user 'GrabbenD'
# https://stackoverflow.com/questions/76688863/apt-add-repository-doesnt-work-on-debian-12
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        software-properties-common && \
    add-apt-repository \
        -U http://deb.debian.org/debian \
        -c non-free-firmware \
        -c non-free && \
    add-apt-repository \
        -U http://deb.debian.org/debian \
        -c non-free-firmware \
        -c non-free && \
    dpkg --add-architecture i386 && \
    apt-get clean

# Steam requires us to accept their license agreement before installation takes place. Again, solution found on S.O. from user 'dragon788'
# https://askubuntu.com/questions/506909/how-can-i-accept-the-lience-agreement-for-steam-prior-to-apt-get-install
RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
         wine wine64 wine32 xvfb xauth steamcmd wget sudo && \
    apt-get clean
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# We need this file, but with a pre-specified version:
# https://github.com/Winetricks/winetricks/blob/master/src/winetricks
ARG WINETRICKS_VERSION=20250102
ADD "https://raw.githubusercontent.com/Winetricks/winetricks/refs/tags/${WINETRICKS_VERSION}/src/winetricks" /usr/bin/winetricks
RUN chmod 755 /usr/bin/winetricks

RUN chown -R ${PUID}:${PGID} "/home/${USER}"
RUN chmod -R 755 "/home/${USER}"

COPY start_game.sh "/start_game.sh"
RUN chown ${PUID}:${PGID} "/start_game.sh"
RUN chmod +x "/start_game.sh"

COPY entrypoint.sh "/entrypoint.sh"
RUN chown ${PUID}:${PGID} "/entrypoint.sh"
RUN chmod +x "/entrypoint.sh"

ENTRYPOINT ["/tini", "--"]
# Run your program under Tini
CMD ["/entrypoint.sh"]