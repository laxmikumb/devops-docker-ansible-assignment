FROM ubuntu:22.04

RUN apt-get update \
    -o Acquire::Retries=5 \
    -o Acquire::http::No-Cache=true \
    -o Acquire::BrokenProxy=true \
    && apt-get install -y --fix-missing \
    -o Acquire::http::No-Cache=true \
    openssh-server sudo ufw iproute2 iputils-ping \
    python3 curl git nginx openssl vim net-tools \
    && mkdir -p /var/run/sshd

RUN useradd -m -s /bin/bash deployer \
    && mkdir -p /home/deployer/.ssh \
    && chmod 700 /home/deployer/.ssh \
    && echo "deployer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/deployer \
    && chmod 440 /etc/sudoers.d/deployer

COPY authorized_keys /home/deployer/.ssh/authorized_keys
RUN chmod 600 /home/deployer/.ssh/authorized_keys \
    && chown -R deployer:deployer /home/deployer/.ssh

RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 80 443
ENTRYPOINT ["/entrypoint.sh"]
