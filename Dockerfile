FROM alpine:3.5

VOLUME [ "/tmp/temp-nfs/docker1", "/opt" ]

# ENTRYPOINT ["echo", "`hostname`", ">>", "/opt/hostname.txt"]
ENTRYPOINT [ "ping", "8.8.8.8" ]

