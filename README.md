# Lidarr

Lidarr music management on FreeBSD.

| | |
|---|---|
| **Port** | 8686 |
| **Registry** | `ghcr.io/daemonless/lidarr` |
| **Source** | [https://github.com/Lidarr/Lidarr](https://github.com/Lidarr/Lidarr) |
| **Website** | [https://lidarr.audio/](https://lidarr.audio/) |

## Deployment

### Podman Compose

```yaml
services:
  lidarr:
    image: ghcr.io/daemonless/lidarr:latest
    container_name: lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    volumes:
      - /path/to/containers/lidarr:/config
      - /path/to/music:/music # optional
      - /path/to/downloads:/downloads # optional
    ports:
      - 8686:8686
    annotations:
      org.freebsd.jail.allow.mlock: "true"
    restart: unless-stopped
```

### Podman CLI

```bash
podman run -d --name lidarr \
  -p 8686:8686 \
  --annotation 'org.freebsd.jail.allow.mlock=true' \
  -e PUID=@PUID@ \
  -e PGID=@PGID@ \
  -e TZ=@TZ@ \
  -v /path/to/containers/lidarr:/config \ 
  -v /path/to/music:/music \  # optional
  -v /path/to/downloads:/downloads \  # optional
  ghcr.io/daemonless/lidarr:latest
```
Access at: `http://localhost:8686`

### Ansible

```yaml
- name: Deploy lidarr
  containers.podman.podman_container:
    name: lidarr
    image: ghcr.io/daemonless/lidarr:latest
    state: started
    restart_policy: always
    env:
      PUID: "1000"
      PGID: "1000"
      TZ: "UTC"
    ports:
      - "8686:8686"
    volumes:
      - "/path/to/containers/lidarr:/config"
      - "/path/to/music:/music" # optional
      - "/path/to/downloads:/downloads" # optional
    annotation:
      org.freebsd.jail.allow.mlock: "true"
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for the application process |
| `PGID` | `1000` | Group ID for the application process |
| `TZ` | `UTC` | Timezone for the container |

### Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration directory |
| `/music` | Music library (Optional) |
| `/downloads` | Download directory (Optional) |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `8686` | TCP | Web UI |

## Notes

- **User:** `bsd` (UID/GID set via PUID/PGID)
- **Base:** Built on `ghcr.io/daemonless/base` (FreeBSD)
- **.NET App:** Requires `--annotation 'org.freebsd.jail.allow.mlock=true'` and a [patched ocijail](https://daemonless.io/guides/ocijail-patch).