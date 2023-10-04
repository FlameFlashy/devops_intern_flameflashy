// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html

module.exports = function (config) {
  config.set({
    basePath: "",
    frameworks: ["jasmine", "@angular-devkit/build-angular"],
    plugins: [
      require("karma-jasmine"),
      require("karma-chrome-launcher"),
      require("karma-jasmine-html-reporter"),
      require("karma-coverage-istanbul-reporter"),
      require("karma-junit-reporter"),
      require("@angular-devkit/build-angular/plugins/karma"),
    ],
    client: {
      clearContext: false, // leave Jasmine Spec Runner output visible in browser
    },
    coverageIstanbulReporter: {
      // dir: require('path').join(__dirname, './coverage'),
      reports: [
        //   'html',
        //   'lcovonly',
        "text-summary",
        "cobertura",
        ...(process.env.ISTANBUL_ADD_REPORTERS || "")
          .split(",")
          .filter((x) => x),
      ],
      fixWebpackSourcePaths: true,
      // thresholds: {
      //     emitWarning: true, // set to `true` to not fail the test command when thresholds are not met
      //     // thresholds for all files
      //     global: {
      //         statements: 90,
      //         lines: 90,
      //         branches: 90,
      //         functions: 90,
      //     },
      //     // thresholds per file
      //     // each: {
      //     //     statements: 90,
      //     //     lines: 90,
      //     //     branches: 90,
      //     //     functions: 90,
      //     //     overrides: {
      //     //         'baz/component/**/*.js': {
      //     //             statements: 98,
      //     //         },
      //     //     },
      //     // },
      // },
    },
    reporters: [
      "progress",
      "kjhtml",
      "coverage-istanbul",
      ...(process.env.KARMA_ADD_REPORTERS || "").split(",").filter((x) => x),
    ],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ["ChromeHeadlessNoSandbox"],
    customLaunchers: {
      ChromeHeadlessNoSandbox: {
        base: "ChromeHeadless",
        flags: [
          "--no-sandbox", // Disable sandboxing
          "--disable-setuid-sandbox", // Disable setuid sandbox (Linux)
        ],
      },
    },
    singleRun: true,
    restartOnFileChange: true,
    junitReporter: {
      outputDir: "./reports/",
    },
    coverageReporter: {
      dir: "./coverage",
      reporters: [
        { type: "cobertura", subdir: ".", file: "cobertura-coverage.xml" },
      ],
    },
  });
};
