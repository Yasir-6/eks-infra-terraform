kubernetes_version     = "1.33"

# EKS Endpoint Access Configuration
endpoint_public_access  = true
endpoint_private_access = true
public_access_cidrs     = ["0.0.0.0/0"]  # Change to your specific IP ranges for security

# Subnet Configuration
use_private_subnets = true  # true = private subnets (recommended), false = public subnets
cluster_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
log_retention_days     = 7
node_instance_types    = ["t2.medium"]
capacity_type          = "ON_DEMAND"
ami_type               = "AL2023_x86_64_STANDARD"
disk_size              = 50
desired_size           = 1
max_size               = 2
min_size               = 1
vpc_cni_version        = null
coredns_version        = null
kube_proxy_version     = null
ebs_csi_version        = null
efs_csi_version        = null
enable_guardduty_agent = false
enable_adot            = false
