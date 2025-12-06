## curling only canary pods : 
while true; do
  curl -H "x-canary: true" \
       -o /dev/null -s -w "%{http_code}\n" \
       http://frontend.localdev.me/
  sleep 1
done


## curling all versions stable and canary : 
while true; do
  curl -o /dev/null -s -w "%{http_code}\n" http://frontend.localdev.me/
  sleep 1

## querying canary only svc : 
# Canary request rate
sum(rate(istio_requests_total{
  destination_service="istio-rollout-canary.demo.svc.cluster.local",
  response_code=~"2..",reporter="destination"
}[1m]))


## qyrying stable svc 

# Canary request rate
sum(rate(istio_requests_total{
  destination_service="istio-rollout-stable.demo.svc.cluster.local",reporter="destination",
  response_code=~"2..",reporter="destination"
}[1m]))


## Success Rate Canary %
sum(rate(istio_requests_total{
    reporter="destination",
    destination_service_name="istio-rollout-canary",
    response_code="200"
}[1m]))
/
sum(rate(istio_requests_total{
    reporter="destination",
    destination_service_name="istio-rollout-canary"
}[1m]))
