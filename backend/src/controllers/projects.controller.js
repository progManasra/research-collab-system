import Project from "../models/project.model.js";

export async function createProject(req, res) {
  const doc = await Project.create(req.body);
  res.status(201).json(doc);
}

export async function listProjects(req, res) {
  const { researcherId } = req.query;
  const filter = {};
  if (researcherId) filter["participants.researcherId"] = researcherId;

  const docs = await Project.find(filter).lean();
  res.json(docs);
}

export async function getProject(req, res) {
  const doc = await Project.findById(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Project not found" });
  res.json(doc);
}

export async function updateProject(req, res) {
  const doc = await Project.findByIdAndUpdate(req.params.id, req.body, { new: true }).lean();
  if (!doc) return res.status(404).json({ error: "Project not found" });
  res.json(doc);
}

export async function deleteProject(req, res) {
  const doc = await Project.findByIdAndDelete(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Project not found" });
  res.json({ ok: true });
}
