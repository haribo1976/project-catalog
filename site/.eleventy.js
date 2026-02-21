module.exports = function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("src/assets");

  eleventyConfig.addFilter("domainLabel", (code) => {
    const labels = {
      azure: "Azure",
      m365: "Microsoft 365",
      doc: "Document Processing",
      fin: "Finance",
      grc: "GRC",
      compliance: "Compliance",
      hr: "HR",
      ops: "Operations",
      lib: "Libraries",
      personal: "Personal",
    };
    return labels[code] || code;
  });

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data",
    },
    templateFormats: ["njk"],
    htmlTemplateEngine: "njk",
  };
};
