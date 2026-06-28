# Generic core with profiles; `mobile` is the first profile

The core is environment-agnostic; concrete environments are expressed as profiles, and `mobile` (React Native bare, iOS + Android) is the first one. We chose a generic core — rather than hard-coding a React Native setup — so cli-setup can grow to other environments (web, backend, other frameworks) without reworking the engine.

## Consequences

- Framework selection within `mobile` (react-native vs flutter) and composable profiles (one profile extending another) are deliberately deferred to a later milestone.
- The first profile still has to prove the model end-to-end, so `mobile` carries the full RN bare toolset for now.
