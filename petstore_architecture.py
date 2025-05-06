from diagrams import Diagram, Cluster
from diagrams.aws.compute import EKS
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.network import Service, Ingress

with Diagram("Pet Store Microservice Architecture on AWS EKS", show=False):
    # External Load Balancer
    lb = ELB("Load Balancer")
    
    # EKS Cluster
    with Cluster("EKS Cluster"):
        eks = EKS("Kubernetes")
        
        # Kubernetes Resources
        with Cluster("Kubernetes Resources"):
            ingress = Ingress("Ingress Controller")
            
            with Cluster("Pet Store Application"):
                svc = Service("Pet Store Service")
                
                with Cluster("Deployments"):
                    pods = [
                        Pod("Pet Store Pod 1"),
                        Pod("Pet Store Pod 2"),
                        Pod("Pet Store Pod 3")
                    ]
                    
                    deploy = Deployment("Pet Store Deployment")
                    deploy >> pods
            
            svc >> pods
    
    # Database
    db = RDS("Pet Database")
    
    # Flow
    lb >> ingress >> svc
    pods >> db
