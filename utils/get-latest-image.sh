#!/bin/bash

prefix="austraits-api-base"

openstack image list -f value | grep $prefix | awk '{print $2}' | sort -n | tail -n 1
