import { Router } from "express";
import { topResearchersByPublications, mostCollaborativePair } from "../controllers/analytics.controller.js";

const r = Router();

r.get("/top-researchers", topResearchersByPublications);
r.get("/top-pair", mostCollaborativePair);

export default r;
