# Ruby and GitHub maintenance plan

Goal: Follow the maintained sibling gems (tepra, pmlatex and scalebar), retain Ruby 2.5–2.7 compatibility, add Ruby 3.2–4.0 CI, and correct the English documentation.

Approach: Resolve released ActiveResource versions compatible with each Ruby, replace obsolete test dependencies as needed, and verify the existing API with isolated HTTP stubs. Reuse the siblings' tested package and release checks. Preserve the public API and bump the patch version to 1.5.4 as requested.

- [x] Reproduce dependency and runtime failures; update gemspec/Gemfile and test tooling; run the full suite on Ruby 4 and available legacy Ruby.
- [x] Fix runtime incompatibilities using failing regression tests; verify library and CLI behavior.
- [x] Add test/build/artifact CI and tag-gated GitHub Releases with package/version/checksum checks; remove the obsolete automatic package push.
- [x] Correct README, gem metadata and CLI English; document installation, configuration, testing and release procedures.
- [x] Run full tests, strict gem build, isolated installation verification and workflow/script checks; review the complete diff.

Review focus: undeclared runtime dependencies; actual installed package loading rather than source loading; accidental real HTTP requests during tests; legacy dependency resolution; release tag/version mismatch and duplicate versions.

Baseline: working tree clean on codex/fix-recursive-warnings-1.5.3 at 7e6d0a3. Ruby 4.0.9 is installed. `bundle exec rspec` cannot run because rspec is not installed. Gemfile.lock pins a 2021 development commit and stale gem version 0.2.0.

Validation: Ruby 4.0.9 and Ruby 2.6.10 each passed 144 examples and strict gem build plus isolated installed-library/CLI verification. Release preflight, simulated upload/download failures, checksum rejection and overwrite prevention are covered. Shell syntax and whitespace checks passed. The full GitHub matrix awaits a push/PR.

Decisions: FactoryBot 6.4.5 contains Ruby 2.7 argument-forwarding syntax despite its metadata, so the Gemfile selects 6.2.1 on Ruby < 2.7. FactoryBot 6.2 requires observer explicitly on Rubies that no longer bundle it. Runtime rails-observers and gli were unused and removed, as were unused legacy development/publishing gems. License metadata now matches the existing GPL-3.0-or-later LICENSE.txt (previous metadata incorrectly said MIT).

Final review: an independent read-only reviewer found no required fixes. Latest verification on Ruby 4.0.9 and 2.6.10: 144 examples, 0 failures, strict build and isolated package verification passed. The original CRLF convention is preserved; `git -c core.whitespace=cr-at-eol diff --check` passes. Gemfile.lock was removed after verification so CI resolves dependencies per Ruby. The user subsequently requested version 1.5.4 and a pull request. Both local Ruby versions passed the same 144 tests and package checks again for 1.5.4. Merge, tagging and publication remain separate steps.

Additional requested coverage: ten HTTP transport examples check Basic authentication, UTF-8 attributes, HTTP 401/404 propagation, escaped nested paths, and binary image POST/PUT with Japanese metadata. Four initially failed: multipart assembly mixed UTF-8 and binary strings, and Content-Length counted characters instead of bytes. Multipart assembly now preserves raw bytes and headers use bytesize. Full validation now covers 154 examples on each local Ruby.

Additional review caught that flattening array-valued fields drops separators for empty arrays. Two failing regression cases now cover empty and nested arrays; converting each field with Array#join before joining binary fields preserves the original serialization.
