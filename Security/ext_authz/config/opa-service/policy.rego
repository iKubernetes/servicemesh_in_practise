package envoy.authz
  
import input.attributes.request.http as http_request

default allow = false

response := {
  "allowed": true,
  "headers": {"x-current-user": "OPA"}
}

allow = response {
  http_request.method == "GET"
}

allow = response {
  http_request.method == "POST"
  glob.match("/livez", ["/"], http_request.path)
}
