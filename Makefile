.POSIX:
.PHONY: all
all: main.pdf
main.pdf: main.md frontmatter.md
	pandoc \
		frontmatter.md main.md \
		-o main.pdf \
		--data-dir=. \
		--template=eisvogel.latex \
		--pdf-engine=xelatex \
		--listings \
		--to beamer \
		--slide-level=2 \
		--lua-filter=./filters/image-size.lua
