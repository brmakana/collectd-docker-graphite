# collectd-docker-graphite
A dockerized collectd that will report to graphite. 

Will retrieve the address for graphite from:
- the GRAPHITE_HOST environment variable, or if not set
- the /services/graphiteweb etcd key