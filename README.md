# pkl-docker

Typed Docker Compose models for Pkl. Define services, ports, volumes, and networks as typed values, then render the Compose document directly as YAML.

## NGINX example

```pkl
amends "@docker/src/Compose.pkl"

services {
  ["nginx"] = new Service {
    // renovate: datasource=docker depName=nginx
    image = "nginx:1.27"
    ports = new Listing {
      new Port {
        published = 18080
        target = 80
      }
    }
  }
}
```

The module emits a Compose document with the configured service under the top-level `services` section.

Render that file with:

```sh
pkl eval -o out/nginx.yaml examples/nginx.pkl
```

The generated file is `out/compose.yaml` and looks like:

```yaml
services:
  nginx:
    image: nginx:1.27
    ports:
      - published: 18080
        target: 80
```

This is also the file used by `make integration-test`.

## Service with deployment settings

```pkl
amends "@docker/src/Compose.pkl"

services {
  ["web"] = new Service {
    image = "nginx:1.27"
    ports = new Listing {
      new Port {
        published = 8080
        target = 80
      }
    }
    volumes = new Listing {
      new Volume {
        source = "./data/nginx"
        target = "/usr/share/nginx/html"
        `read_only` = true
      }
    }
    networks = new Listing { "frontend" }
  }
}

networks {
  ["frontend"] = new Network { `external` = true }
}
```

Ports and volumes use Compose’s structured syntax. Volume mounts default to the `bind` type, port values are validated, and a port can omit `published` when it should remain internal to the Compose network. Services can also list `env_file` paths; Compose reads those files at container creation, keeping secret values out of the generated YAML.

For host networking, set `network_mode = "host"` on the service and leave
`networks` empty. Docker Compose does not treat the special host network like a
user-defined external network.

## Validate locally

Render the example with:

```sh
make render-nginx
```

Run the end-to-end NGINX check with Docker available:

```sh
make integration-test
```

That target renders a temporary Compose file, starts Nginx, checks its welcome page, and removes the stack afterward. `make integration-up` leaves it running for inspection, and `make integration-down` removes it.
