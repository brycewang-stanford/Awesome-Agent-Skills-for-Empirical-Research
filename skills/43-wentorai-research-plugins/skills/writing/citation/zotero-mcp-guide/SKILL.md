---
name: zotero-mcp-guide
description: "Guide to Zotero MCP for connecting Zotero library with AI assistants"
metadata:
  openclaw:
    emoji: "🔗"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "mcp", "claude", "ai-assistant", "model-context-protocol"]
    source: "https://github.com/54yyyu/zotero-mcp"
---

# Zotero MCP Guide

## Overview

Zotero MCP is an emerging tool with over 2,000 GitHub stars that implements the Model Context Protocol (MCP) to connect your Zotero reference library with AI assistants such as Claude. By exposing your Zotero library as a structured data source through MCP, it allows AI models to search, retrieve, and reason about your collected academic papers, annotations, and notes during conversations.

The Model Context Protocol provides a standardized way for AI applications to access external data sources. Zotero MCP leverages this protocol to give AI assistants direct, read-only access to your research library. Instead of manually copying and pasting paper details into a chat, you can ask an AI assistant to look up papers in your Zotero library, summarize your annotations on a specific topic, find related references, or help draft text based on your collected sources.

This integration is particularly valuable for researchers who maintain comprehensive Zotero libraries and want to leverage AI assistance for literature reviews, writing, and knowledge synthesis. The AI can work with the full context of your library rather than being limited to whatever you paste into the conversation, making interactions more productive and contextually grounded.

## Installation and Setup

Zotero MCP requires both a running Zotero instance and an MCP-compatible AI client.

**Prerequisites**:
- Zotero 6 or 7 installed and running
- Node.js 18 or later
- An MCP-compatible AI client (Claude Desktop, or another MCP host)

**Install the MCP Server**:

```bash
# Clone the repository
git clone https://github.com/54yyyu/zotero-mcp.git
cd zotero-mcp

# Install dependencies
npm install

# Build the server
npm run build
```

**Configure Zotero**:
- Ensure the Zotero local API is enabled (it is by default on port 23119)
- The MCP server communicates with Zotero through its local HTTP API
- No API key is needed for local connections; Zotero must simply be running

**Configure Your AI Client**:

For Claude Desktop, add the Zotero MCP server to your configuration file (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "zotero": {
      "command": "node",
      "args": ["/path/to/zotero-mcp/dist/index.js"]
    }
  }
}
```

For other MCP hosts, follow their respective documentation for adding MCP servers. The server communicates over stdio using the standard MCP transport protocol.

**Verify the Connection**:
1. Start Zotero
2. Launch your AI client with the MCP configuration
3. Ask the AI to search your Zotero library (e.g., "Find papers about machine learning in my Zotero library")
4. If the AI returns results from your library, the connection is working

## Core Features

**Library Search**: The MCP server exposes a search tool that allows AI assistants to query your Zotero library using natural language or structured queries. The AI can search by:
- Title keywords
- Author names
- Publication year or date range
- Tags and collections
- Full-text content (if Zotero full-text indexing is enabled)

**Item Retrieval**: Retrieve complete metadata for specific items including:
- Bibliographic information (title, authors, journal, year, DOI, etc.)
- Abstract and keywords
- Tags and collection membership
- Attached file information
- Related items

**Annotation Access**: The AI can read your PDF annotations and notes for specific items. This means you can ask questions like "What did I highlight in the Smith 2024 paper?" or "Summarize my annotations on papers about transformer architectures" and the AI will access your actual annotations to formulate a response.

**Collection Browsing**: Navigate your Zotero collection hierarchy to understand how you have organized your library. The AI can list collections, show items within specific collections, and understand the taxonomic structure of your research.

**Note Reading**: Access standalone notes and item notes in your Zotero library. This is useful for AI-assisted writing where your accumulated research notes provide the source material for drafting text.

**Citation Formatting**: Request formatted citations for items in your library. The AI can generate citations in various styles (APA, MLA, Chicago, etc.) by accessing the complete bibliographic data through MCP.

## Research Workflow Integration

**AI-Assisted Literature Review**:
1. Collect papers on your topic in a Zotero collection as you normally would
2. Read and annotate the papers in Zotero's PDF reader
3. Start a conversation with your AI assistant
4. Ask the AI to review your collection and annotations on the topic
5. The AI accesses your library through MCP and synthesizes your annotations
6. Iterate with the AI to identify themes, gaps, and connections you may have missed

**Intelligent Writing Support**:
- Ask the AI to draft a paragraph about a topic, referencing papers from your library
- The AI retrieves relevant items and annotations to ground the draft in your sources
- Request properly formatted citations that match your collected references
- Iterate on the draft with the AI having full context of your source materials

**Research Question Exploration**:
- Pose a research question to the AI
- Ask it to search your library for relevant papers
- The AI identifies which of your collected papers relate to the question
- Discuss the state of knowledge based on your library, not general training data

**Library Management Assistance**:
- Ask the AI to identify potential duplicate entries in your library
- Request suggestions for how to reorganize collections based on content analysis
- Have the AI suggest tags for untagged items based on their metadata and content

**Example Conversations**:

```
You: What papers do I have about attention mechanisms in neural networks?

AI: [Searches Zotero via MCP] I found 12 papers in your library related
to attention mechanisms. The earliest is Bahdanau et al. (2014) and the
most recent is...

You: Summarize what I highlighted in the Vaswani 2017 paper.

AI: [Retrieves annotations via MCP] In the Vaswani et al. (2017)
"Attention Is All You Need" paper, you highlighted three key passages...
```

## Security and Privacy Considerations

Zotero MCP operates locally on your machine. All communication between the MCP server and Zotero happens over localhost, and your library data is not uploaded to any external service. However, when you use the MCP integration with a cloud-based AI assistant, the content retrieved from your library is sent to the AI provider as part of the conversation context.

**Best practices for privacy**:
- Be aware that paper content, annotations, and notes accessed through MCP will be included in your conversation with the AI provider
- Avoid using MCP with sensitive or embargoed research content when the AI provider is cloud-based
- For maximum privacy, use MCP with locally-hosted AI models
- Review your AI provider's data retention and usage policies
- The MCP server provides read-only access; it cannot modify your Zotero library

## Troubleshooting

**AI Cannot Find Zotero**: Ensure Zotero is running before starting your AI client. The MCP server connects to Zotero's local API on port 23119. If you have changed the default port, update the MCP server configuration accordingly.

**Search Returns No Results**: Verify that your Zotero library has items and that full-text indexing is enabled for better search coverage. Check that the MCP server is properly connected by reviewing its console output for any error messages.

**Slow Responses**: Large libraries may take longer to search. Consider using more specific queries or searching within particular collections to narrow the scope. Enabling Zotero's search cache can improve response times.

## References

- GitHub Repository: https://github.com/54yyyu/zotero-mcp
- Model Context Protocol Specification: https://modelcontextprotocol.io
- Zotero Local API Documentation: https://www.zotero.org/support/dev/web_api/v3/basics
- Claude Desktop MCP Configuration: https://docs.anthropic.com/en/docs/claude-desktop
