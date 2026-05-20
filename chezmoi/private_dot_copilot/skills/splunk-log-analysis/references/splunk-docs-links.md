# Splunk Documentation Links

## Official Splunk Docs

- [SPL2 Search Reference](https://docs.splunk.com/Documentation/SplunkCloud/latest/SearchReference/WhatsInThisManual) — Complete SPL command reference
- [Splunk Search Tutorial](https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/WelcometotheSearchTutorial) — Getting started with Splunk search
- [Splunk Cheat Sheet](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/SplunkEnterpriseQuickReferenceGuide) — Quick reference card for SPL

## GitHub TheHub Docs

- [Splunk Cookbook](https://thehub.github.com/epd/engineering/dev-practicals/performance/tools/splunk/) — Performance-focused SPL patterns: slow pages, timeouts, exceptions, background jobs, killed SQL
- [A Splunk guide for dotcom](https://thehub.github.com/epd/engineering/incident-response/being-on-call/splunk/) — Complete guide with field reference, useful commands (`head`, `top`, `stats`, `timechart`, `ctable`), advanced usage (subsearches, index introspection)
- [Sentry Exceptions in Splunk](https://thehub.github.com/epd/engineering/dev-practicals/observability/sentry-exceptions-in-splunk/) — Querying the `prod-exceptions` index for exception data (all exceptions land here even when Sentry rate-limits)
- [Splunk Recipes](https://thehub.github.com/epd/engineering/dev-practicals/observability/logging/splunk-recipes/) — OTel-based service log queries for Moda services
- [Splunk-to-Kusto Guide](https://thehub.github.com/epd/engineering/dev-practicals/observability/logging/dotcom-kusto/splunk-to-kusto-guide/) — Translating SPL to KQL for the Dotcom Kusto cluster
- [Background Jobs Observability](https://thehub.github.com/epd/engineering/products-and-services/dotcom/background-jobs/observability/) — Logs from kube workers in the `catchall` index
- [GraphQL Debugging with Splunk](https://thehub.github.com/epd/engineering/products-and-services/public-apis/graphql/debugging/sentry-splunk/) — GraphQL-specific Splunk fields (`gh.graphql.*`)
- [How to Fast — Understanding What is Slow](https://thehub.github.com/epd/engineering/dev-practicals/performance/techniques/how-to-fast-understanding-what-is-slow/) — Using Splunk alongside Sentry and Datadog for performance investigation

## Splunk MCP

- [splunk-mcp wrapper](https://github.com/livehybrid/splunk-mcp) — The Python MCP server that bridges VS Code to Splunk's REST API

## GitHub Splunk Infrastructure

- [Splunk repo](https://github.com/github/splunk) — Index management, endpoint details
- [Splunk index chatop docs](https://github.com/github/splunk/blob/main/docs/splunk-index-chatop.md) — How to create a dedicated index for your service
- Slack: [#splunk](https://github.slack.com/archives/CCYGBERC4) — Splunk-specific questions
- Slack: [#observability](https://github.slack.com/archives/C9H0UJC2W) — General observability
- Team: `@github/security-telemetry` — Owns the Splunk infrastructure
