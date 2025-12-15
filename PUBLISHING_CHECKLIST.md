# Publishing Checklist for fsrs_ruby

## ✅ Files Created/Updated

### Essential Files
- ✅ `fsrs_ruby.gemspec` - Updated with your credentials
- ✅ `CODE_OF_CONDUCT.md` - Contributor Covenant
- ✅ `CONTRIBUTING.md` - Contribution guidelines
- ✅ `README.md` - Updated with credits and verification info
- ✅ `.github/workflows/ci.yml` - GitHub Actions CI/CD
- ✅ `.rubocop.yml` - Code style configuration
- ✅ `Gemfile` - Added RuboCop gems

### Existing Files (Already Good)
- ✅ `LICENSE` - MIT License
- ✅ `CHANGELOG.md` - Version history
- ✅ `VERIFICATION_REPORT.md` - Testing documentation
- ✅ `TESTING.md` - Test guide
- ✅ `.gitignore` - Ignore patterns

## 📋 Pre-Publishing Steps

### 1. Install Dependencies
```bash
bundle install
```

### 2. Run All Tests
```bash
bundle exec rspec
# Should show: 69 examples, 0 failures
```

### 3. Check Code Style (Optional)
```bash
bundle exec rubocop
# Fix any critical issues
```

### 4. Build Gem Locally
```bash
gem build fsrs_ruby.gemspec
# Creates: fsrs_ruby-1.0.0.gem
```

### 5. Test Gem Installation
```bash
gem install ./fsrs_ruby-1.0.0.gem
irb -r fsrs_ruby
```

Test in IRB:
```ruby
fsrs = FsrsRuby.new
card = FsrsRuby.create_empty_card(Time.now)
result = fsrs.next(card, Time.now, FsrsRuby::Rating::GOOD)
puts result.card.scheduled_days
```

### 6. Create GitHub Repository
1. Go to https://github.com/new
2. Name: `fsrs_ruby`
3. Description: "Ruby implementation of FSRS v6.0 spaced repetition algorithm"
4. Public repository
5. Don't initialize with README (you already have one)

### 7. Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit - FSRS Ruby v1.0.0"
git branch -M main
git remote add origin https://github.com/ondrejrohon/fsrs_ruby.git
git push -u origin main
```

### 8. Create Git Tag
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 9. Sign Up for RubyGems.org
1. Visit: https://rubygems.org/sign_up
2. Use: ondrej.rohon@gmail.com
3. Verify email

### 10. Enable 2FA (REQUIRED)
1. Visit: https://rubygems.org/settings/edit
2. Enable Two-Factor Authentication
3. Save recovery codes

### 11. Publish to RubyGems.org
```bash
gem push fsrs_ruby-1.0.0.gem
```

You'll be prompted for credentials. After publishing, your gem will be available at:
https://rubygems.org/gems/fsrs_ruby

### 12. Verify Publication
```bash
gem search fsrs_ruby
gem install fsrs_ruby
```

## 🎉 Post-Publishing

### Update README Badges (Optional)
Add to top of README.md:

```markdown
[![Gem Version](https://badge.fury.io/rb/fsrs_ruby.svg)](https://badge.fury.io/rb/fsrs_ruby)
[![CI Status](https://github.com/ondrejrohon/fsrs_ruby/workflows/CI/badge.svg)](https://github.com/ondrejrohon/fsrs_ruby/actions)
[![Code Coverage](https://codecov.io/gh/ondrejrohon/fsrs_ruby/branch/main/graph/badge.svg)](https://codecov.io/gh/ondrejrohon/fsrs_ruby)
```

### Announce Your Gem
- Reddit: r/ruby
- Twitter/X: #ruby #opensource
- Dev.to: Write an article
- Ruby Weekly: Submit to newsletter

## 🔧 Future Maintenance

### For Updates
1. Make changes
2. Update CHANGELOG.md
3. Bump version in `lib/fsrs_ruby/version.rb`
4. Commit and tag
5. Build and push new gem version

### Version Bumping
- **Patch** (1.0.0 → 1.0.1): Bug fixes
- **Minor** (1.0.0 → 1.1.0): New features (backward compatible)
- **Major** (1.0.0 → 2.0.0): Breaking changes

## ⚠️ Important Notes

- Your email (ondrej.rohon@gmail.com) will be publicly visible
- RubyGems.org now requires 2FA for all gem owners
- Keep your recovery codes safe
- You can add co-owners later if needed
- Monitor GitHub issues and respond to bug reports

## 📞 Help

If you encounter issues:
- RubyGems help: https://guides.rubygems.org/
- GitHub Actions: https://docs.github.com/en/actions
- Ruby community: https://www.ruby-lang.org/en/community/

Good luck! 🚀
