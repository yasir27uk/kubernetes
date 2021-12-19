#!/bin/bash

ContainerRuntime=$1

echo ''
echo "=============================================="
echo "Install Kubernetes ...                        "
echo "=============================================="
echo ''

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo ''
echo "=============================================="
echo "Done: Install Kubernetes .                    "
echo "=============================================="
echo ''

sleep 5

clear

if   [ $ContainerRuntime = 'crio' ]
then
	echo ''
	echo "=============================================="
	echo "Enable and start cri-o ...                    "
	echo "=============================================="
	echo ''

        ln -s /usr/bin/fuse-overlayfs /usr/local/bin/fuse-overlayfs
        cp -p /root/crio.conf /etc/crio/crio.conf
        systemctl daemon-reload
        systemctl enable crio --now
	service crio start

	sh -c "echo 'KUBELET_EXTRA_ARGS=--container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint=\"unix:///var/run/crio/crio.sock\"' > /etc/sysconfig/kubelet"
	
	echo ''
	echo "=============================================="
	echo "Done: Enable and start cri-o.                 "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Install podman, skopeo, buildah...            "
	echo "=============================================="
	echo ''

	dnf -y install podman skopeo buildah
	sed -i "/fuse-overlayfs/s/#mount_program/mount_program/g" /etc/containers/storage.conf

	echo ''
	echo "=============================================="
	echo "Done: Install podman, skopeo, buildah.        "
	echo "=============================================="
	echo ''

	sleep 5

	clear

elif [ $ContainerRuntime = 'containerd' ]
then
	echo ''
	echo "=============================================="
	echo "Enable and start containerd ...               "
	echo "=============================================="
	echo ''

        systemctl daemon-reload
        systemctl enable containerd --now
	service containerd start

	sh -c "echo 'KUBELET_EXTRA_ARGS=--container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint=\"unix:///run/containerd/containerd.sock\"' > /etc/sysconfig/kubelet"
	
	echo ''
	echo "=============================================="
	echo "Done: Enable and start containerd.            "
	echo "=============================================="
	echo ''

elif [ $ContainerRuntime = 'docker' ]
then
        echo ''
        echo "=============================================="
        echo "Enable and start Docker ...                   "
        echo "=============================================="
        echo ''

        systemctl daemon-reload
        systemctl enable docker --now
	service docker start

        echo ''
        echo "=============================================="
        echo "Done: Enable and start Docker ...             "
        echo "=============================================="
        echo ''

        sleep 5

        clear
fi

echo ''
echo "=============================================="
echo "Enable kubelet service...                     "
echo "=============================================="
echo ''

systemctl enable kubelet

echo ''
echo "=============================================="
echo "Done: Enable kubelet service.                 "
echo "=============================================="
echo ''

sleep 5

clear


