export async function requireSession(req, res, next) {
  try {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7).trim() : null;

    if (!token) return res.status(401).json({ error: "Session expired or invalid" });

    const redis = req.app.locals.redis;

    // session:<token> => researcherId
    const researcherId = await redis.get(`session:${token}`);

    if (!researcherId) return res.status(401).json({ error: "Session expired or invalid" });

    // ✅ خليها object ثابت
    req.user = { researcherId };

    return next();
  } catch (e) {
    return res.status(401).json({ error: "Session expired or invalid" });
  }
}
