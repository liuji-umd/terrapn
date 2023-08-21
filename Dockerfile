FROM ros:melodic

# RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
# RUN apt install python-rosdep
# RUN rosdep init
RUN apt-get update
RUN apt-get install -y ros-melodic-cv-bridge && apt-get install -y ros-melodic-pcl-ros

RUN apt-get install -y git
RUN apt-get install wget

#Ceres solver install 
RUN apt-get install -y cmake
RUN apt-get install -y libgoogle-glog-dev libgflags-dev
RUN apt-get install -y libatlas-base-dev
RUN apt-get install -y libeigen3-dev
RUN apt-get install -y libsuitesparse-dev

RUN wget http://ceres-solver.org/ceres-solver-2.1.0.tar.gz
RUN tar zxf ceres-solver-2.1.0.tar.gz
RUN mkdir /opt/ceres-bin
WORKDIR /opt/ceres-bin
RUN cmake /ceres-solver-2.1.0
RUN make -j3
RUN make test
RUN make install




# Build aloam package
RUN mkdir -p /opt/aloam_ws/src
WORKDIR /opt/aloam_ws/src

RUN git clone https://github.com/HKUST-Aerial-Robotics/A-LOAM.git

WORKDIR /opt/aloam_ws/
RUN rosdep install --from-paths src --ignore-src -r -y


RUN .  /opt/ros/melodic/setup.sh && catkin_make 

# Installing miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
WORKDIR /
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN chmod +x Miniconda3*
RUN bash Miniconda3* -b

# Building terrapn packages
RUN mkdir -p /opt/terrapn_ws/src
WORKDIR /opt/terrapn_ws/src

RUN git clone https://github.com/Inception-Robotics/terrapn.git

WORKDIR /opt/terrapn_ws/
RUN rosdep install --from-paths src --ignore-src -r -y
RUN .  /opt/ros/melodic/setup.sh && catkin_make 

WORKDIR /opt/terrapn_ws/src/terrapn/conda
RUN conda env create -f terrapn.yml
