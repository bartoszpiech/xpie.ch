# Available themes:      retro-light | terminal-dark
# Available backgrounds: grain | clouds | none
THEME := retro-light
#THEME      := terminal-dark
#BACKGROUND := grain
BACKGROUND := wallpaper

BUILD            := build
TEMPLATE         := _template.html
TEMPLATE_DESKTOP := _template_desktop.html

PAGES_MD   := about.md projects.md resume.md bajo.md
POSTS_MD   := $(wildcard blog/posts/*.md)
PAGES_HTML := $(PAGES_MD:%.md=$(BUILD)/%.html)
POSTS_HTML := $(POSTS_MD:blog/posts/%.md=$(BUILD)/blog/posts/%.html)
ALL_HTML   := $(BUILD)/index.html $(PAGES_HTML) $(BUILD)/blog/index.html $(POSTS_HTML)

PANDOC := pandoc --from=markdown+raw_html --metadata-file=_stats.yaml

.PHONY: all clean serve _stats.yaml wallpaper

all: $(BUILD)/css/style.css $(BUILD)/fonts $(BUILD)/backgrounds/wallpaper.webp $(BUILD)/gallery _stats.yaml $(ALL_HTML)

# ---- Wallpaper (convert source PNG → optimised WebP) ----
QUALITY := 82
wallpaper:
	cwebp -q $(QUALITY) backgrounds/wallpaper.png -o backgrounds/wallpaper.webp

$(BUILD)/backgrounds/wallpaper.webp: backgrounds/wallpaper.webp
	mkdir -p $(BUILD)/backgrounds
	cp backgrounds/wallpaper.webp $@

# ---- Gallery (symlink into build) ----
$(BUILD)/gallery:
	mkdir -p $(BUILD)
	ln -sf $(CURDIR)/gallery $(BUILD)/gallery

# ---- Fonts (symlink into build) ----
$(BUILD)/fonts:
	mkdir -p $(BUILD)
	ln -sf $(CURDIR)/fonts $(BUILD)/fonts

# ---- Theme + CSS build ----
$(BUILD)/css/style.css: themes/$(THEME).css backgrounds/$(BACKGROUND).css css/_base.css
	mkdir -p $(BUILD)/css
	cat themes/$(THEME).css backgrounds/$(BACKGROUND).css css/_base.css \
	  | minify --type=css > $@

# ---- Stats (reads previous build output) ----
_stats.yaml:
	@TOTAL_KB=$$(find -L $(BUILD) -type f 2>/dev/null \
	  | xargs cat 2>/dev/null | wc -c | tr -d ' ' | awk '{printf "%.1f", $$1/1024}') ; \
	POST_COUNT=$$(ls blog/posts/*.md 2>/dev/null | wc -l | tr -d ' ') ; \
	PAGE_COUNT=$(words $(ALL_HTML)) ; \
	printf 'total-kb: "%skb"\npage-count: "%s"\npost-count: "%s"\n' \
	  "$$TOTAL_KB" "$$PAGE_COUNT" "$$POST_COUNT" > _stats.yaml

# ---- Pages ----
$(BUILD)/index.html: index.md _stats.yaml $(TEMPLATE_DESKTOP) $(BUILD)/css/style.css
	mkdir -p $(BUILD)
	$(PANDOC) --template=$(TEMPLATE_DESKTOP) $< | minify --type=html > $@

$(BUILD)/blog/index.html: blog/index.md _stats.yaml $(TEMPLATE) $(BUILD)/css/style.css
	mkdir -p $(BUILD)/blog
	$(PANDOC) --template=$(TEMPLATE) --metadata parent="/index.html" $< | minify --type=html > $@

$(BUILD)/blog/posts/%.html: blog/posts/%.md _stats.yaml $(TEMPLATE) $(BUILD)/css/style.css
	mkdir -p $(BUILD)/blog/posts
	$(PANDOC) --template=$(TEMPLATE) --metadata parent="/blog/index.html" $< | minify --type=html > $@

$(BUILD)/%.html: %.md _stats.yaml $(TEMPLATE) $(BUILD)/css/style.css
	mkdir -p $(BUILD)
	$(PANDOC) --template=$(TEMPLATE) --metadata parent="/index.html" $< | minify --type=html > $@

clean:
	rm -rf $(BUILD) _stats.yaml

serve:
	python3 -m http.server 8080 --directory $(BUILD)
