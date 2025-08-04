# slurm.cluster

Template for setting up and deploying a Slurm cluster.

## Overview

This repository provides tools and configuration templates for setting up a Slurm cluster. Slurm is an open-source workload manager used for high-performance computing (HPC) environments.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/laugesen11/slurm.cluster.git
cd slurm.cluster
```

### 2. Configure the Cluster

Use the provided `configure.sh` script to set up your cluster configuration. You can specify various options for cluster name, master node, backup master, user, group, database, python path, plugins, and more.

#### Example Command

```bash
./configure.sh --cluster-name mycluster --master-name master01 --cluster-loc /opt/slurm
```

Run `./configure.sh --help` or view the [configure.sh](https://github.com/laugesen11/slurm.cluster/blob/main/configure.sh) for all available options.

### 3. Review and Edit Node & Nodeset Configurations

- Edit `etc/conf/nodes.conf` to define your compute nodes.
  - Example:
    ```
    NodeName=linux[1-32] CPUs=1 State=UNKNOWN
    ```
  - Adjust CPUs, memory, and other options as needed for your hardware.

- Edit `etc/conf/nodesets.conf` to define logical groupings of nodes.

### 4. Build and Deploy

If a Makefile or build automation is present, use the standard `make` command to build or deploy services:

```bash
make
```

Refer to the repository documentation or Makefile for any specific build targets.

---

## Configuration Files

- **etc/conf/nodes.conf**: List your compute nodes and hardware specs.
- **etc/conf/nodesets.conf**: Define nodesets for job scheduling and partitioning.

For more information and options, consult the official [Slurm documentation](https://slurm.schedmd.com/documentation.html).

## License

No explicit license is provided. Contact the repository owner for usage permissions.

## Support

Open an issue in the [GitHub repository](https://github.com/laugesen11/slurm.cluster/issues) for questions and help.

---

*Template maintained by [laugesen11](https://github.com/laugesen11).*
