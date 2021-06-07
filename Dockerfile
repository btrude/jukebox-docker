# combine python:3.7.7-stretch/buildpack-deps:stretch
# with nvidia/cuda:11.1-cudnn8-devel-ubuntu18.04 for jukebox training with apex

FROM nvcr.io/nvidia/pytorch:21.05-py3

# workaround readline fallback
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && apt-get install -y -q

RUN apt-get update && apt-get install -y \
	ffmpeg \
	libopenmpi-dev \
	openmpi-bin \
	libsndfile1 \
	libavdevice-dev \
	libavfilter-dev \
	ssh

RUN mkdir -p /opt/jukebox
WORKDIR /opt/jukebox


RUN pip install av

COPY ./jukebox/requirements.txt /opt/jukebox/
RUN pip install -r requirements.txt && rm requirements.txt

COPY ./jukebox /opt/jukebox
RUN rm apex/setup.py
RUN pip install -e .
RUN pip install tensorboard ./tensorboardX

COPY ./setup.py /opt/jukebox/apex/
RUN pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./apex

EXPOSE 6006
