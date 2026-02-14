// Narration & preamble plugin for OpenCode.
//
// 1. System prompt injection: tells the model to always narrate its thinking,
//    offer choices when ambiguous, and explain before acting.
// 2. Preamble on edit/bash: when the model emits a tool call with no (or too
//    little) explanation, generates one via the "narration" sub-agent.
// 3. Tool definition hints: prepends "explain before calling" to tool
//    descriptions so the model sees it at tool-call decision time.
// 4. Post-tool summaries: after each tool execution, appends a short summary
//    of what happened so the conversation stays narrated.

export const Narration = async ({ client }) => {
  const handled = new Set()

  // Track the current provider so hooks without provider context
  // (tool.definition, tool.execute.after) can scope their behavior.
  let currentProvider = ""

  // If the assistant wrote fewer than this many characters, treat it as
  // "no useful explanation" and generate a preamble anyway.
  const MIN_EXPLANATION_CHARS_FOR_APPLY_PATCH = 120
  const MIN_EXPLANATION_CHARS_FOR_BASH = 80

  // Provider IDs whose models tend not to narrate their reasoning.
  const NARRATION_NUDGE_PROVIDERS = new Set(["openai", "google", "xai"])

  function truncate(value, maxChars) {
    if (typeof value !== "string") return value
    if (value.length <= maxChars) return value
    return value.slice(0, maxChars) + `\n…(truncated, ${value.length - maxChars} chars omitted)`
  }

  function safeJson(value, maxChars) {
    try {
      return truncate(JSON.stringify(value, null, 2), maxChars)
    } catch {
      return "(unserializable)"
    }
  }

  function extractFilesFromPatchText(patchText) {
    if (typeof patchText !== "string" || patchText.length === 0) return []
    const files = new Set()
    for (const rawLine of patchText.split(/\r?\n/)) {
      const line = rawLine.trim()
      // OpenCode apply_patch format:
      // *** Add File: path
      // *** Update File: path
      // *** Delete File: path
      if (line.startsWith("*** Add File:")) files.add(line.slice("*** Add File:".length).trim())
      if (line.startsWith("*** Update File:")) files.add(line.slice("*** Update File:".length).trim())
      if (line.startsWith("*** Delete File:")) files.add(line.slice("*** Delete File:".length).trim())
      // Common diff markers (best-effort fallback)
      if (line.startsWith("+++ b/")) files.add(line.slice("+++ b/".length).trim())
      if (line.startsWith("--- a/")) files.add(line.slice("--- a/".length).trim())
    }
    return Array.from(files).filter(Boolean)
  }

  function summarizeToolPayload(toolPayload) {
    const tool = toolPayload?.tool ?? "unknown"
    const input = toolPayload?.input ?? {}

    if (tool === "apply_patch") {
      const patchText = input?.patchText
      const files = extractFilesFromPatchText(patchText)
      const patchChars = typeof patchText === "string" ? patchText.length : 0
      const patchLines = typeof patchText === "string" ? patchText.split(/\r?\n/).length : 0
      return {
        tool,
        summary: {
          files,
          patch: {
            chars: patchChars,
            lines: patchLines,
          },
        },
      }
    }

    return { tool, input }
  }

  async function safeToast(message) {
    try {
      await client.tui.showToast({
        title: "Narration",
        message,
        variant: "info",
        duration: 6000,
      })
    } catch {
      // Ignore toast failures (eg. non-TUI client).
    }
  }

  // ── System prompt injection ──────────────────────────────────────────
  // Appends narration/choice-offering instructions for models that need it.
  const NARRATION_SYSTEM_PROMPT = [
    "# Communication style",
    "",
    "Always narrate your thought process as you work. In the same response,",
    "include a short explanation of what you are about to do and why alongside",
    "each tool call. Between consecutive tool calls, briefly summarize what",
    "you learned and what you plan to do next. Every response that includes",
    "tool calls should also include interleaved text explaining them.",
    "",
    "# Offering choices",
    "",
    "When a user's request is ambiguous or there are multiple reasonable",
    "approaches, present the options as a short numbered list and ask which",
    "they prefer before proceeding. If one option is clearly best, recommend",
    "it but still let the user decide. Only skip this when the task is",
    "completely unambiguous.",
    "",
    "# Explaining edits",
    "",
    "In the same response as the tool call, explain in plain language:",
    "(a) what you intend to change, (b) which files are affected, and",
    "(c) why this change addresses the user's request.",
  ].join("\n")

  return {
    // ── Track current provider ─────────────────────────────────────────
    "chat.params": async (input, _output) => {
      currentProvider = input?.provider?.info?.id ?? input?.model?.providerID ?? ""
    },

    // ── System prompt hook ─────────────────────────────────────────────
    "experimental.chat.system.transform": async (input, output) => {
      const provider = input?.model?.providerID ?? ""
      currentProvider = provider
      if (NARRATION_NUDGE_PROVIDERS.has(provider)) {
        output.system.push(NARRATION_SYSTEM_PROMPT)
      }
    },

    // ── Tool definition hints ──────────────────────────────────────────
    // Prepend a short instruction to tool descriptions so the model sees
    // it right at the point where it decides to call a tool.
    // Only applied for providers that tend to skip explanations.
    "tool.definition": async (_input, output) => {
      if (!NARRATION_NUDGE_PROVIDERS.has(currentProvider)) return
      const hint =
        "IMPORTANT: In the same response, write a short explanation of what " +
        "you are about to do and why, then call this tool.\n\n"
      if (output.description && !output.description.startsWith("IMPORTANT:")) {
        output.description = hint + output.description
      }
    },

    // ── Post-tool summaries ────────────────────────────────────────────
    // After a tool executes, append a brief human-readable summary to the
    // tool output so the model (and user) can follow the narrative.
    "tool.execute.after": async (input, output) => {
      if (!NARRATION_NUDGE_PROVIDERS.has(currentProvider)) return
      try {
        const tool = input?.tool ?? "unknown"
        const args = input?.args ?? {}
        let summary = ""

        if (tool === "read") {
          const file = args.filePath ?? args.path ?? "unknown file"
          summary = `[Read ${file}]`
        } else if (tool === "glob") {
          summary = `[Searched for files matching: ${args.pattern ?? "?"}]`
        } else if (tool === "grep") {
          summary = `[Searched file contents for: ${args.pattern ?? "?"}]`
        } else if (tool === "bash") {
          const cmd = typeof args.command === "string" ? args.command.slice(0, 120) : "?"
          summary = `[Ran command: ${cmd}]`
        } else if (tool === "edit") {
          summary = `[Edited ${args.filePath ?? args.path ?? "unknown file"}]`
        } else if (tool === "write") {
          summary = `[Wrote ${args.filePath ?? args.path ?? "unknown file"}]`
        } else if (tool === "apply_patch") {
          const files = extractFilesFromPatchText(args.patchText)
          summary = files.length > 0
            ? `[Applied patch to: ${files.join(", ")}]`
            : `[Applied patch]`
        } else if (tool === "webfetch") {
          summary = `[Fetched: ${args.url ?? "?"}]`
        } else if (tool === "task") {
          summary = `[Ran sub-task: ${(args.description ?? "").slice(0, 80)}]`
        }

        if (summary && output.output != null) {
          output.output = output.output + "\n\n" + summary
        }
      } catch {
        // Never break tool execution for a summary failure.
      }
    },

    // ── Preamble on permission ─────────────────────────────────────────
    event: async ({ event }) => {
      // The handler may receive either the raw Event ({ type, properties })
      // or a GlobalEvent envelope ({ directory, payload: { type, properties } }).
      const ev = event?.payload ?? event
      if (ev?.type !== "permission.updated" && ev?.type !== "permission.asked") return

      const permission = ev?.properties?.info ?? ev?.properties
      if (!permission?.id || !permission?.sessionID || !permission?.messageID) return
      const dedupeKey = `${permission.sessionID}:${permission.messageID}:${permission.callID ?? ""}`
      if (handled.has(permission.id) || handled.has(dedupeKey)) return

      // Only intervene for file-modifying and bash permission gates.
      if (permission.type !== "edit" && permission.type !== "bash") return

      handled.add(permission.id)
      handled.add(dedupeKey)

      let parts = []
      try {
        const msg = await client.session.message({
          sessionID: permission.sessionID,
          messageID: permission.messageID,
        })
        parts = msg?.data?.parts ?? []
      } catch {
        return
      }

      const assistantText = parts
        .filter((p) => p?.type === "text" && typeof p.text === "string")
        .map((p) => p.text)
        .join("\n")
        .trim()

      const toolPart =
        permission.callID &&
        parts.find((p) => p?.type === "tool" && p.callID === permission.callID)

      // If we can’t find the tool call details, still generate a generic preamble.
      const toolPayload = {
        tool: toolPart?.tool ?? "unknown",
        input: toolPart?.state?.input ?? {},
      }

      const summarizedToolPayload = summarizeToolPayload(toolPayload)

      const hasUserVisibleText = assistantText.length > 0
      const shouldGenerateDespiteText =
        (toolPayload.tool === "apply_patch" && assistantText.length < MIN_EXPLANATION_CHARS_FOR_APPLY_PATCH) ||
        (permission.type === "bash" && assistantText.length < MIN_EXPLANATION_CHARS_FOR_BASH)

      if (hasUserVisibleText && !shouldGenerateDespiteText) {
        return
      }

      // Try to fetch the most recent user question prior to this tool-calling message.
      let lastUserText = ""
      try {
        const history = await client.session.messages({
          sessionID: permission.sessionID,
          limit: 50,
        })
        const items = history?.data ?? history
        if (Array.isArray(items) && items.length > 0) {
          const idx = items.findIndex((m) => m?.info?.id === permission.messageID)
          for (let i = (idx >= 0 ? idx : items.length) - 1; i >= 0; i--) {
            const entry = items[i]
            if (entry?.info?.role !== "user") continue
            const text = (entry.parts ?? [])
              .filter((p) => p?.type === "text" && typeof p.text === "string")
              .map((p) => p.text)
              .join("\n")
              .trim()
            if (text) {
              lastUserText = text
              break
            }
          }
        }
      } catch {
        // Ignore; we can still generate a generic preamble.
      }

      const isBash = permission.type === "bash"
      const prompt =
        `You are generating a short assistant message that will be shown to the user BEFORE they approve a ${isBash ? "shell command" : "file change"}.\n` +
        "The original assistant message may have been missing (or too short on) explanation.\n\n" +
        "Do BOTH of these in the same message:\n" +
        "1) Answer the user's latest question (if there is one).\n" +
        `2) Explain what the pending ${isBash ? "command" : "file change"} will do and why, in plain language.\n\n` +
        "Constraints:\n" +
        "- Do NOT call tools and do NOT ask the user to run commands.\n" +
        `- If you cannot fully answer yet, say what info is missing, but still explain the intended ${isBash ? "command" : "change"}.\n` +
        (isBash ? "" : "- Mention affected files if obvious.\n") +
        "- Keep it concise (max ~12 lines).\n\n" +
        (assistantText
          ? `Assistant already wrote (may be too short):\n${truncate(assistantText, 800)}\n\n`
          : "") +
        (lastUserText
          ? `User's latest message:\n${truncate(lastUserText, 2000)}\n\n`
          : "") +
        "Pending tool call (JSON, may be truncated):\n" +
        safeJson(summarizedToolPayload, 8000)

      try {
        await safeToast("Generating an explanation for the pending edit...")
        await client.session.promptAsync({
          sessionID: permission.sessionID,
          // Thread it off the tool-calling message for context.
          messageID: permission.messageID,
          agent: "narration",
          parts: [{ type: "text", text: prompt }],
        })
      } catch {
        // If anything goes wrong, don’t block the normal permission flow.
        await safeToast("Could not generate explanation (plugin error).")
      }
    },
  }
}
