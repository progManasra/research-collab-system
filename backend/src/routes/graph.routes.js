import { Router } from "express";
import { requireSession } from "../middleware/requireSession.js";
import {
  upsertResearcherNode,
  addCoauthor,
  addSupervises,
  deleteCoauthor,
  deleteSupervises,
  getNeighborhoodGraph,
} from "../controllers/graph.controller.js";

const r = Router();

// ✅ Public (Read)
r.get("/neighborhood/:id", getNeighborhoodGraph);

// ✅ Protected (Admin = write)
r.post("/researcher-node", requireSession, upsertResearcherNode);
r.post("/coauthor", requireSession, addCoauthor);
r.post("/supervises", requireSession, addSupervises);

r.delete("/coauthor", requireSession, deleteCoauthor);
r.delete("/supervises", requireSession, deleteSupervises);

export default r;


// import { Router } from "express";
// import {
//   getNeighborhoodGraph,
//   upsertResearcherNode,
//   addCoauthor,
//   addSupervises
// } from "../controllers/graph.controller.js";

// const r = Router();

// r.get("/neighborhood/:id", getNeighborhoodGraph);

// // ✅ POST endpoints
// r.post("/researcher-node", upsertResearcherNode);
// r.post("/coauthor", addCoauthor);
// r.post("/supervises", addSupervises);

// export default r;
