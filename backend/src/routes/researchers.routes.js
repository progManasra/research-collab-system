import { Router } from "express";
import { requireSession } from "../middleware/requireSession.js";

import {
  createResearcher,
  listResearchers,
  getResearcher,
  updateResearcher,
  deleteResearcher,
  getIntegratedProfile,
} from "../controllers/researchers.controller.js";

const r = Router();

// ✅ Public (Read)
r.get("/", listResearchers);
r.get("/:id", getResearcher);
r.get("/:id/profile-integrated", getIntegratedProfile);

// ✅ Protected (Admin = write operations)
r.post("/", requireSession, createResearcher);
r.put("/:id", requireSession, updateResearcher);
r.delete("/:id", requireSession, deleteResearcher);

export default r;


// import { Router } from "express";
// import {
//   createResearcher, listResearchers, getResearcher, updateResearcher, deleteResearcher
// } from "../controllers/researchers.controller.js";
// import { getIntegratedProfile } from "../controllers/researchers.controller.js";


// const r = Router();
// r.post("/", createResearcher);
// r.get("/", listResearchers);
// r.get("/:id", getResearcher);
// r.put("/:id", updateResearcher);
// r.delete("/:id", deleteResearcher);
// r.get("/:id/profile-integrated", getIntegratedProfile);

// export default r;
