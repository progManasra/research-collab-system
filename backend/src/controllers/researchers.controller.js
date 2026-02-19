import Researcher from "../models/researcher.model.js";
import Project from "../models/project.model.js";
import Publication from "../models/publication.model.js";
import neo4j from "neo4j-driver";

function asJsNumber(v) {
  if (typeof v === "number") return v;
  if (neo4j.isInt(v)) return v.toNumber();
  return Number(v);
}

export async function createResearcher(req, res) {
  const doc = await Researcher.create(req.body);
  res.status(201).json(doc);
}

export async function listResearchers(req, res) {
  const { department, interest } = req.query;
  const filter = {};
  if (department) filter.department = department;
  if (interest) filter.interests = interest;

  const docs = await Researcher.find(filter).lean();
  res.json(docs);
}

export async function getResearcher(req, res) {
  const doc = await Researcher.findById(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Researcher not found" });
  res.json(doc);
}

export async function updateResearcher(req, res) {
  const doc = await Researcher.findByIdAndUpdate(req.params.id, req.body, { new: true }).lean();
  if (!doc) return res.status(404).json({ error: "Researcher not found" });
  res.json(doc);
}

export async function deleteResearcher(req, res) {
  const doc = await Researcher.findByIdAndDelete(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Researcher not found" });
  res.json({ ok: true });
}
export async function getIntegratedProfile(req, res) {
  const profileId = req.params.id;

  const redis = req.app.locals.redis;
  const neo4jDriver = req.app.locals.neo4j;

  // ✅ session owner (who is logged in)
  const sessionOwnerId =
    typeof req.user === "string" ? req.user : req.user?.researcherId;

  // لو ما في سيشن (حسب مشروعك ممكن تكون حامي الراوت أو لا)
  const ownerId = sessionOwnerId || profileId;

  // ✅ unified keys
  const cacheKey = `cache:profile:${profileId}`;
  const recentKey = `recentQueries:${ownerId}`;

  // helper: push recent query + ensure TTL موجود دائمًا
  async function pushRecent() {
    await redis.lPush(recentKey, `profile-integrated ${profileId}`);
    await redis.lTrim(recentKey, 0, 9);
    await redis.expire(recentKey, 300); // 5 minutes TTL for the list
  }

  // 1) Try cache
  const cached = await redis.get(cacheKey);
  if (cached) {
    await pushRecent();
    const payload = JSON.parse(cached);
    payload.recentQueries = await redis.lRange(recentKey, 0, 4);
    return res.json(payload);
  }

  // 2) Mongo reads
  const researcher = await Researcher.findById(profileId).lean();
  if (!researcher) return res.status(404).json({ error: "Researcher not found" });

  const projects = await Project.find({ "participants.researcherId": profileId }).lean();
  const publications = await Publication.find({ authorIds: profileId }).lean();

  // 3) Neo4j: collaborators
  const session = neo4jDriver.session();
  let collaborators = [];
  try {
    const result = await session.run(
      `
      MATCH (a:Researcher {id:$id})-[r:CO_AUTHOR]-(b:Researcher)
      WITH b.id AS collaboratorId, max(r.count) AS times
      RETURN collaboratorId, times
      ORDER BY times DESC
      `,
      { id: profileId }
    );

    collaborators = result.records.map((rec) => ({
      collaboratorId: rec.get("collaboratorId"),
      times: asJsNumber(rec.get("times")),
    }));
  } finally {
    await session.close();
  }

  // 4) Redis recent queries
  await pushRecent();
  const recentQueries = await redis.lRange(recentKey, 0, 4);

  const payload = {
    researcher,
    projects,
    publications,
    collaborators,
    recentQueries,
  };

  // 5) Cache integrated response (TTL 60 seconds)
  await redis.setEx(cacheKey, 60, JSON.stringify(payload));

  res.json(payload);
}
