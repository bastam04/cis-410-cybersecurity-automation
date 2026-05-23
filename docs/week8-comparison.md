# Week 8 Comparison: On-Premise Docker vs. Cloud Run

| Dimension | On-Premise Docker (Wks 3–5) | Cloud Run (Week 8) |
|---|---|---|
| Infrastructure setup | 3 VMs created, Docker installed on each | No VM setup needed. Cloud Run manages the server infrastructure. |
| Deployment command | SSH → docker build → docker run | GitHub Actions builds, pushes, and deploys with gcloud run deploy. |
| TLS / HTTPS | Not configured | HTTPS is automatically provided through the run.app URL. |
| Scaling approach | Manual — redeploy or add VMs | Automatic scaling, including scale-to-zero when idle. |
| Port management | Ports 5000/5001/5002 per environment | No manual public port setup. Cloud Run routes traffic to container port 5000. |
| Cost when idle | VM running 24/7 regardless of traffic | Cloud Run can scale to zero when there is no traffic. |
| Rollback | Re-deploy previous image manually | Cloud Run revisions allow returning to a previous deployment. |
| Secrets management | GitHub Secrets → env vars in workflow | OIDC replaces long-lived SSH keys. Deployment uses short-lived identity tokens. |

## Reflection Questions

### Q1
The on-premise approach required more manual steps because I had to SSH into a VM, build the Docker image, run the container, and manage the server directly. Cloud Run removed the need to manage VMs, configure ports, manually restart containers, or keep Docker running on a server.

### Q2
For on-premise Docker, I would check the running container or image tag manually on the VM. With Cloud Run, the image uses a commit SHA tag.

### Q3
Scale-to-zero reduces security exposure because the application is not constantly running when there is no traffic.

### Q4
OIDC removed the need for ssh private keys in github secrets.
