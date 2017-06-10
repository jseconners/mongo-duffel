mongo-duffel
====================================================


Quick, isolated MongoDB install setup and data packaging for
testing or small dev work

-------------------------------------------

mongo-duffel handles installing an isolated MongoDB instance in a local
directory, prefixing/removing the binaries from your PATH environment,
starting and stopping the server and also provides the option for packing up
the data directory for versioning and unpacking across machines.

Utilize the packing/unpacking alongside with a python virtual environment
for a nice little portable workspace.

Usage
------------

Installing and starting the local MongDB instance
::

    $ source duffel.sh up
    >
    > No local mongodb install found
    >
    > 1) debian 7 x64		  4) rhel 7 x64		   7) ubuntu 12.04 x64	   10) ubuntu 16.04 ARM 64
    > 2) debian 8 x64		  5) suse 11 x64	   8) ubuntu 14.04 x64	   11) osx 10.7+ x64
    > 3) rhel 6 x64		      6) suse 12 x64	   9) ubuntu 16.04 x64	   12) osx 10.7+ w/ssl x64
    > Select OS version for mongodb install: 9
    >
    > Download and install for ubuntu 16.04 x64? [y/N] y
    >
    >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    >                                  Dload  Upload   Total   Spent    Left  Speed
    > 100 95.7M  100 95.7M    0     0  6377k      0  0:00:15  0:00:15 --:--:-- 6033k
    > Installing local mongodb...
    > Local binaries already in path
    > Starting local mongodb
    > about to fork child process, waiting until server is ready for connections.
    > forked process: 4675
    > child process started successfully, parent exiting


Stopping the local instance and optionally packing up the data
::

    $ source duffel.sh down
    >
    > Removing local binaries from path
    > Stopping server
    > Pack up data directory to dataduffel.tar.gz? [y/N] y
    > Packing it up...
    > Done

Both 'up' and 'down' are safe to run multiple times. 'up' will only install if
it can't find a local installation.

Starting and existing installation
::

    $ source duffel.sh up
    >
    > Local mongodb installed
    > Adding local binaries to path
    > Starting local mongodb
    > about to fork child process, waiting until server is ready for connections.
    > forked process: 4911
    > child process started successfully, parent exiting

Also, 'up' will give you the option to unpack the dataduffel.tar.gz file into
the data directory (overwriting existing contents) if it finds it in the same
directory. You can also run 'up' any time to unpack the dataduffel.tar.gz file -
the script will handle stopping and restarting the server to do this.

Starting up and unpacking data
::

    $ source duffel.sh up
    >
    > Local mongodb installed
    > Adding local binaries to path
    > Overwite data dir with dataduffel.tar.gz? [y/N] y
    > Unpacking data...
    > Done
    > Starting local mongodb
    > about to fork child process, waiting until server is ready for connections.
    > forked process: 5091
    > child process started successfully, parent exiting

Unpacking data again while server is already running
::

    $ source duffel.sh up
    >
    > Local mongodb installed
    > Local binaries already in path
    > Overwite data dir with dataduffel.tar.gz? [y/N] y
    > Stopping server
    > Unpacking data...
    > Done
    > Starting local mongodb
    > about to fork child process, waiting until server is ready for connections.
    > forked process: 5191
    > child process started successfully, parent exiting


Installation
------------
::
    Clone the repository and run 'source duffel.sh up' to install and start
    the isolated MongoDB instance

Author
------

-  James Conners