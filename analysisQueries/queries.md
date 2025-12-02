100 * sum(rate(istio_requests_total{destination_service="istio-rollout.demo.svc.cluster.local",response_code=~"2.."}[1m])) 
          / sum(rate(istio_requests_total{destination_service="istio-rollout.demo.svc.cluster.local"}[1m]))


100 * sum(rate(istio_requests_total{destination_service="istio-rollout.demo.svc.cluster.local",response_code=~"2..", reporter="destination"}[1m])) 
          / sum(rate(istio_requests_total{destination_service="istio-rollout.demo.svc.cluster.local",reporter="destination"}[1m]))