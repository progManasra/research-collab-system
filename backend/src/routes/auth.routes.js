import { Router } from "express";
import { login, logout, me } from "../controllers/auth.controller.js";
import { requireSession } from "../middleware/requireSession.js";

const r = Router();

r.post("/login", login);
r.post("/logout", logout);
r.get("/me", requireSession, me);

export default r;
