import mongoose from "mongoose";

const ResearcherSchema = new mongoose.Schema(
  {
    _id: { type: String, required: true }, // R1001
    name: { type: String, required: true },
    department: { type: String, required: true },
    interests: [{ type: String }]
  },
  { timestamps: true }
);

ResearcherSchema.index({ department: 1 });
ResearcherSchema.index({ interests: 1 });

export default mongoose.model("Researcher", ResearcherSchema);
