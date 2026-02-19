import Researcher from "../models/researcher.model.js";
import Project from "../models/project.model.js";
import Publication from "../models/publication.model.js";
import mongoose from "mongoose";

async function run() {
  const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/research";
  await mongoose.connect(mongoUri);

  // Reset
  await Researcher.deleteMany({});
  await Project.deleteMany({});
  await Publication.deleteMany({});

  // Researchers (10)
  const researchers = [
    { _id: "R1001", name: "Lina Ahmad", department: "CS", interests: ["AI", "NoSQL", "Graph"] },
    { _id: "R1002", name: "Omar Saleh", department: "CS", interests: ["Databases", "NoSQL"] },
    { _id: "R1003", name: "Sara Nasser", department: "Business", interests: ["TQM", "Quality 5.0"] },
    { _id: "R1004", name: "Maha Youssef", department: "Engineering", interests: ["IoT", "AI"] },
    { _id: "R1005", name: "Yazan Khatib", department: "CS", interests: ["Security", "Distributed Systems"] },
    { _id: "R1006", name: "Huda Karim", department: "Business", interests: ["Project Management", "Analytics"] },
    { _id: "R1007", name: "Ali Hamdan", department: "Engineering", interests: ["Robotics", "Lean"] },
    { _id: "R1008", name: "Nour Zaid", department: "CS", interests: ["ML", "NLP"] },
    { _id: "R1009", name: "Dina Farah", department: "Business", interests: ["HR", "AI"] },
    { _id: "R1010", name: "Khaled Saad", department: "Engineering", interests: ["BIM", "Automation"] }
  ];

  await Researcher.insertMany(researchers);

  // Projects (5)
  const projects = [
    {
      _id: "P2001",
      title: "Research Collaboration System",
      summary: "Prototype to manage research projects and collaboration network.",
      status: "active",
      participants: [
        { researcherId: "R1001", role: "PI" },
        { researcherId: "R1002", role: "Co-I" },
        { researcherId: "R1003", role: "Contributor" }
      ],
      publicationIds: ["PUB3001", "PUB3002", "PUB3003"]
    },
    {
      _id: "P2002",
      title: "Quality 5.0 in AI Projects",
      summary: "Studying Quality 5.0 principles for AI project success.",
      status: "active",
      participants: [
        { researcherId: "R1003", role: "PI" },
        { researcherId: "R1006", role: "Co-I" },
        { researcherId: "R1009", role: "RA" }
      ],
      publicationIds: ["PUB3004", "PUB3005", "PUB3006"]
    },
    {
      _id: "P2003",
      title: "Graph Analytics for Collaboration",
      summary: "Using graph databases for collaboration analytics.",
      status: "active",
      participants: [
        { researcherId: "R1001", role: "Co-I" },
        { researcherId: "R1008", role: "PI" },
        { researcherId: "R1005", role: "Contributor" }
      ],
      publicationIds: ["PUB3007", "PUB3008", "PUB3009"]
    },
    {
      _id: "P2004",
      title: "Lean + Real-Time Integration",
      summary: "Lean practices with real-time integration in service operations.",
      status: "completed",
      participants: [
        { researcherId: "R1007", role: "PI" },
        { researcherId: "R1004", role: "Co-I" }
      ],
      publicationIds: ["PUB3010", "PUB3011", "PUB3012"]
    },
    {
      _id: "P2005",
      title: "BIM Automation in Engineering",
      summary: "Automation workflows in BIM for engineering design.",
      status: "active",
      participants: [
        { researcherId: "R1010", role: "PI" },
        { researcherId: "R1004", role: "Co-I" }
      ],
      publicationIds: ["PUB3013", "PUB3014", "PUB3015"]
    }
  ];

  await Project.insertMany(projects);

  // Publications (15)
  const pubs = [
    { _id: "PUB3001", title: "Hybrid NoSQL Architecture for Research Systems", year: 2025, venue: "IEEE", projectId: "P2001", authorIds: ["R1001", "R1002"] },
    { _id: "PUB3002", title: "Caching Strategies for Integrated Queries", year: 2025, venue: "ACM", projectId: "P2001", authorIds: ["R1001", "R1003"] },
    { _id: "PUB3003", title: "Prototype Design Trade-offs in NoSQL", year: 2025, venue: "Springer", projectId: "P2001", authorIds: ["R1002", "R1003"] },

    { _id: "PUB3004", title: "Quality 5.0 Principles for AI Success", year: 2025, venue: "Elsevier", projectId: "P2002", authorIds: ["R1003", "R1006"] },
    { _id: "PUB3005", title: "Human-centric AI Governance in Services", year: 2025, venue: "IEEE", projectId: "P2002", authorIds: ["R1003", "R1009"] },
    { _id: "PUB3006", title: "Risk Factors in AI Project Delivery", year: 2024, venue: "ACM", projectId: "P2002", authorIds: ["R1006", "R1009"] },

    { _id: "PUB3007", title: "Graph-Based Collaboration Metrics", year: 2025, venue: "Neo4jConf", projectId: "P2003", authorIds: ["R1008", "R1001"] },
    { _id: "PUB3008", title: "Co-authorship Networks: A Practical Model", year: 2024, venue: "Springer", projectId: "P2003", authorIds: ["R1008", "R1005"] },
    { _id: "PUB3009", title: "Efficient Traversals for Research Graphs", year: 2024, venue: "ACM", projectId: "P2003", authorIds: ["R1001", "R1005"] },

    { _id: "PUB3010", title: "Lean Operations with Real-Time Data", year: 2024, venue: "IEEE", projectId: "P2004", authorIds: ["R1007", "R1004"] },
    { _id: "PUB3011", title: "Integration Patterns for Service Analytics", year: 2024, venue: "Elsevier", projectId: "P2004", authorIds: ["R1007", "R1004"] },
    { _id: "PUB3012", title: "Operational Waste Reduction with IoT", year: 2023, venue: "ACM", projectId: "P2004", authorIds: ["R1004", "R1007"] },

    { _id: "PUB3013", title: "BIM Automation Pipelines: Case Study", year: 2025, venue: "Springer", projectId: "P2005", authorIds: ["R1010", "R1004"] },
    { _id: "PUB3014", title: "Design Automation and Project Outcomes", year: 2024, venue: "IEEE", projectId: "P2005", authorIds: ["R1010", "R1004"] },
    { _id: "PUB3015", title: "Multidisciplinary Data Integration in BIM", year: 2024, venue: "Elsevier", projectId: "P2005", authorIds: ["R1010", "R1004"] }
  ];

  await Publication.insertMany(pubs);

  console.log("✅ Mongo seed completed");
  await mongoose.disconnect();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
