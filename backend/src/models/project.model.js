import mongoose from "mongoose";

const ProjectSchema = new mongoose.Schema(
  {
    _id: { type: String, required: true }, // P2001
    title: { type: String, required: true },
    summary: { type: String, default: "" },
    status: { type: String, default: "active" },
    participants: [
      {
        researcherId: { type: String, required: true },
        role: { type: String, required: true }
      }
    ],
    publicationIds: [{ type: String }]
  },
  { timestamps: true }
);

ProjectSchema.index({ "participants.researcherId": 1 });
ProjectSchema.index({ status: 1 });

export default mongoose.model("Project", ProjectSchema);
