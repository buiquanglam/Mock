import http from "k6/http";
import { sleep, check } from "k6";

export let options = {
  VUs: 10,
  duration: "10s",
};

export default function () {
  let res = http.get("http://host.docker.internal:4444/admin/apis.json");
  sleep(5);
  check(res, {
    "is status 200": (r) => r.status === 200,
    "is status 401": (r) => r.status === 401,
    "is status 404": (r) => r.status === 404,
    "is status 500": (r) => r.status === 500,
  });
}
