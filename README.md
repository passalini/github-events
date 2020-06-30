# Github events
Project to save and filter github events using webhooks

# To do:
- [ ] GET /events: should filter events from an issue
- [x] /webhooks: index from configured webhooks
- [x] Authorization by login and password

def verify_signature(payload_body, secret)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
  Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end
