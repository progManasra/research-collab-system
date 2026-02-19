import Publication from "../models/publication.model.js";
import neo4j from "neo4j-driver";

function asJsNumber(v) {
  // v ممكن يكون number عادي
  if (typeof v === "number") return v;

  // v ممكن يكون Neo4j Integer
  if (neo4j.isInt(v)) return v.toNumber();

  // fallback
  return Number(v);
}

export async function topResearchersByPublications(req, res) {
  const top = await Publication.aggregate([
    { $unwind: "$authorIds" },
    { $group: { _id: "$authorIds", pubCount: { $sum: 1 } } },
    { $sort: { pubCount: -1 } },
    { $limit: 5 }
  ]);

  res.json(top.map(x => ({ researcherId: x._id, publications: x.pubCount })));
}

export async function mostCollaborativePair(req, res) {
  const driver = req.app.locals.neo4j;
  const session = driver.session();

  try {
    const result = await session.run(`
      MATCH (a:Researcher)-[r:CO_AUTHOR]->(b:Researcher)
      RETURN a.id AS A, b.id AS B, r.count AS collaborations
      ORDER BY collaborations DESC
      LIMIT 1
    `);

    const row = result.records[0];
    if (!row) return res.json(null);

    const collaborationsVal = row.get("collaborations");

    res.json({
      researcherA: row.get("A"),
      researcherB: row.get("B"),
      collaborations: asJsNumber(collaborationsVal)
    });
  } finally {
    await session.close();
  }
}
