import { Router } from "express";
import { requireSession } from "../middleware/requireSession.js";

const r = Router();

// GET /cache/recent?limit=10
r.get("/recent", requireSession, async (req, res) => {
  const redis = req.app.locals.redis;

  const researcherId =
    typeof req.user === "string" ? req.user : req.user?.researcherId;

  if (!researcherId)
    return res.status(400).json({ error: "Missing researcherId in session" });

  const limit = Math.min(Number(req.query.limit || 10), 50);
  const key = `recentQueries:${researcherId}`;

  const items = await redis.lRange(key, 0, limit - 1);

  let ttl = await redis.ttl(key);
  // ✅ Redis: -2 means key does not exist, -1 means no expiry
  if (ttl < 0) ttl = 0;

  res.json({ key, ttl, items });
});

export default r;
