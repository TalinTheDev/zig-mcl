-- Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
-- Configures neovim for this specific project

return {
	lsp = {
		zls = {
			settings = {
				zls = {
					enable_build_on_save = true,
					semantic_tokens = "partial",
				},
			},
		},
		bashls = {},
	},
	mason = {
		"shellharden",
	},
	treesitter = {
		"zig",
		"bash",
	},
}
