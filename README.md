# OCI Kube Prompt

<img src="images/oci-kube-prompt.gif" width="600" />

The project is a small Bash script that displays the Kubernetes cluster actively set in the environment in the Bash prompt.
This is currently geared toward [Oracle Container Engine](https://cloud.oracle.com/containers/kubernetes-engine) Kubernetes
clusters, but could be easily extended to support other vendors.

As many people who operate Kubernetes-based systems have experienced, it's all too easy to accidentally point to the
wrong Kubernetes cluster (like dev instead of prod) and get yourself into trouble.  Displaying the name of the active
cluster reduces the chances of making a mistake.

The project was originally inspired by [this](https://pracucci.com/display-the-current-kubelet-context-in-the-bash-prompt.html)
blog post.  However, for many vendors (OCI is one of them) the real human-readable information about the cluster, like its
name, is not directly available within the kubeconfig file - it requires a bit of extra work to fetch that.

# Usage

## Config File
Create a config file containing your OCI tenancy/user details, as in the
[OCI docs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/sdkconfig.htm), with a user that is authorized to list
compartments and cluster.  For example:

```
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
tenancy=ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
key_file=/tmp/my_api_key.pem
fingerprint=aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa:aa
```

## Source kube-prompt.sh within your .bashrc or .bash_profile

For example place the oci-kube-prompt.sh script in `~/.oci`, then add to your `.bashrc`:

```
source ~/.oci/oci-kube-prompt.sh
```

## Fetch OCI Clusters

We don't want to reach out to OCI over and over again, so this is a one time step (or whenever you want to refresh your
cluster list): fetch the current OCI clusters in the tenancy.  A directory `~/.oci/clusters` will be created containing
mappings of cluster OCID -> human readable cluster name.  This can take a minute, depending on how many compartments,
clusters you have:

```
fetch_oci_clusters
```

## Add to your prompt

Finally, add a call to the `__oci_cluster_name` function into PS1 within your .bashrc or .bash_profile.  For example:

```
export PS1="\W\[\e[1;33m\]\$(__oci_cluster_name)\[\033[00m\] \$ "
```

## Enjoy

At this point, whenever your KUBECONFIG is pointed to an OCI cluster, you'll see the region/name of the cluster in your
Bash prompt, like:

```
tmp(uk-london-1/dan-dev) $ kubectl get pod --all-namespaces
kube-system   kube-dns-79744689dc-lhqzm                                         3/3       Running             0          19d
kube-system   kube-dns-79744689dc-ltkrx                                         3/3       Running             0          19d
kube-system   kube-flannel-ds-g5jsm                                             1/1       Running             0          19d
kube-system   kube-flannel-ds-qsrsn                                             1/1       Running             0          19d
```

## Further Customizations

- If you'd like the prompt to show a different format for all clusters (say, without the region shown), just modify the
 `fetch_oci_clusters()` function in oci-fetch-prompt.sh and re-fetch cluster names.
- If you'd like to customize how a single cluster appears in your prompt, you can modify the `~/.oci/clusters/<ocid>`
 for the cluster in question to make it appear however you want.

# Contributions

Pull requests welcome!