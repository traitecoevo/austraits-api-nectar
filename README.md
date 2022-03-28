Automated deployment of [traitecoevo/austraits-api](https://github.com/traitecoevo/austraits-api) to Nectar OpenStack.

## Quick deploy

You will need:

- OpenStack credentials for target Nectar project sourced/set in environment (see [Setting up your credentials](https://tutorials.rc.nectar.org.au/openstack-cli/04-credentials))
- Python packages python-openstackclient and python-heatclient installed in environment or Python virtual environment
    - `pip install python-openstackclient python-heatclient`

Deploy it:

```
$ openstack stack create YOUR_STACK_NAME -t base.yaml --parameter "parameter1=foo; parameter2=bar"
```

Optional `--parameter` argument lets you override default parameters from base.yaml template. Some to try:

- `instance_count`: how many API instances to launch
- `api_branch`: branch of [traitecoevo/austraits_api](https://github.com/traitecoevo/austraits-api) (default 'master') to use for deployment

### Deploy single instance

To deploy just a single instance:

```
$ openstack stack create YOUR_STACK_NAME -t test-instance.yaml --parameter "keypair=YOUR_KEYPAIR_NAME"
```

You can again use `api_branch` parameter to deploy the specified branch of traitecoevo/austraits_api.

This will be assigned a public-facing IP address, and you can SSH in with the specified keypair.
