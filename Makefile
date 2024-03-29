all: build test stop

# this is to forward X apps to host:
# See: http://stackoverflow.com/a/25280523/1336939
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# paths
TBB_PATH=/home/docker/tbcrawl/tor-browser/
CRAWL_PATH=/home/docker/tbcrawl
GUEST_SSH=/home/docker/.ssh
HOST_SSH=${HOME}/.ssh

ENV_VARS = \
	--env="DISPLAY=${DISPLAY}" 					\
	--env="XAUTHORITY=${XAUTH}"					\
	--env="VIRTUAL_DISPLAY=$(VIRTUAL_DISPLAY)"  \
	--env="START_XVFB=false"                    \
	--env="TBB_PATH=${TBB_PATH}"
VOLUMES = \
	--volume=${XSOCK}:${XSOCK}					\
	--volume=${XAUTH}:${XAUTH}					\
	--volume=${HOST_SSH}:${GUEST_SSH}			\
	--volume=`pwd`:${CRAWL_PATH}				\


# network interface on which to listen
DEVICE=ens5

# commandline arguments
CRAWL_PARAMS=-c walsh -u ./videos.txt --timeout 10 -s -d ${DEVICE} -v

# Make routines
build:
	@docker build -t tbcrawl --rm .

run:
	@docker run -it --rm ${ENV_VARS} ${VOLUMES} --net host --privileged --memory 1024mb --shm-size 1024mb \
	tbcrawl python3 bin/tbcrawler.py $(CRAWL_PARAMS)

run-without-tor:
	@docker run -it --rm ${ENV_VARS} ${VOLUMES} --net host --privileged --memory 1024mb --shm-size 1024mb \
	tbcrawl python3 bin/tbcrawler.py $(CRAWL_PARAMS) --without-tor

stop:
	@docker stop `docker ps -a -q -f ancestor=tbcrawl`
	@docker rm `docker ps -a -q -f ancestor=tbcrawl`

destroy:
	@docker rmi -f tbcrawl

reset: stop destroy
