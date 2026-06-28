# Security Policy

## Supported versions

`cli-setup` is in early development. Until a `1.0.0` release, only the latest
commit on the default branch is supported. Security fixes are applied there.

## Reporting a vulnerability

Please **do not** open a public issue for security vulnerabilities.

Report privately using one of:

- GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
  ("Report a vulnerability" under the repository's **Security** tab), or
- Email **email.iisrael@gmail.com** with a description and reproduction steps.

Please include:

- A description of the vulnerability and its impact.
- Steps to reproduce or a proof of concept.
- Affected version / commit and your environment (macOS version, architecture).

## What to expect

- Acknowledgement of your report within **5 business days**.
- An assessment and, where applicable, a fix or mitigation plan.
- Credit for the disclosure if you would like it, once a fix is released.

## Scope notes

Because `cli-setup` installs developer tooling and edits a managed block in your
`~/.zshrc`, reports about untrusted input (e.g. a malicious **team config** URL),
checksum/verification gaps in vendored binaries (`gum`, `jq`), or shell injection
are especially welcome.
