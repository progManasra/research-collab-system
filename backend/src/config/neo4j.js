import neo4j from "neo4j-driver";

export function createNeo4jDriver(uri, user, pass) {
  const driver = neo4j.driver(uri, neo4j.auth.basic(user, pass));
  console.log("Neo4j driver ready");
  return driver;
}
