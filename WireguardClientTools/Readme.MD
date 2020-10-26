### Requirement
1. [addon-wireguard](https://github.com/hassio-addons/addon-wireguard)

### Usage
1. Install add-on
2. Setting Configuration

### Configuration

#### Wireguard

1. Setting Wireguard peers as client

```
...
peers:
...
  - name: CHOSE_A_NAME
    endpoint: 'ENDPOINT ADDRESS'
    public_key: PUBLIC KEY
    addresses:
      - 10.99.97.1
    allowed_ips:
      - 10.99.97.1/32
      - 192.168.3.0/24
    client_allowed_ips: []
...
```

#### Wireguard Client Tools

1. The IP Range that you want to access via wireguard tunnle as wireguard client.

```
destination_ip:
  - 192.168.3.0/24
```

2. addon-wireguard enstablished port. Default: 51820

```
wireguard_port: 51820
```
