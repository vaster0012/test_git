# Applying the fix bundle

From a local clone of `vaster0012/test_git`, copy the bundle contents over the repository root, then review and commit:

```bash
cp -a /path/to/test_git_fix_bundle/. /path/to/test_git/
cd /path/to/test_git
bash -n setup_enviroment.sh
bash -n Test_scrp1/stableinst.sh
git diff --check
git diff
git add README.md packages.txt setup_enviroment.sh Test_scrp1/stableinst.sh .github/workflows/shellcheck.yml
git commit -m "Fix bootstrap installer"
git push
```

Recommended: push to a feature branch and open a pull request rather than committing directly to `main`.
