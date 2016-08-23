Dir.glob("**/.sync/.last_build").each(&File.method(:delete))
warn "sync_clean done"
