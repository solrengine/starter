# Lookbook personalization for the SolRengine starter.

Rails.application.config.lookbook.tap do |lookbook|
  # Browser tab + sidebar header. Includes the installed solrengine-ui
  # version so visitors can tell which release they're browsing.
  lookbook.project_name = "SolRengine Starter · solrengine-ui v#{Solrengine::Ui::VERSION}"

  # Every preview renders inside app/views/layouts/lookbook_preview.html.erb,
  # which loads the starter's own Tailwind build and centers the component
  # in a flex container so it's not jammed against the top-left corner.
  lookbook.preview_layout = "lookbook_preview"

  # Purple accent palette (Tailwind purple-*) via CSS custom property overrides.
  # Keeps the indigo base theme but repaints highlights to match the Solana /
  # SolRengine brand.
  lookbook.ui_theme = :indigo
  lookbook.ui_theme_overrides do |theme|
    theme[:accent_50]  = "#faf5ff"
    theme[:accent_100] = "#f3e8ff"
    theme[:accent_200] = "#e9d5ff"
    theme[:accent_300] = "#d8b4fe"
    theme[:accent_400] = "#c084fc"
    theme[:accent_500] = "#a855f7"
    theme[:accent_600] = "#9333ea"
    theme[:accent_700] = "#7e22ce"
    theme[:accent_800] = "#6b21a8"
    theme[:accent_900] = "#581c87"
    theme[:favicon]    = "#a855f7"
  end
end
