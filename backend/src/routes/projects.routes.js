import { Router } from "express";
import { requireSession } from "../middleware/requireSession.js";
import {
  createProject,
  listProjects,
  getProject,
  updateProject,
  deleteProject,
} from "../controllers/projects.controller.js";

const r = Router();

// ✅ Public (Read)
r.get("/", listProjects);
r.get("/:id", getProject);

// ✅ Protected (Admin = write)
r.post("/", requireSession, createProject);
r.put("/:id", requireSession, updateProject);
r.delete("/:id", requireSession, deleteProject);

export default r;



// import { Router } from "express";
// import { createProject, listProjects, getProject, updateProject, deleteProject } from "../controllers/projects.controller.js";

// const r = Router();
// r.post("/", createProject);
// r.get("/", listProjects);
// r.get("/:id", getProject);
// r.put("/:id", updateProject);
// r.delete("/:id", deleteProject);

// export default r;
