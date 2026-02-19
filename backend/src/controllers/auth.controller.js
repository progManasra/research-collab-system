import crypto from "crypto";
import Researcher from "../models/researcher.model.js";

// ✅ خلي الافتراضي 10 دقائق بدل 60 ثانية
const TTL_SECONDS = Number(process.env.SESSION_TTL_SECONDS || 600);

export async function login(req, res) {
  const { researcherId, password } = req.body || {};
  if (!researcherId) return res.status(400).json({ error: "researcherId is required" });

  // Prototype: تأكد الباحث موجود
  const r = await Researcher.findById(researcherId);
  if (!r) return res.status(401).json({ error: "Invalid researcherId" });

  // Prototype password
  if (password && password !== "1234") {
    return res.status(401).json({ error: "Invalid password" });
  }

  const redis = req.app.locals.redis;

  const sessionId = crypto.randomBytes(24).toString("hex");

  // ✅ session stored as STRING: session:<id> = researcherId
  await redis.setEx(`session:${sessionId}`, TTL_SECONDS, researcherId);

  res.json({ ok: true, sessionId, expiresInSec: TTL_SECONDS, researcherId });
}

export async function logout(req, res) {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7).trim() : null;
  if (!token) return res.json({ ok: true });

  const redis = req.app.locals.redis;
  await redis.del(`session:${token}`);
  res.json({ ok: true });
}

export async function me(req, res) {
  res.json({ ok: true, user: req.user });
}
