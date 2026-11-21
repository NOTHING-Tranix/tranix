// B-1407: k6 load test for the two hot polling paths (driver suggestions, shipper/receiver tracking).
// Run against staging only:  k6 run -e BASE=https://staging-api.example/api/v1 -e DRIVER_TOKEN=... -e SHIPPER_TOKEN=... -e LOAD_ID=... tools/loadtest/suggestions-tracking.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    drivers: { executor: 'constant-vus', vus: 200, duration: '5m', exec: 'suggestions' },
    trackers: { executor: 'constant-vus', vus: 300, duration: '5m', exec: 'tracking' },
  },
  thresholds: { http_req_failed: ['rate<0.01'], http_req_duration: ['p(95)<400'] },
};

const BASE = __ENV.BASE;

export function suggestions() {
  const r = http.get(`${BASE}/driver/suggestions?sort=NEAREST`, { headers: { Authorization: `Bearer ${__ENV.DRIVER_TOKEN}` } });
  check(r, { 'suggestions 200': (x) => x.status === 200 });
  sleep(30); // the app polls every 30 s
}

export function tracking() {
  const r = http.get(`${BASE}/loads/${__ENV.LOAD_ID}/tracking`, { headers: { Authorization: `Bearer ${__ENV.SHIPPER_TOKEN}` } });
  check(r, { 'tracking 200': (x) => x.status === 200 });
  sleep(30);
}
