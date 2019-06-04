FROM ros:kinetic-ros-base

# python requirements
RUN apt-get update && apt-get install -y \
    python-pip
COPY python_requirements.txt /tmp
WORKDIR /tmp
RUN pip install -r python_requirements.txt

# install build tools
RUN apt-get update && apt-get install -y \
      python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# clone ros package repo
ENV ROS_WS /opt/ros_ws
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS
RUN git -C src clone \
      https://github.com/frdedynamics/ros_robotino_rest_pkg.git

# install ros package dependencies
RUN apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src/ros_robotino_rest_pkg \
      --ignore-src && \
    rm -rf /var/lib/apt/lists/*

# build ros package source
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build \
      ros_robotino_rest_pkg

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh


# run ros package launch file
CMD ["roslaunch", "ros_robotino_rest_pkg", "robotino_bringup.launch"]
