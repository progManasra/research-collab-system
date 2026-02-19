import mongoose from "mongoose";

const PublicationSchema = new mongoose.Schema(
  {
    _id: { type: String, required: true }, // PUB3001
    title: { type: String, required: true },
    year: { type: Number, default: 2025 },
    venue: { type: String, default: "" },
    projectId: { type: String, required: true },
    authorIds: [{ type: String, required: true }]
  },
  { timestamps: true }
);

PublicationSchema.index({ projectId: 1 });
PublicationSchema.index({ authorIds: 1 });
PublicationSchema.index({ year: 1 });

export default mongoose.model("Publication", PublicationSchema);
