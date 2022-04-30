Automated deployment of [traitecoevo/austraits-api](https://github.com/traitecoevo/austraits-api) to Nectar OpenStack.

## Quick deploy

You will need:

- OpenStack credentials for target Nectar project sourced/set in environment (see [Setting up your credentials](https://tutorials.rc.nectar.org.au/openstack-cli/04-credentials))
- Python packages python-openstackclient and python-heatclient installed in environment/virtual environment
    - `$ pip install python-openstackclient python-heatclient`

Deploy it:

```
$ openstack stack create YOUR_STACK_NAME -t base.yaml --parameter "image=IMAGE_ID_OR_NAME"
```

IMAGE_ID_OR_NAME should be an image built by [traitecoevo/austraits-api-nectar-imagebuilder](https://github.com/traitecoevo/austraits-api-nectar-imagebuilder) .

`--parameter` argument (repeatable) lets you override default parameter values from base.yaml template. Some to try:

- `class_c`: class C network 192.168.*xxx*.0/24 to use
- `instance_count`: how many API instances to launch
- `api_branch`: branch of [traitecoevo/austraits_api](https://github.com/traitecoevo/austraits-api) to use (default 'master')

### Deploy standalone instance

To deploy a standalone API instance:

```
$ openstack stack create YOUR_STACK_NAME -t test-instance.yaml --parameter "image=IMAGE_ID_OR_NAME" --parameter="keypair=YOUR_KEYPAIR_NAME"
```

You can again use `api_branch` parameter to deploy the specified branch of traitecoevo/austraits_api .

The instance will be assigned a public-facing IP address, and you can SSH in with the specified keypair.
