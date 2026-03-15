# Available themes:      retro-light | terminal-dark
# Available backgrounds: grain | clouds | none
THEME := retro-light
#THEME      := terminal-dark
#BACKGROUND := grain
BACKGROUND := wallpaper

BUILD            := build
SITE_URL         := https://xpie.ch
SITE_LAUNCH      := 2026-03-15
WEATHER_CITY     := Warsaw
GITHUB_REPO      := bartoszpiech/xpie.ch
TEMPLATE         := _template.html
TEMPLATE_DESKTOP := _template_desktop.html

PAGES_MD   := about.md projects.md resume.md bajo.md song.md usrbin.md 404.md
POSTS_MD   := $(wildcard blog/posts/*.md)
PAGES_HTML := $(PAGES_MD:%.md=$(BUILD)/%.html)
POSTS_HTML := $(POSTS_MD:blog/posts/%.md=$(BUILD)/blog/posts/%.html)
ALL_HTML   := $(BUILD)/index.html $(PAGES_HTML) $(BUILD)/blog/index.html $(POSTS_HTML)

PANDOC := pandoc --from=markdown+raw_html --metadata-file=_stats.yaml \
          --lua-filter=reading-time.lua --toc \
          --include-after-body=cowsay.html

.PHONY: all clean serve _stats.yaml wallpaper subset-font

all: $(BUILD)/css/style.css $(BUILD)/fonts $(BUILD)/backgrounds/wallpaper.webp $(BUILD)/gallery $(BUILD)/badges $(BUILD)/song.opus $(BUILD)/cursor.png _stats.yaml $(ALL_HTML) $(BUILD)/feed.xml $(BUILD)/sitemap.xml $(BUILD)/robots.txt $(BUILD)/humans.txt $(BUILD)/CNAME

$(BUILD)/song.opus: song.opus
	cp song.opus $(BUILD)/song.opus

$(BUILD)/cursor.png: cursor.png
	cp cursor.png $(BUILD)/cursor.png

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
	POST_COUNT=$$(ls blog/posts/*.md 2>/dev/null | wc -l | tr -d ' ') ; \
	PAGE_COUNT=$(words $(ALL_HTML)) ; \
	BUILD_DATE=$$(date '+%Y-%m-%d') ; \
	LAUNCH_TS=$$(date -d "$(SITE_LAUNCH)" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$(SITE_LAUNCH)" +%s) ; \
	NOW_TS=$$(date +%s) ; \
	UPTIME=$$(( ($$NOW_TS - $$LAUNCH_TS) / 86400 )) ; \
	WEATHER=$$(curl -sf "https://wttr.in/$(WEATHER_CITY)?format=%c%20%t%20%w&m" 2>/dev/null \
	  | sed 's/↑/⬆️/g;s/↗/↗️/g;s/→/➡️/g;s/↘/↘️/g;s/↓/⬇️/g;s/↙/↙️/g;s/←/⬅️/g;s/↖/↖️/g' \
	  || echo "") ; \
	GH_STARS="" ; \
	if [ -n "$(GITHUB_REPO)" ]; then \
	  GH_STARS=$$(curl -sf "https://api.github.com/repos/$(GITHUB_REPO)" \
	    | grep -o '"stargazers_count":[0-9]*' | grep -o '[0-9]*' || echo "") ; \
	fi ; \
	printf 'page-count: "%s"\npost-count: "%s"\nbuild-date: "%s"\nuptime: "up %sd"\nweather: "%s"\ngh-stars: "%s"\n' \
	  "$$PAGE_COUNT" "$$POST_COUNT" "$$BUILD_DATE" "$$UPTIME" "$$WEATHER" "$$GH_STARS" > _stats.yaml

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
	mkdir -p $(dir $@)
	$(PANDOC) --template=$(TEMPLATE) --metadata parent="/index.html" $< | minify --type=html > $@

# ---- RSS feed ----
$(BUILD)/feed.xml: $(POSTS_MD)
	@mkdir -p $(BUILD)
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0"><channel>\n<title>xpie.ch</title>\n<link>https://xpie.ch</link>\n<description>xpie.ch blog</description>\n' > $@
	@for f in $(POSTS_MD); do \
	  title=$$(grep '^title:' $$f | head -1 | sed 's/^title: *//;s/"//g'); \
	  date=$$(grep '^date:' $$f | head -1 | sed 's/^date: *//;s/"//g'); \
	  slug=$$(basename $$f .md); \
	  printf '<item><title>%s</title><link>https://xpie.ch/blog/posts/%s.html</link><pubDate>%s</pubDate></item>\n' \
	    "$$title" "$$slug" "$$date" >> $@; \
	done
	@printf '</channel></rss>\n' >> $@

# ---- Sitemap ----
$(BUILD)/sitemap.xml: $(ALL_HTML)
	@mkdir -p $(BUILD)
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' > $@
	@for f in $(ALL_HTML); do \
	  url=$$(echo $$f | sed 's|^$(BUILD)||'); \
	  printf '<url><loc>$(SITE_URL)%s</loc></url>\n' "$$url" >> $@; \
	done
	@printf '</urlset>\n' >> $@

# ---- Static files ----
$(BUILD)/robots.txt: robots.txt
	cp robots.txt $(BUILD)/robots.txt

$(BUILD)/humans.txt: humans.txt
	cp humans.txt $(BUILD)/humans.txt

$(BUILD)/CNAME: CNAME
	cp CNAME $(BUILD)/CNAME

# ---- Badges (symlink into build) ----
$(BUILD)/badges:
	mkdir -p $(BUILD)
	ln -sf $(CURDIR)/badges $(BUILD)/badges

# ---- Font subsetting ----
subset-font:
	@CHARS=$$(find -L $(BUILD) -name '*.html' | xargs cat | sed 's/<[^>]*>//g' | tr '[:upper:]' '[:lower:]' | tr -d '\n' | grep -o . | sort -u | tr -d '\n') ; \
	pyftsubset fonts/ComicMono.ttf \
	  --text="$$CHARS" \
	  --output-file=fonts/ComicMono.woff2 \
	  --flavor=woff2 \
	  --no-hinting
	@echo "Done. New size: $$(wc -c < fonts/ComicMono.woff2) bytes"

clean:
	rm -rf $(BUILD) _stats.yaml

serve:
	python3 -m http.server 8080 --directory $(BUILD)
