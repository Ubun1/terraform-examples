FROM fedora:28

RUN yum install git make autoconf unzip findutils which -y
RUN curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \ 
    unzip /tmp/terraform.zip -d /tmp && \
    install /tmp/terraform /usr/local/bin

RUN useradd terraform-examples

USER terraform-examples
COPY --chown=terraform-examples . /home/terraform-examples/proj
WORKDIR "/home/terraform-examples/proj"
RUN autoconf && ./configure && make init
CMD ["/bin/bash"]
