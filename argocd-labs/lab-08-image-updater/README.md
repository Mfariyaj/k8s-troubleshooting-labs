# Lab 08: Image Updater Not Working

## Difficulty: ⭐⭐ Medium

## Scenario
ArgoCD Image Updater is installed and should automatically update container images. However, the annotations on the Application are incorrect, so images are never updated.

## Error Output
```
$ argocd app get image-updater-app
Name:               argocd/image-updater-app
Status:             Synced
Health:             Healthy

$ kubectl logs -n argocd deployment/argocd-image-updater
time="2024-01-15T10:30:00Z" level=info msg="Processing application image-updater-app"
time="2024-01-15T10:30:00Z" level=warning msg="No images configured for application image-updater-app"
time="2024-01-15T10:30:00Z" level=info msg="No image updates required for application image-updater-app"
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check Image Updater logs: `kubectl logs -n argocd deployment/argocd-image-updater`
3. Identify why images are not being updated
4. Fix the annotations on the Application

## Hints
<details>
<summary>Hint 1</summary>
ArgoCD Image Updater uses specific annotations. Check the annotation keys.
</details>

<details>
<summary>Hint 2</summary>
The correct annotation is `argocd-image-updater.argoproj.io/image-list`, not `argocd-image-updater.argoproj.io/images`.
</details>
