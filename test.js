const response = await fetch(
  "http://localhost:3002/mock/56fd97ce-1d19-4946-b4b5-42a0234dde5a/user/:id",
  {
    method: "POST",
    headers: {
      Authorization:
        "Bearer am_live_TNfDRK-wprWIc6h3KYdZixlyOhU2SIN2vtEjGnZQLog",
    },
    body: JSON.stringify({
      name: "t",
    }),
  },
);

console.log("Status:", response.status);
console.log("Body:", await response.json());
