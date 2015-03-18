# TF2 dedicated server
#
# VERSION 0.0.1

FROM fedora
MAINTAINER Martin Hagstrom <martin@mrhg.se>

# Update
RUN yum update -y
# Install deps
RUN yum install -y wget glibc.i686 libgcc.i686

# Add user
RUN useradd tf2
USER tf2

# Set parameters
ENV HOME /home/tf2
ENV SERVER $HOME/hlserver
RUN mkdir $SERVER

# Download steamcmd tool
RUN wget -O - http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $SERVER -xz

ADD tf2_ds.txt $SERVER/tf2_ds.txt
ADD update.sh $SERVER/update.sh
RUN $SERVER/update.sh

# Fix missing steamclient error
RUN mkdir -p $HOME/.steam/sdk32
RUN cp $SERVER/linux32/steamclient.so $HOME/.steam/sdk32

# Install plugins
ENV ADDONSBASE $SERVER/tf2/tf/
ENV ADDONS $ADDONSBASE/addons
RUN wget -O - http://mirror.pointysoftware.net/alliedmodders/mmsource-1.10.2-linux.tar.gz | tar -C $ADDONSBASE -xz
RUN wget -O - http://newyork.download.maverickservers.com/source/sourcemod-1.6.1-linux.tar.gz | tar -C $ADDONSBASE -xz
ADD metamod.vdf $ADDONS/metamod.vdf
ADD TF2_Random_Class.smx $ADDONS/sourcemod/plugins/

# Add config files
ADD server.cfg $SERVER/tf2/tf/cfg/server.cfg
ADD motd.txt $SERVER/tf2/tf/cfg/motd.txt
ADD maplist.txt $SERVER/tf2/tf/cfg/maplist.txt
ADD mapcycle.txt $SERVER/tf2/tf/cfg/mapcycle.txt
ADD tf.sh $SERVER/tf.sh

# Server runs on port 27015
EXPOSE 27015/udp

# Default start options
ENTRYPOINT ["/home/tf2/hlserver/tf.sh"]
CMD ["+sv_pure", "1", "+mapcycle", "mapcycle.txt", "+map", "arena_sawmill.bsp", "+maxplayers", "24", "+ip", "0.0.0.0"]
