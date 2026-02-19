import neo4j from "neo4j-driver";

function asJsNumber(v) {
  if (typeof v === "number") return v;
  if (neo4j.isInt(v)) return v.toNumber();
  return Number(v);
}

export async function getNeighborhoodGraph(req, res) {
  const id = req.params.id;
  const depth = Number(req.query.depth ?? 1);
  const useDepth2 = depth >= 2;

  const driver = req.app.locals.neo4j;
  const session = driver.session();

  try {
    // Cypher must use literal range, not parameter, so we switch between two queries
    const cypherDepth1 = `
      MATCH p=(a:Researcher {id:$id})-[rel:CO_AUTHOR|SUPERVISES*1..1]-(b:Researcher)
      UNWIND relationships(p) AS r
      WITH DISTINCT r
      MATCH (s:Researcher)-[r]->(t:Researcher)
      RETURN s.id AS from, s.name AS fromName,
             t.id AS to,   t.name AS toName,
             type(r) AS type,
             coalesce(r.count, 1) AS weight
    `;

    const cypherDepth2 = `
      MATCH p=(a:Researcher {id:$id})-[rel:CO_AUTHOR|SUPERVISES*1..2]-(b:Researcher)
      UNWIND relationships(p) AS r
      WITH DISTINCT r
      MATCH (s:Researcher)-[r]->(t:Researcher)
      RETURN s.id AS from, s.name AS fromName,
             t.id AS to,   t.name AS toName,
             type(r) AS type,
             coalesce(r.count, 1) AS weight
    `;

    const result = await session.run(useDepth2 ? cypherDepth2 : cypherDepth1, { id });

    const nodesMap = new Map();
    const edges = [];

    for (const rec of result.records) {
      const from = rec.get("from");
      const to = rec.get("to");
      const fromName = rec.get("fromName");
      const toName = rec.get("toName");
      const type = rec.get("type");
      const weight = asJsNumber(rec.get("weight"));

      nodesMap.set(from, { id: from, label: `${fromName} (${from})` });
      nodesMap.set(to, { id: to, label: `${toName} (${to})` });

      edges.push({
        from,
        to,
        label: type === "CO_AUTHOR" ? `CO_AUTHOR (${weight})` : "SUPERVISES",
        weight,
      });
    }

    // Ensure base node exists even if no edges
    if (!nodesMap.has(id)) {
      const r0 = await session.run(
        `MATCH (a:Researcher {id:$id}) RETURN a.id AS id, a.name AS name`,
        { id }
      );
      if (r0.records.length) {
        nodesMap.set(id, {
          id,
          label: `${r0.records[0].get("name")} (${id})`,
        });
      }
    }

    res.json({
      id,
      depth: useDepth2 ? 2 : 1,
      nodes: Array.from(nodesMap.values()),
      edges,
    });
  } finally {
    await session.close();
  }
}

export async function upsertResearcherNode(req, res) {
  const { id, name, department } = req.body;
  if (!id || !name) return res.status(400).json({ error: "id and name are required" });

  const driver = req.app.locals.neo4j;
  const session = driver.session();
  try {
    await session.run(
      `
      MERGE (r:Researcher {id:$id})
      SET r.name=$name, r.department=coalesce($department, r.department)
      `,
      { id, name, department: department ?? null }
    );
    res.json({ ok: true });
  } finally {
    await session.close();
  }
}

export async function addCoauthor(req, res) {
  const { a, b, count } = req.body;
  if (!a || !b) return res.status(400).json({ error: "a and b are required" });

  const c = Number(count ?? 1);

  const driver = req.app.locals.neo4j;
  const session = driver.session();
  try {
    // symmetric edges
    await session.run(
      `
      MATCH (x:Researcher {id:$a}), (y:Researcher {id:$b})
      MERGE (x)-[r:CO_AUTHOR]->(y)
      SET r.count = coalesce(r.count, 0) + $c
      `,
      { a, b, c }
    );

    await session.run(
      `
      MATCH (x:Researcher {id:$a}), (y:Researcher {id:$b})
      MERGE (y)-[r:CO_AUTHOR]->(x)
      SET r.count = coalesce(r.count, 0) + $c
      `,
      { a, b, c }
    );

    res.json({ ok: true });
  } finally {
    await session.close();
  }
}

export async function addSupervises(req, res) {
  const { supervisor, student } = req.body;
  if (!supervisor || !student) {
    return res.status(400).json({ error: "supervisor and student are required" });
  }

  const driver = req.app.locals.neo4j;
  const session = driver.session();
  try {
    await session.run(
      `
      MATCH (s:Researcher {id:$supervisor}), (t:Researcher {id:$student})
      MERGE (s)-[:SUPERVISES]->(t)
      `,
      { supervisor, student }
    );
    res.json({ ok: true });
  } finally {
    await session.close();
  }
}

// ✅ NEW: delete CO_AUTHOR both directions (because you created symmetric edges)
export async function deleteCoauthor(req, res) {
  const { a, b } = req.query;
  if (!a || !b) return res.status(400).json({ error: "a and b are required" });

  const driver = req.app.locals.neo4j;
  const session = driver.session();
  try {
    await session.run(
      `
      MATCH (x:Researcher {id:$a})-[r:CO_AUTHOR]->(y:Researcher {id:$b})
      DELETE r
      `,
      { a, b }
    );

    await session.run(
      `
      MATCH (x:Researcher {id:$b})-[r:CO_AUTHOR]->(y:Researcher {id:$a})
      DELETE r
      `,
      { a, b }
    );

    res.json({ ok: true });
  } finally {
    await session.close();
  }
}

// ✅ NEW: delete SUPERVISES
export async function deleteSupervises(req, res) {
  const { supervisor, student } = req.query;
  if (!supervisor || !student) {
    return res.status(400).json({ error: "supervisor and student are required" });
  }

  const driver = req.app.locals.neo4j;
  const session = driver.session();
  try {
    await session.run(
      `
      MATCH (s:Researcher {id:$supervisor})-[r:SUPERVISES]->(t:Researcher {id:$student})
      DELETE r
      `,
      { supervisor, student }
    );

    res.json({ ok: true });
  } finally {
    await session.close();
  }
}
