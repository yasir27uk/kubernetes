#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf

# Deploy metallb load balancer
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
# kubectl get ns
# sleep 5
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
# function CountRunningMetallb {
# 	kubectl get all -n metallb-system | grep -c Running
# }
# RunningMetallb=$(CountRunningMetallb)
# kubectl create configmap config --from-file=/root/configmap
# kubectl describe configmap config

# If not using ingress-nginx
# kubectl expose deploy nginx --port 80 --type LoadBalancer

# Deploy ingress-nginx
kubectl create ns ingress-nginx
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version --short
echo ''
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
echo ''
helm repo add metallb https://metallb.github.io/metallb
echo ''
helm repo update
echo ''
helm repo list
echo ''
helm install metallb metallb/metallb -f values.yaml
echo ''

function CheckStatus1 {
	kubectl get all -n metallb-system | grep -c Running
}
RunningMetallb=$(CountRunningMetallb)

while [ $Status1 -lt 4 ]
do
	Status1=$(CheckStatus1)
	sleep 5
done

helm search repo ingress
echo ''
helm install orabuntu-lxd ingress-nginx/ingress-nginx -n ingress-nginx --values /root/ingress-nginx.yaml
echo ''

function CheckStatus2 {
	kubectl -n ingress-nginx get all | grep -c Running
}
Status2=$(CheckStatus2)

while [ $Status2 -lt 2 ]
do
	Status2=$(CheckStatus2)
	sleep 5
done

helm list -n ingress-nginx
echo ''
kubectl -n ingress-nginx get all
echo ''
# sudo iptables -t nat -A PREROUTING -p tcp -i enp0s17 --dport 80 -j DNAT --to-destination 10.209.53.240:80

