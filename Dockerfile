FROM ubuntu:20.04
RUN apt-get update && apt-get install -y procps coreutils bash
COPY vm-health-check.sh /vm_health_check.sh
ENTRYPOINT ["bash", "/vm_health_check.sh"]
