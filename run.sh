#! /bin/bash

bundle update --all && \
bundle exec jekyll serve --drafts --watch --config _config.yml --host 0.0.0.0
