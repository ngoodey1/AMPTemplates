# NaviPal OSRM AMP Template

This package contains an AMP Generic Module template plus an AMP-compatible
container image definition for OSRM.

## Why a custom image is required

AMP-managed containers must include AMP's expected base environment. The normal
`ghcr.io/project-osrm/osrm-backend` image does not include that environment.
This project therefore builds OSRM on top of `cubecoders/ampbase:debian`.

## Included files

- `Dockerfile` — builds the AMP-compatible OSRM image.
- `.github/workflows/build-image.yml` — publishes the image to GitHub Container Registry.
- `amp-template/navipal-osrm.kvp` — AMP Generic Module definition.
- `amp-template/navipal-osrmconfig.json` — settings shown in AMP.
- `amp-template/navipal-osrmports.json` — TCP port 5000.
- `amp-template/navipal-osrmupdates.json` — downloads and preprocesses the map.

## 1. Create the GitHub repository

Create a repository such as:

    navipal-osrm-amp

Copy this package into the repository and push it to the `main` branch.

GitHub Actions will build:

    ghcr.io/YOUR_GITHUB_USERNAME/navipal-osrm-amp:latest

The initial image build compiles OSRM and can use substantial CPU and storage.

## 2. Make the container package accessible

For the easiest AMP pull, set the GHCR package visibility to Public:

1. Open the package on GitHub.
2. Open Package settings.
3. Change visibility to Public.

A private package requires registry authentication on the AMP host.

## 3. Edit the AMP image name

Open:

    amp-template/navipal-osrm.kvp

Replace:

    ghcr.io/REPLACE_GITHUB_USERNAME/navipal-osrm-amp:latest

with your actual lowercase GitHub owner/package path.

## 4. Add the template repository to AMP

The recommended structure for an AMP configuration repository is to place these
files at the repository root:

    navipal-osrm.kvp
    navipal-osrmconfig.json
    navipal-osrmports.json
    navipal-osrmupdates.json

You can either create a second repository containing those four files at its
root, or copy them to the root of this repository.

In ADS:

1. Open **Configuration → Instance Deployment**.
2. Add your repository under **Configuration Repositories**.
3. Fetch or refresh the templates.
4. Restart ADS if the template does not appear.
5. Create a **NaviPal OSRM** instance.
6. Enable container deployment.

## 5. Configure the map

Before pressing Update, set:

- **OSM PBF Download URL** — direct `.osm.pbf` URL.
- **Dataset Name** — matching local name without the extension.
- **Routing Profile** — normally `Car`.
- **Routing Algorithm** — normally `MLD`.

Example:

    URL: https://download.geofabrik.de/north-america/us/michigan-latest.osm.pbf
    Dataset Name: michigan-latest

Press **Update**. AMP will:

1. Download the PBF when absent.
2. Run `osrm-extract`.
3. Run `osrm-partition` and `osrm-customize` for MLD.
4. Retain the generated `.osrm*` files inside the instance datastore.

Then press **Start**.

## 6. Test the API

From another application that can reach the instance:

    http://AMP_SERVER_IP:5000/route/v1/driving/-83.0458,42.3314;-83.6875,43.0125?overview=false

OSRM coordinates use longitude,latitude order.

## Rebuilding the map

Enable **Force Map Rebuild**, press Update, then disable the setting again.
This deletes the downloaded and processed files before rebuilding.

## Important resource note

Large extracts require substantial temporary disk and memory. Begin with a
single state or similarly sized region rather than the entire United States.

## Security

OSRM has no built-in authentication. Prefer exposing it only to NaviPal or put
it behind a reverse proxy with access controls.
