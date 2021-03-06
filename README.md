# How To Use These Images
### Hardware Requirements
These images require an nvidia GPU. I have tested it with Maxwell, Pascal, Volta, and Turing architectures without issue, but be aware that you will need 11-24GB of VRAM depending on what specifically you are trying to do with the images. See the vast.ai section for a guide to using this image on vast's paid cloud service.

### Software Requirements
Using local GPUs in docker also requires [nvidia-docker](https://github.com/NVIDIA/nvidia-docker), which currently is only fully supported in Linux (note that these images do not work in WSL2 given the lack of support for the NVML API). Follow the above link for install instructions.

### Using the image locally
The images can be run locally using the following command: `docker run -it --gpus all btrude/jukebox-docker bash` which will pull down the image when run for the first time and then take you to the jukebox directory within a running container instance. From there you can run any commands that are available in the [jukebox README](http://github.com/openai/jukebox). You will most likely want to mount a volume for transferring files to and from the container. See [docker volumes documentation](https://docs.docker.com/storage/volumes/) or alternatively [docker cp documentation](https://docs.docker.com/engine/reference/commandline/cp/) for copying directly via the command line. For those new to docker be aware that files will not persist when these containers are spun down, so make sure you are establishing a method for transferring any artifacts out of the container before exiting it. Likewise the openai-provided models will have to download when using the image for the first time so it is recommended to save them outside of the container for later use (they are too large to practically be stored within the image).

### A guide to using these images on vast.ai
For those that may want to use jukebox but don't have the requisite hardware I have written up the following guide for using the images on vast.ai. It is most likely possible to use this guide with other cloud services as well, but I have only tested it with vast.

Before starting register a vast.ai account and [follow this guide](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) through to [this page](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) but instead of putting the ssh key into your github account put it into the ssh key box on [your vast account](https://vast.ai/console/account/)

Afterwards, create a vast instance allocating ~50gb of disk space (disk space is very cheap so best to play it safe and allocate as much as you can), setting the instance image to either `btrude/jukebox-docker:latest` or `btrude/jukebox-docker:apex` in the "Instance Configuration" section, and then go to https://vast.ai/console/instances/ and wait for it to spin up. The images from this repo should be cached so if you don't see the blue button transition to "Connect" within a few minutes then its most likely broken and you should destroy and start over until you are given the "Connect" option after it says the image has successfully loaded (I bring this up because sometimes the instances fail to load and its not obvious through the ui, this will probably save someone time talking to customer support/wasting credits).

Click "Connect" and a modal will pop up with an ssh command, copy that command into your terminal and type "yes" when prompted and then cd /opt/jukebox/ as vast does not take you to the docker image workdir. You should now be connected to the vast instances inside an instance of tmux. tmux allows your processes to stay running even after you have disconnected from the instance which is potentially important depending on how long you intend to use it for. See https://tmuxcheatsheet.com/ for important tmux commands, or just do ctrl+b, d to detach from the session, then type exit to exit ssh when you are done. Follow the instructions in the cheatsheet to re-attach to the session if necessary.

In order to pass your own dataset, prompt, or original code, or to recover any samples you made you will have to use `scp`. Take the ssh command provided to you by vast, e.g:
`ssh -p 16090 root@ssh5.vast.ai -L 8080:localhost:8080` and pass the relevant info to scp like `scp -P 16090 root@ssh5.vast.ai:/opt/jukebox/path/to/file.wav ~/path/on/my/local/mac`

So if you wanted to transfer a file from the default example in this repo's readme to your desktop it would look like this `scp -P 16090 root@ssh5.vast.ai:/opt/jukebox/sample_5b/level_0/item_0.wav ~/Desktop` depending on which specific file, or just `scp -r -P 16090 root@ssh5.vast.ai:/opt/jukebox/sample_5b/ ~/Desktop` if you want to transfer an entire directory.

You can also go in the opposite direction if you need to send things to the instance like `scp -r -P 16090 ~/Desktop/my_audio_dataset/ root@ssh5.vast.ai:/opt/jukebox/`

Note that the metadata in sample.py is hard-coded so you may want to use nano to modify the metadata (`nano jukebox/sample.py`), then arrow (nano is a command line text editor) down to line 188 and change the defaults to whatever you want (see here: https://github.com/openai/jukebox/tree/master/jukebox/data/ids for the default options; v3=1b, v2=5b). Ctrl + x, y to save and exit nano.

### About
This image is created using [software developed by openai](https://github.com/btrude/jukebox-docker/blob/master/citation.bib). I have only made this to facilitate running the software on vast.ai for my own personal use and have made this available publically so others can leverage the GPUs vast provides. Please direct any non-docker issues to https://github.com/openai/jukebox/issues.
