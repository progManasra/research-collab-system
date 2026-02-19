import neo4j from "neo4j-driver";

async function run() {
  const uri = process.env.NEO4J_URI || "bolt://localhost:7687";
  const user = process.env.NEO4J_USER || "neo4j";
  const pass = process.env.NEO4J_PASS || "password123";

  const driver = neo4j.driver(uri, neo4j.auth.basic(user, pass));
  const session = driver.session();

  try {
    // Reset graph
    await session.run(`MATCH (n) DETACH DELETE n`);

    // Create Researcher nodes
    const researchers = [
      { id: "R1001", name: "Lina Ahmad", department: "CS" },
      { id: "R1002", name: "Omar Saleh", department: "CS" },
      { id: "R1003", name: "Sara Nasser", department: "Business" },
      { id: "R1004", name: "Maha Youssef", department: "Engineering" },
      { id: "R1005", name: "Yazan Khatib", department: "CS" },
      { id: "R1006", name: "Huda Karim", department: "Business" },
      { id: "R1007", name: "Ali Hamdan", department: "Engineering" },
      { id: "R1008", name: "Nour Zaid", department: "CS" },
      { id: "R1009", name: "Dina Farah", department: "Business" },
      { id: "R1010", name: "Khaled Saad", department: "Engineering" }
    ];

    for (const r of researchers) {
      await session.run(
        `CREATE (:Researcher {id:$id, name:$name, department:$department})`,
        r
      );
    }

    // CO_AUTHOR relations (with counts)
    const coauthor = [
      ["R1001", "R1002", 3],
      ["R1001", "R1003", 1],
      ["R1002", "R1003", 1],
      ["R1008", "R1001", 1],
      ["R1008", "R1005", 1],
      ["R1001", "R1005", 1],
      ["R1007", "R1004", 3],
      ["R1010", "R1004", 3],
      ["R1003", "R1006", 1],
      ["R1003", "R1009", 1],
      ["R1006", "R1009", 1]
    ];

    for (const [a, b, count] of coauthor) {
      // a -> b
      await session.run(
        `
        MATCH (x:Researcher {id:$a}), (y:Researcher {id:$b})
        MERGE (x)-[r:CO_AUTHOR]->(y)
        SET r.count=$count
        `,
        { a, b, count }
      );

      // b -> a (symmetric)
      await session.run(
        `
        MATCH (x:Researcher {id:$a}), (y:Researcher {id:$b})
        MERGE (y)-[r:CO_AUTHOR]->(x)
        SET r.count=$count
        `,
        { a, b, count }
      );
    }

    // SUPERVISES relations
    const supervises = [
      ["R1001", "R1008"],
      ["R1003", "R1009"]
    ];

    for (const [sup, stu] of supervises) {
      await session.run(
        `
        MATCH (s:Researcher {id:$sup}), (t:Researcher {id:$stu})
        MERGE (s)-[:SUPERVISES]->(t)
        `,
        { sup, stu }
      );
    }

    console.log("✅ Neo4j seed completed");
  } finally {
    await session.close();
    await driver.close();
  }
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
