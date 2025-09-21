# Signing Setup

This project intentionally ships without real signing material. To build or publish your own HAP you *must* provide personal certificates locally.

## Steps

1. Copy `build-profile.json5` to `build-profile.local.json5` and fill in the absolute paths and passwords to your own certificates, OR reuse the prepared `build-profile.local.json5` kept on your machine.
2. Keep `build-profile.local.json5` outside of version control (it's already listed in `.gitignore`).
3. Before running a build, either:
   - overwrite `build-profile.json5` with your local values, or
   - maintain a script that swaps the files as part of your build pipeline.

