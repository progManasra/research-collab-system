import { Router } from "express";
import { requireSession } from "../middleware/requireSession.js";
import {
  createPublication,
  listPublications,
  getPublication,
  updatePublication,
  deletePublication,
} from "../controllers/publications.controller.js";

const r = Router();

// ✅ Public (Read)
r.get("/", listPublications);
r.get("/:id", getPublication);

// ✅ Protected (Admin = write)
r.post("/", requireSession, createPublication);
r.put("/:id", requireSession, updatePublication);
r.delete("/:id", requireSession, deletePublication);

export default r;


// import { Router } from "express";
// import { createPublication, listPublications, getPublication, updatePublication, deletePublication } from "../controllers/publications.controller.js";

// const r = Router();
// r.post("/", createPublication);
// r.get("/", listPublications);
// r.get("/:id", getPublication);
// r.put("/:id", updatePublication);
// r.delete("/:id", deletePublication);

// export default r;
