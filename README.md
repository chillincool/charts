# Charts

A Helm chart repository with CI/CD automation linked to container releases.

## Usage

[Helm](https://helm.sh) must be installed to use these charts.
Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add chrismsykes https://chrismsykes.github.io/charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.

To search for available charts:

```bash
helm search repo chrismsykes
```

To install a chart:

```bash
helm install my-release chrismsykes/<chart-name>
```

To uninstall the chart:

```bash
helm delete my-release
```

## Charts

### Common Library Chart

The `common` chart is a library chart containing shared templates and helpers that other charts can use as a dependency. This keeps things DRY (Don't Repeat Yourself) by providing reusable templates for:

- Labels and selectors
- Deployments
- Services
- Ingress
- ServiceAccounts
- ConfigMaps
- Secrets
- HorizontalPodAutoscalers

#### Using the Common Library

To use the common library in your chart, add it as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: "1.x.x"
    repository: "https://chrismsykes.github.io/charts"
```

Then use the templates in your chart:

```yaml
# templates/deployment.yaml
{{- include "common.deployment" . }}

# templates/service.yaml
{{- include "common.service" . }}
```

## CI/CD Integration

This repository includes GitHub Actions workflows for:

1. **Linting and Testing** (`lint-test.yml`) - Runs on pull requests to validate charts
2. **Release** (`release.yml`) - Publishes charts to GitHub Pages on push to main
3. **Container Updates** (`update-chart.yml`) - Updates chart versions when new container images are released

### Linking to Your Containers Repo

To automatically update charts when new container images are released, add the following workflow to your containers repository:

```yaml
name: Trigger Chart Update

on:
  push:
    tags:
      - 'v*'

jobs:
  trigger-chart-update:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger chart update
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.CHARTS_REPO_TOKEN }}
          repository: chrismsykes/charts
          event-type: container-release
          client-payload: '{"chart_name": "your-chart-name", "image_tag": "${{ github.ref_name }}"}'
```

Note: You'll need to create a Personal Access Token (PAT) with `repo` scope and add it as a secret named `CHARTS_REPO_TOKEN` in your containers repository.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.