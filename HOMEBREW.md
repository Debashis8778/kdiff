# Setting up Homebrew Tap (Optional)

To enable `brew install kdiff`, you need to create a Homebrew tap repository:

## Steps:

1. **Create a new repository** named `homebrew-tap` on GitHub under your account
   - Repository: `https://github.com/rajamohan-rj/homebrew-tap`

2. **Initialize the repository**:
   ```bash
   git clone https://github.com/rajamohan-rj/homebrew-tap.git
   cd homebrew-tap
   mkdir Formula
   echo "# Homebrew Tap for kdiff" > README.md
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

3. **GoReleaser will automatically**:
   - Create Formula/kdiff.rb on each release
   - Update the formula with new versions
   - Handle dependencies and checksums

4. **Users can then install via**:
   ```bash
   brew tap rajamohan-rj/tap
   brew install kdiff
   ```

## Note:
The Homebrew tap is configured in `.goreleaser.yaml` and will be automatically maintained by the release process.
