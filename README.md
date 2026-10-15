# pkl-docker

Typed Docker Compose models for Pkl. Define services, ports, volumes, and networks as typed values, then render the Compose document directly as YAML.

## Minimal service

```pkl
amends "@docker/src/Compose.pkl"

services {
  ["example"] = new Service {
    image = "nginx:1.27"
  }
}
```

The module emits a Compose document with the configured service under the top-level `services` section.

Render that file with:

```sh
pkl eval -o out/compose.yaml examples/compose.pkl
```

The generated file is `out/compose.yaml` and looks like:

```yaml
services:
  example:
    image: nginx:1.27
```

The integration example in `examples/nginx.pkl` adds a published port on `18080` and is the file used by `make integration-test`.

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

Ports and volumes use Compose’s structured syntax. Port values are validated, and a port can omit `published` when it should remain internal to the Compose network.

## Validate locally

Render the basic example with:

```sh
make render
```

Run the end-to-end Nginx check with Docker available:

```sh
make integration-test
```

That target renders a temporary Compose file, starts Nginx, checks its welcome page, and removes the stack afterward. `make integration-up` leaves it running for inspection, and `make integration-down` removes it.
