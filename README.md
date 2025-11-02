Automated deployment of [traitecoevo/austraits-api](https://github.com/traitecoevo/austraits-api) to Nectar OpenStack.

## Quick deploy

You will need:

- OpenStack credentials for target Nectar project sourced/set in environment (see [Setting up your credentials](https://tutorials.rc.nectar.org.au/openstack-cli/04-credentials))
- Python packages python-openstackclient and python-heatclient installed in environment/virtual environment
    - `$ pip install python-openstackclient python-heatclient`

Deploy it:

```
$ openstack stack create YOUR_STACK_NAME -t base.yaml \
    --parameter="image=IMAGE_ID_OR_NAME" \
    --parameter="logstash_image=LOGSTASH_IMAGE_ID_OR_NAME" \
    --parameter="availability_zone=NECTAR_AZ"
```

IMAGE_ID_OR_NAME and LOGSTASH_IMAGE_ID_OR_NAME should be images built by [traitecoevo/austraits-api-nectar-imagebuilder](https://github.com/traitecoevo/austraits-api-nectar-imagebuilder) .

`--parameter` argument also lets you override default parameter values from base.yaml template. Some to try:

- `class_c`: class C network 192.168.*xxx*.0/24 to use
- `instance_count`: how many API instances to launch
- `api_branch`: branch of [traitecoevo/austraits_api](https://github.com/traitecoevo/austraits-api) to use (default 'master')

### Deploy standalone instance

To deploy a standalone API instance:

```
$ openstack stack create YOUR_STACK_NAME -t test-instance.yaml \
    --parameter="image=IMAGE_ID_OR_NAME" \
    --parameter="logstash_image=LOGSTASH_IMAGE_ID_OR_NAME" \
    --parameter="availability_zone=NECTAR_AZ" \
    --parameter="keypair=YOUR_KEYPAIR_NAME"
```

You can again use `api_branch` parameter to deploy the specified branch of [traitecoevo/austraits_api](https://github.com/traitecoevo/austraits-api) .

The instance will be assigned a public-facing IP address, and you can SSH in with the specified keypair.

## Features

The code enables the deployment of the Austraits API on Nectar via [OpenStack](https://docs.openstack.org/). OpenStack is a cloud operating system that controls large pools of compute, storage, and networking resources throughout a datacenter, all managed through a dashboard that gives administrators control while empowering their users to provision resources through a web interface.

Features of this deployment include: (What were the design decisions behind this setup?)

- Automatic setup of multiple Austraits API instances behind a load balancer.
- Automatic setup of DNS records for the API instances.
- Automatic setup of a Logstash instance for logging of traffic from the API instances.
- Retrieval of Data from Swift object storage during instance initialization.
- Configurable parameters for customizing the deployment, such as the number of API instances, instance flavor, and DNS settings, branch of Austraits API to deploy. 

## Notes on setup and usage

OpenStack uses [Heat templates](https://docs.openstack.org/heat/latest/) to define the infrastructure, and cloud-init scripts to set up the instances. Briefly, relevant files are as follows:

.
├── base.yaml: main Heat template for deploying a full Austraits API stack
├── test-instance.yaml: Heat template for deploying a standalone Austraits API instance (with public IP and without load balancer)
├── cloud-init.yaml: cloud-init script for setting up instances
├── filebeat.yml: Filebeat configuration for log shipping
├── logstash: For setting up Logstash instance
├── network.yaml: Network configuration for the stack
├── nginx.conf: Nginx configuration for the API gateway
├── server.yaml: Heat template for deploying a single Austraits API instance
├── userdata.sh: User data script for instance initialization
└── utils: Utility scripts and files

When creating the stack, the code in userdata.sh is eventually executed. this is where we Need to customize fetching of data and starting of the API. To get there, the flow is:

- base.yml: main template
    - calls asg (autoscaling group) to create multiple API instances
        - calls `server.yaml` for each instance
            - calls `cloud_init.yaml`
            - calls `userdata.sh`
                - gets data
                - copies API code
                - starts API

## Troubleshooting

If deployment fails, you might might

- validate the template with byt running `openstack stack validate -t base.yaml .....`
- use `--debug` flag to get more verbose output during stack creation: `openstack stack create --debug YOUR_STACK_NAME -t base.yaml .....`
- check the logs on the instances via the NECTAR dashboard or by SSHing in (for standalone instance) or via the logstash instance for full stack deployments.


