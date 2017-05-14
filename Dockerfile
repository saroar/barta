# Copyright (C) 2016 PerfectlySoft Inc.
# Author: Shao Miller <swiftcode@synthetel.com>

FROM perfectlysoft/ubuntu1510
RUN /usr/src/Perfect-Ubuntu/install_swift.sh --sure
RUN git clone https://github.com/saroar/barta
/usr/src/barta
WORKDIR /usr/src/barta
RUN swift build
CMD .build/debug/barta --port 80
