# Azure Functions on M1 Macs

Currently Azure Functions on ARM isn't supported, so here is a workaround.

Make sure `jq` is installed with `brew install jq`.

`cd` into this directory, then run `make install_func_arm64_worker`

[Source](https://github.com/Azure/azure-functions-python-worker/issues/915#issuecomment-1500553363)
