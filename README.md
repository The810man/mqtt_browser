# MQTT Browser by 810
A Standalone Browser application for the MQTT system

## Description

The MQTT-Browser is an App designed to visualize MQTT topic trees.
The MQTT-Browser uses a Tree-Structure like System to help you organize all of your Topics. You can view multiple Topics in an Tab-view and switch between them.

## Docker

To run MQTT-Browser within docker the container needs access to `X` server.

Type `xhost` to see the authorized clients

```bash
$ xhost
access control enabled, only authorized clients can connect
SI:localuser:<your user name>
```

Normally your user should be allowed to access `X`, so the user and group id of the container needs to be set to your user
and group id. (see `--user=...`. Also, the `X` socket needs to be mounted into the container and the `DISPLAY` variable is
required:

```bash
docker run -it --rm -v /tmp/.X11-unix/:/tmp/.X11-unix --user=$(id -u):$(id -g) -e DISPLAY=$DISPLAY \
  https://github.com/The810man/mqtt_browser.git:latest
```

To access a MQTT broker on the host machine, enter the host machines IP address instead of `localhost`.

## Installation

### Linux

To Install the MQTT-Browser on your Linux machine
you will need to get the .zip File which contains a .deb and
another .zip which contains the direct launch file.

To Run the App via the executable File:

- extract the .zip into a folder
- open a Terminal in that folder
- type in the following command

```bash
chmod u+x [filename]
```

To Install the .deb file to your System:

- open a Terminal on where the .deb file is located
- type in the following command

```bash
sudo dpkg -i [filename].deb
```

- make sure to replace "fileName" with the actual Name

### Mqtt-Browser on Steam or Itch.io

If you dont want to use git or build the app on youre own etc.
Get youre self the App on Steam: [Not available]
Or on Itch.io [Not available]

## Usage

### Connections

- Save and load the Broker connection settings via the client Setup Page
- Input your Brokers Ip and Port then hit Connect

### Tree-View

- Click on Nodes to Expand/Collapse them
- Selected Nodes have a Boreder arround them
- If a node is selected the menu button shows on the nodes right side
- use the nodes menu button to open the selected node on a new Tab or more

### Tools

- on the Right side are the Tools like the Publish tool
- you can open and close those tools
- to Publish enter the Topic-string and hit publish
- you can send json data via the Text-field
- set the QoS level and check if the topic should be retained
- if a topic is selected then the values will show on the value tool
- all parent topics will be displayed and can be copied and deleted via the Topic tool on the Top

### Tabs

- Every Tab except the host Tab can be closed
- Tabs also have a little tool button
- Tab tools can search/ expand and collaps all nodes
- to search for nodes/ topics just click on the search icon

### Disconnect

- On the upper right side is a Disconnect button
- Press the Button to disconnect from the broker
- after disconnecting you will be send back to the client setup page

### Misc

- On the upper left side you will find the settings tab
- On the Settings tab you will find Tree-View settings and a Dark mode button
