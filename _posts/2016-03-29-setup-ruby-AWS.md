---
layout:     post
title:      How to set up an ipython cluster
date:       2016-03-28
summary:    Summary of installation steps to configure an ipython cluster (Ubuntu + OSX)
categories: blog
---

The idea of this project is to make use of different machines for large parallel computations such as parameter search.
For example, I am investing the behavior of a spiking neural network for different values of external input and electrical synapse 
strength. Here I plot the power of strongest frequency components after analysis in the Fourier domain:

![phase plan diagram](/images/phase_plan.png)

The library `ipyparallel` allows such computation, by distributing the computation accorss severals workers.

### Install ipython

[pyenv](https://github.com/yyuu/pyenv) is a convenient tool to control which version of python is installed. 
For this installation, I went with `anaconda3.2-5-0`

```bash
pyenv install anaconda3.2-5-0
```

(be sure you have updated pyenv previously doing `pyenv update` if available, or `git pull origin master` if you cloned pyenv,
or `brew update && brew upgrade pyenv` if pyenv was installed with brew.

### Configure SSH for all nodes

[ssh without password](http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/)

```bash
ssh-keygen  # (without passphrase)
ssh-copy-id -i ~/.ssh/id_rsa.pub remote-host #(where remote-host is the machine you try to ssh to) (https://github.com/beautifulcode/ssh-copy-id-for-OSX)
```

Then try ssh remote-host


### Create profile cluster on hub machine

```bash
ipython profile create --parallel --profile=cluster
```
### Create symbolic link for python on every node:

```bash
sudo ln -s ~/.pyenv/versions/anaconda3-2.5.0/bin/python /python
```

### Edit ~/.ipython/profile\_cluster/ipcluster\_config.py

```python
c = get_config()

c.IPClusterEngines.engine_launcher_class = 'SSH'
c.LocalControllerLauncher.controller_args = ["--ip='*'"]

c.SSHEngineSetLauncher.engines = {
    'localhost': 4,
    'node1': 4,
    'node2': 4,
}
```

### Create profile cluster on nodes

```bash
ipython profile create --parallel --profile=cluster
```

### Duplicate packages from one machine 

In case you already have one machine with all the packages you need, it is possible to duplicate this installation
by generating a list of moduled installed. 

With anaconda

```bash
conda list --export > env.txt
```

Or with pip

```bash
pip freeze > requirements.txt
```

However, because anaconda doesn't respect the order of the packages and will
likely stop when a dependeny is not yet installed, the following script works:

```bash
cat requirements.txt | while read PACKAGE; do conda install --yes "$PACKAGE"; done
```

From /Dropbox/ipythoncluster: sudo python pipreqs.py requirements.txt

Or if you use pip instead

```python
"""
pipreqs.py: run ``pip install`` iteratively over a requirements file.
"""
def main(argv):
    try:
        filename = argv.pop(0)
    except IndexError:
        print("usage: pipreqs.py REQ_FILE [PIP_ARGS]")
    else:
        import pip
        retcode = 0
        with open(filename, 'r') as f:
            for line in f:
                pipcode = pip.main(['install', line.strip()] + argv)
                retcode = retcode or pipcode
        return retcode
if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv[1:]))
```

then run

```bash
python pipreqs.py requirements.txt
```


### Start the cluster

```
ipcluster start --profile=cluster
```

### Setup Ubuntu cloud

[Installing JUJU](https://help.ubuntu.com/lts/clouddocs/en/Installing-Juju.html)

```bash
sudo apt-get update
sudo apt-get install juju-core
sudo apt-get install juju-quickstart juju-deployer charm-tools
```


[installing MAAS](https://maas.ubuntu.com/docs/install.html)

```bash
sudo add-apt-repository ppa:maas/stable
sudo apt-get update
sudo apt-get install maas
```

### Additionnal tips

To sync a folder over the network:

```bash
rsync -r ~/Projects/github/cortex/data/ gp1514@beast:~/Dropbox/ICL-2014/Code/c-code/cortex/data
```



### Additional Resources

-   [How to set up a private ipython cluster](http://ianhowson.com/how-to-set-up-a-private-ipython-cluster.html)
-   [How to set up an ipython cluster](https://github.com/tritemio/PyBroMo/wiki/Howto-setup-an-IPython-cluster)
