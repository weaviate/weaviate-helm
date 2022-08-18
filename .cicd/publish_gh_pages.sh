#!/bin/bash

set -eou pipefail

pip3 install chartpress==1.3.0

chartpress --publish-chart
