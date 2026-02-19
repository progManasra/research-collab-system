import express from "express";
import cors from "cors";
import { connectMongo } from "./config/mongo.js";
import { createNeo4jDriver } from "./config/neo4j.js";
import { createRedisClient } from "./config/redis.js";
import researchersRoutes from "./routes/researchers.routes.js";
import projectsRoutes from "./routes/projects.routes.js";
import publicationsRoutes from "./routes/publications.routes.js";
import analyticsRoutes from "./routes/analytics.routes.js";
import graphRoutes from "./routes/graph.routes.js";
import authRoutes from "./routes/auth.routes.js";
import cacheRoutes from "./routes/cache.routes.js";



const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

async function bootstrap() {
  await connectMongo(process.env.MONGO_URI);

  const neo4jDriver = createNeo4jDriver(
    process.env.NEO4J_URI,
    process.env.NEO4J_USER,
    process.env.NEO4J_PASS
  );

  const redisClient = await createRedisClient(
    process.env.REDIS_HOST,
    process.env.REDIS_PORT
  );

  app.locals.neo4j = neo4jDriver;
  app.locals.redis = redisClient;

  app.get("/health", (req, res) => {
    res.json({ ok: true, service: "backend", time: new Date().toISOString() });
  });
app.use("/researchers", researchersRoutes);
app.use("/projects", projectsRoutes);
app.use("/publications", publicationsRoutes);

app.use("/analytics", analyticsRoutes);
app.use("/graph", graphRoutes);
app.use("/auth", authRoutes);
app.use("/cache", cacheRoutes);


  app.listen(PORT, () => console.log(`API running on :${PORT}`));
}

bootstrap().catch((err) => {
  console.error("Bootstrap failed:", err);
  process.exit(1);
});
