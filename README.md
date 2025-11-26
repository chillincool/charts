# Charts

A Helm chart repository with CI/CD automation linked to container releases.

## Usage

[Helm](https://helm.sh) must be installed to use these charts.
Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add chillincool https://chillincool.github.io/charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.

To search for available charts:

```bash
helm search repo chillincool
```

To install a chart:

```bash
helm install my-release chillincool/<chart-name>
```

To uninstall the chart:

```bash
helm delete my-release
```

## Charts

This repository includes the following Helm charts:

### Application Charts

#### Sonarr
Smart PVR for newsgroup and bittorrent users - TV series management and automation.

```bash
helm install my-sonarr chillincool/sonarr
```

#### Radarr
A movie collection manager for Usenet and BitTorrent users - automated movie downloading and management.

```bash
helm install my-radarr chillincool/radarr
```

#### Lidarr
A music collection manager for Usenet and BitTorrent users - automated music downloading and management.

```bash
helm install my-lidarr chillincool/lidarr
```

#### Prowlarr
An indexer manager/proxy for Usenet and BitTorrent - manages indexers for the *arr suite.

```bash
helm install my-prowlarr chillincool/prowlarr
```

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
    repository: "https://chillincool.github.io/charts"
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

### Linking to Container Package Releases

Container images are published as GitHub Container Registry (GHCR) packages under the [chillincool organization](https://github.com/orgs/chillincool/packages). The [chillincool/containers](https://github.com/chillincool/containers) repository provides the build infrastructure that publishes these packages.

To keep charts synchronized with container package updates, you have two options:

#### Option 1: Trigger from Container Build Workflow

Add the following step to your container build workflow (e.g., in the `containers` repository CI, after successful image push):

```yaml
- name: Trigger chart update
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.CHARTS_REPO_TOKEN }}
    repository: chillincool/charts
    event-type: container-release
    client-payload: '{"chart_name": "your-app-name", "image_tag": "${{ github.sha }}"}'
```

#### Option 2: Trigger from Package Publication Events

Create a workflow in a repository with access to organization packages that triggers on package publication:

```yaml
name: Trigger Chart Update on Package Release

on:
  registry_package:
    types: [published]

jobs:
  trigger-chart-update:
    runs-on: ubuntu-latest
    steps:
      - name: Extract package info
        id: package
        run: |
          echo "name=${{ github.event.registry_package.name }}" >> $GITHUB_OUTPUT
          # The version field structure varies - use package_version.version or package_version.name
          # Adjust based on your actual package structure
          VERSION="${{ github.event.registry_package.package_version.version }}"
          if [ -z "$VERSION" ]; then
            VERSION="${{ github.event.registry_package.package_version.name }}"
          fi
          echo "version=$VERSION" >> $GITHUB_OUTPUT
      
      - name: Trigger chart update
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.CHARTS_REPO_TOKEN }}
          repository: chillincool/charts
          event-type: container-release
          client-payload: '{"chart_name": "${{ steps.package.outputs.name }}", "image_tag": "${{ steps.package.outputs.version }}"}'
```

**Note:** The `registry_package` event structure may vary depending on your package configuration. You may need to adjust the extraction logic to match your package metadata and tagging convention. The example above uses `package_version.name` which typically contains the version/tag for container packages.

**Note:** You'll need to create a Personal Access Token (PAT) with `repo` scope and add it as a secret named `CHARTS_REPO_TOKEN` in the repository where you add this workflow.

Alternatively, you can manually trigger chart updates using the workflow dispatch in this repository's `update-chart.yml` workflow.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.