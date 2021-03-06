## Update:

* forked by markus - use version 2.2.4 now! (LTS until 2025)
* use newest confd confd-0.16.0-linux-amd64  --> get your architecture using: dpkg --print-architecture
* Note that HAProxy Community is free and used here. The commercial version is [here](https://www.haproxy.com/de/products/community-vs-enterprise-edition/)
* to see how the haproxy.tmpl file generates the final config file see:  docker exec -it 467aeb24d37d cat /usr/local/etc/haproxy/haproxy.cfg
* see also test.cfg

# HAProxy vs ngnix
* HAProxy (High Availability Proxy) is a free, very fast and reliable solution offering high availability, load balancing, and proxying for TCP and HTTP-based applications. On the other hand, nginx is detailed as "A high performance free open source web server powering busiest sites on the Internet".
* HAProxy belongs to "Load Balancer / Reverse Proxy" category of the tech stack, while nginx can be primarily classified under "Web Servers".
* ngnix is way more popular


# easy-lb-haproxy
This repository defines a load balancer container for Docker, based on haproxy, confd and etcd.

## High-level design

The container runs a [haproxy](http://www.haproxy.org/) load balancer process. The configuration is generated by [confd](https://github.com/kelseyhightower/confd) from live data pulled from [etcd](https://github.com/coreos/etcd). Changes made in etcd are automatically reflected in the configuration, making it very convenient for services to add and remove themselves from the system just by interacting with the etcd service.

## Deployment

To deploy a load balancer container, use the following command:

    docker run -p 80:80 -e ETCD_PEERS=http://172.17.0.2:2379 miguelgrinberg/easy-lb-haproxy

The container accepts the following environment variables:

- `ETCD_PEERS`: a comma-separated list of etcd client URLs. (Required, the etcd service must be deployed separately)
- `HAPROXY_STATS`: set to a non-null value to enable the haproxy stats feature. (Optional, disabled by default)
- `HAPROXY_STATS_URI`: if stats are enabled, this is the stats URL. (Optional, defaults to `/stats`)
- `HAPROXY_STATS_AUTH`: if stats are enabled, this sets login credentials to access the stats page. (Optional, auth is disabled by default)

## Building

To build the container image locally, you can use the included `build.sh` script.

## Configuration

The load balancer is automatically configured from the contents of etcd's `/services` directory. For example, consider the following `etcdctl` commands:

    etcdctl set /services/foo/upstream/server1 172.17.0.4:5000
    etcdctl set /services/foo/upstream/server2 172.17.0.5:5000
    etcdctl set /services/bar/upstream/server3 172.17.0.6:5000

This will cause the load balancer to forward requests to URLs that start with `/foo` to server1 and server2 at the addresses and ports specified, and any requests that start with `/bar` to server3. Note that the names `server{1,2,3}` are not significant, each service can register itself with any name, as long as it is unique.

To use a URL prefix different than the service name, set a `location` key. For example, the following command will make the load balancer send requests with URLs that start with `/api/foo` to the `foo` service:

    etcdctl set /services/foo/location /api/foo

To set a service as the default, simply set its location to the root URL:

    etcdctl set /services/foo/location /

By default, each backend is configured for round robin load balancing. To use custom backend options, add the desired options under a `backend` key. For example, to set the `source` load balancing algorithm, write the following key:

    etcdctl set /services/foo/backend/balance source

Whenever changes are made in etcd to the `/services` subtree, those changes will automatically trigger a configuration update.
