---
name: technical-readme-transformer
description: Transforms technical README.md files into user-friendly product landing pages while extracting developer documentation into separate guides
when-to-use: When a project's README is too technical or developer-focused, when onboarding new users/stakeholders, or when preparing a project for public release
capabilities:
  - Analyzes README.md content to identify technical vs. user-facing information
  - Extracts API documentation, setup instructions, and technical details into DEVELOPER_GUIDE.md
  - Rewrites README.md as engaging, high-level product landing page copy
  - Creates compelling project hooks and value propositions
  - Structures content for visual hierarchy and readability
  - Adapts tone to welcome users and stakeholders, not just contributors
  - Preserves essential links and quick-start information
---

# Technical README Transformer

Transform technical documentation into user-friendly product landing pages while preserving developer details in dedicated guides.

## Core Purpose

Convert developer-centric README files into engaging product overviews that resonate with users, stakeholders, and potential contributors, ensuring technical details remain accessible in separate documentation.

## Guidelines

### 1. Initial Assessment

**Before transformation:**
- Read the entire README.md to understand content structure
- Identify sections that are technical/setup/API-focused
- Note the project's core purpose, audience, and unique value
- Preserve all links, badges, and essential metadata

### 2. Content Separation

**Move to DEVELOPER_GUIDE.md:**
- Installation and setup instructions (beyond quick start)
- API documentation and endpoints
- Architecture diagrams and technical specifications
- Development environment setup
- Testing procedures
- Contributing guidelines (or keep brief summary)
- Configuration details
- Deployment instructions

**Keep in README.md:**
- Project name and tagline
- Quick start (simplified, 3-5 commands max)
- Problem statement and solution
- Key features and benefits
- Use cases and examples
- Screenshots or visual demos
- Who this is for
- Links to detailed docs

### 3. README Structure

Follow this landing page structure:

```markdown
# [Project Name]

[Compelling hook - 1-2 sentences that grab attention]

## Why [Project Name]?

[Clear problem statement + your solution]

## Key Features

- [Benefit-driven feature 1]
- [Feature 2]
- [Feature 3]

## Who Should Use This?

- [User persona 1]
- [User persona 2]

## Quick Start

[Simplified 3-5 step setup]

## What's Next?

[Link to full docs, examples, community]

---
```

### 4. Writing Principles

**Focus on "Why" and "What":**
- ❌ "This tool uses Redis for caching with a TTL of 3600 seconds"
- ✅ "Lightning-fast performance with intelligent caching that keeps your data fresh"

**Create emotional connection:**
- Start with the problem users face
- Show empathy for their pain points
- Present your solution as the answer they've been looking for

**Use benefit-driven language:**
- Instead of "includes X feature", say "Achieve Y result with X"
- Focus on outcomes, not capabilities

**Maintain visual hierarchy:**
- Use emojis sparingly for visual interest (✨, 🚀, 💡)
- Keep paragraphs short (2-3 sentences)
- Use bullet points for features and benefits
- Include code blocks only for quick start examples

### 5. Tone Guidelines

- **Welcoming**: "Get started in minutes" not "Before you begin..."
- **Confident**: State benefits clearly without hedging
- **Inclusive**: Address users and stakeholders, not just developers
- **Professional but warm**: Avoid jargon unless clearly explained
- **Action-oriented**: Use verbs that encourage exploration

## Success Criteria

A successful transformation meets these criteria:

1. **README.md**:
   - Has a compelling hook within first 3 lines
   - Clearly states the problem being solved
   - Lists 3-7 benefit-driven features
   - Includes a quick start under 5 steps
   - Has no more than one code block (quick start)
   - Reads like a product landing page, not technical docs

2. **DEVELOPER_GUIDE.md**:
   - Contains all extracted technical content
   - Has clear sections and navigation
   - Preserves all original technical accuracy
   - Links back to README for context

3. **Overall**:
   - No information is lost or duplicated
   - Both documents are cross-referenced
   - A non-technical stakeholder can understand the project value from README
   - A developer can still find all technical details in DEVELOPER_GUIDE

## Edge Cases & Failure Modes

| Situation | Solution |
|-----------|----------|
| README is already user-friendly | Enhance existing structure, don't recreate |
| Project has no technical details | Create DEVELOPER_GUIDE with placeholder sections for future use |
| README is extremely short | Expand with problem statement, use cases, and benefits |
| Mixed content in sections | Split sections, keeping user-facing parts in README |
| Critical API info needed by users | Keep brief summary in README, full details in DEVELOPER_GUIDE |
| Multiple existing docs files | Consolidate technical content, create clear documentation hub |

## Example Transformations

### Before (Technical README):

```markdown
# DataFlow Pro

DataFlow Pro is a stream processing framework built on Apache Kafka. It uses the Consumer API to read from topics and the Producer API to write to output topics.

## Installation

```
npm install dataflow-pro
docker-compose up -d kafka redis
npm run configure
npm start
```

## API Reference

The StreamProcessor class accepts the following options:
- `batchSize`: Number (default: 100)
- `windowSize`: Number (default: 5000)
- `retryPolicy`: Object (see below)

See api.md for complete reference.
```

### After (Landing Page README):

```markdown
# DataFlow Pro ✨

**Transform chaotic data streams into actionable insights—without the complexity.**

## Why DataFlow Pro?

Processing real-time data shouldn't require a PhD in distributed systems. DataFlow Pro simplifies stream processing so you can focus on extracting value, not managing infrastructure.

## Key Features

- **Lightning-fast processing** – Handle millions of events per second with minimal latency
- **Fault-tolerant design** – Built-in retries and checkpointing keep your data safe
- **Flexible deployment** – Run anywhere: cloud, on-prem, or edge devices
- **Developer-friendly** – Intuitive APIs that get you productive in minutes

## Who Should Use This?

- Data engineers building real-time analytics pipelines
- Product teams needing live user behavior insights
- Startups scaling their data infrastructure

## Quick Start

```bash
npm install dataflow-pro
docker-compose up -d
npm start
```

## What's Next?

- 📖 [Full Developer Guide](./DEVELOPER_GUIDE.md)
- 💡 [Example Projects](./examples/)
- 💬 [Join our Community](https://discord.gg/dataflow)
```

### After (DEVELOPER_GUIDE.md):

```markdown
# DataFlow Pro - Developer Guide

Complete technical documentation for implementing and extending DataFlow Pro.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Architecture](#architecture)
- [Contributing](#contributing)

## Installation

### Prerequisites
- Node.js 16+
- Docker & Docker Compose
- Apache Kafka 2.8+

### Step-by-Step Setup

[Detailed setup instructions...]

## API Reference

### StreamProcessor

The core class for creating and managing data streams.

#### Constructor Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `batchSize` | Number | 100 | Number of events per batch |
| `windowSize` | Number | 5000 | Time window in milliseconds |

[Complete API documentation...]
```