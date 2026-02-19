import { createClient } from "redis";

export async function createRedisClient(host, port) {
  const client = createClient({ url: `redis://${host}:${port}` });
  client.on("error", (e) => console.error("Redis error:", e));
  await client.connect();
  console.log("Redis connected");
  return client;
}
