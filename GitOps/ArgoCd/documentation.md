# Argo Cd 
Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes

The Core Concept: GitOps 
+ To understand Argo CD, you must understand GitOps.
Traditional CD (Push): Your CI server (like Jenkins) builds code, logs into your Kubernetes cluster, and runs kubectl apply. The CI server holds the power.
+ GitOps (Pull): You commit code/configuration to Git. Argo CD (running inside Kubernetes) watches that Git repository. When it sees a change, it pulls the changes and applies them to the cluster.

Why Argo CD?
Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

Why Should You Use It
+ Single Source of Truth: You never manually run kubectl edit on a production cluster. Everything is defined in Git. If the cluster dies, you can rebuild it exactly as it was just by pointing Argo CD at the repo.
+ Drift Detection & Auto-Healing: If someone manually changes a configuration in the cluster (causing "drift"), Argo CD detects that the live state differs from Git. It can automatically revert the change to match Git.
+ Easy Rollbacks: Did a deployment break the app? Don't panic. Simply revert the Git commit. Argo CD sees the revert and rolls back the application automatically.
+ Security: Your CI pipeline (GitHub Actions, Jenkins) does not need access to your Kubernetes cluster credentials. It only needs permission to push to Git. Argo CD holds the cluster credentials, reducing the attack surface.
+ Visual Dashboard: Argo CD provides a beautiful UI that shows the health status of every resource, making debugging much easier than staring at CLI logs.