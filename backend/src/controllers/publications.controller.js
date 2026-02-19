import Publication from "../models/publication.model.js";

export async function createPublication(req, res) {
  const doc = await Publication.create(req.body);
  res.status(201).json(doc);
}

export async function listPublications(req, res) {
  const { projectId, authorId } = req.query;
  const filter = {};
  if (projectId) filter.projectId = projectId;
  if (authorId) filter.authorIds = authorId;

  const docs = await Publication.find(filter).lean();
  res.json(docs);
}

export async function getPublication(req, res) {
  const doc = await Publication.findById(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Publication not found" });
  res.json(doc);
}

export async function updatePublication(req, res) {
  const doc = await Publication.findByIdAndUpdate(req.params.id, req.body, { new: true }).lean();
  if (!doc) return res.status(404).json({ error: "Publication not found" });
  res.json(doc);
}

export async function deletePublication(req, res) {
  const doc = await Publication.findByIdAndDelete(req.params.id).lean();
  if (!doc) return res.status(404).json({ error: "Publication not found" });
  res.json({ ok: true });
}
