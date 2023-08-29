FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04

# Installing ROS Noetic
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq wget curl git build-essential vim sudo lsb-release locales bash-completion
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt-get update -q && \
    apt-get install -y ros-melodic-desktop-full &&\
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential &&\
    apt install -y python-rosdep &&\
    rm -rf /var/lib/apt/lists/*
RUN rosdep init
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN rosdep update

# RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
# RUN apt install python-rosdep
# RUN rosdep init
RUN apt-get update
RUN apt-get install -y ros-melodic-cv-bridge && apt-get install -y ros-melodic-pcl-ros

RUN apt-get install -y git
RUN apt-get install wget

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

# Installing Ceres solver
# Using tag 2.1.0rc2 as this tag passes cuda related test cases 
# Also, the test cases were not completing successfully as the docker build process was not able to access nvidia GPUs, to solve this issue I modified /etc/docker/daemon.json file and made nvidia runtime as default. 
# Here is the ref: https://earthly.dev/blog/buildingrunning-nvidiacontainer/#:~:text=The%20NVIDIA%20runtime%20must%20be,the%20%2D%2Dgpus%20all%20flag.
RUN apt-get install -y cmake libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev libsuitesparse-dev
WORKDIR /opt/
RUN git clone https://ceres-solver.googlesource.com/ceres-solver &&\ 
    cd ceres-solver &&\
    git checkout tags/2.1.0rc2 &&\ 
    mkdir build &&\
    cd build &&\
    nvidia-smi &&\
    cmake .. &&\
    make -j3 &&\
    make test &&\
    make install
    
# Build aloam package
RUN mkdir -p /opt/aloam_ws/src
WORKDIR /opt/aloam_ws/src

RUN git clone https://github.com/HKUST-Aerial-Robotics/A-LOAM.git

WORKDIR /opt/aloam_ws/
RUN rosdep install --from-paths src --ignore-src -r -y


RUN .  /opt/ros/melodic/setup.sh && catkin_make 
