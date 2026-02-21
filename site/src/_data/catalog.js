const yaml = require("js-yaml");
const fs = require("fs");
const path = require("path");

module.exports = function () {
  const raw = fs.readFileSync(
    path.resolve(__dirname, "../../../catalog/projects-public.yaml"),
    "utf8"
  );
  const data = yaml.load(raw);
  const projects = data.projects || [];
  const metadata = data._metadata || {};

  const domains = [...new Set(projects.map((p) => p.domain))].sort();
  const categories = [...new Set(projects.map((p) => p.category))].sort();

  const stats = {
    total: projects.length,
    withDeploymentPlan: projects.filter((p) => p.has_deployment_plan).length,
    domains: domains.length,
    categories: categories.length,
  };

  return { projects, metadata, domains, categories, stats };
};
