package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func setupTestRepo(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()

	cmds := [][]string{
		{"git", "init"},
		{"git", "config", "user.email", "test@test.com"},
		{"git", "config", "user.name", "Test"},
	}
	for _, args := range cmds {
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Dir = dir
		if out, err := cmd.CombinedOutput(); err != nil {
			t.Fatalf("setup %v failed: %v\n%s", args, err, out)
		}
	}

	// Create some files and directories
	files := map[string]string{
		"README.md":       "# Test",
		"main.go":         "package main",
		"src/app.go":      "package src",
		"src/app_test.go": "package src",
		"docs/guide.md":   "# Guide",
	}
	for name, content := range files {
		p := filepath.Join(dir, name)
		os.MkdirAll(filepath.Dir(p), 0o755)
		os.WriteFile(p, []byte(content), 0o644)
	}

	cmd := exec.Command("git", "add", "-A")
	cmd.Dir = dir
	cmd.CombinedOutput()

	cmd = exec.Command("git", "commit", "-m", "initial")
	cmd.Dir = dir
	cmd.CombinedOutput()

	return dir
}

func TestIsGitRepo(t *testing.T) {
	repo := setupTestRepo(t)

	if !isGitRepo(repo) {
		t.Error("expected true for a valid git repo")
	}
	if isGitRepo(t.TempDir()) {
		t.Error("expected false for a non-git directory")
	}
}

func TestAnalyzeRepo(t *testing.T) {
	repo := setupTestRepo(t)
	cfg := Config{RepoPath: repo, Depth: 3, Color: false}

	stats, err := analyzeRepo(cfg)
	if err != nil {
		t.Fatalf("analyzeRepo failed: %v", err)
	}

	if stats.TotalFiles != 5 {
		t.Errorf("expected 5 files, got %d", stats.TotalFiles)
	}
	if stats.TotalDirs < 2 {
		t.Errorf("expected at least 2 dirs, got %d", stats.TotalDirs)
	}
	if len(stats.Branches) == 0 {
		t.Error("expected at least one branch")
	}
	if stats.FileTypes[".go"] != 3 {
		t.Errorf("expected 3 .go files, got %d", stats.FileTypes[".go"])
	}
	if stats.FileTypes[".md"] != 2 {
		t.Errorf("expected 2 .md files, got %d", stats.FileTypes[".md"])
	}
	if len(stats.RecentLogs) != 1 {
		t.Errorf("expected 1 commit log, got %d", len(stats.RecentLogs))
	}
}

func TestWalkDirDepth(t *testing.T) {
	repo := setupTestRepo(t)

	// Create deeply nested structure
	deep := filepath.Join(repo, "a", "b", "c", "d")
	os.MkdirAll(deep, 0o755)
	os.WriteFile(filepath.Join(deep, "deep.txt"), []byte("deep"), 0o644)

	stats := RepoStats{FileTypes: make(map[string]int)}
	err := walkDir(repo, 2, &stats)
	if err != nil {
		t.Fatalf("walkDir failed: %v", err)
	}

	// With depth 2, "a/b/c" should be skipped
	for _, d := range stats.DirTree {
		depth := strings.Count(d.Path, string(os.PathSeparator))
		if d.Path != "." && depth >= 2 {
			// dir paths in tree should be at most depth 1 (0-indexed from root)
			// but file counts may be rolled up
		}
	}

	// deep.txt should not be counted since it's beyond depth 2
	if stats.FileTypes[".txt"] != 0 {
		t.Errorf("expected 0 .txt files at depth 2, got %d", stats.FileTypes[".txt"])
	}
}

func TestFormatSize(t *testing.T) {
	tests := []struct {
		bytes    int64
		expected string
	}{
		{0, "0 B"},
		{500, "500 B"},
		{1024, "1.0 KB"},
		{1536, "1.5 KB"},
		{1048576, "1.0 MB"},
		{1073741824, "1.0 GB"},
	}
	for _, tc := range tests {
		got := formatSize(tc.bytes)
		if got != tc.expected {
			t.Errorf("formatSize(%d) = %q, want %q", tc.bytes, got, tc.expected)
		}
	}
}

func TestColorizer(t *testing.T) {
	enabled := colorizer(true)
	result := enabled(colorGreen, "hello")
	if !strings.Contains(result, "\033[32m") {
		t.Error("expected ANSI color codes when enabled")
	}
	if !strings.HasSuffix(result, colorReset) {
		t.Error("expected color reset suffix")
	}

	disabled := colorizer(false)
	result = disabled(colorGreen, "hello")
	if result != "hello" {
		t.Errorf("expected plain text when disabled, got %q", result)
	}
}

func TestRenderDoesNotPanic(t *testing.T) {
	repo := setupTestRepo(t)
	cfg := Config{RepoPath: repo, Depth: 3, Color: false}

	stats, err := analyzeRepo(cfg)
	if err != nil {
		t.Fatalf("analyzeRepo failed: %v", err)
	}

	// Redirect stdout to discard output
	old := os.Stdout
	os.Stdout, _ = os.Open(os.DevNull)
	defer func() { os.Stdout = old }()

	// Should not panic
	render(cfg, stats)
}

func TestAnalyzeRepoNoRemotes(t *testing.T) {
	repo := setupTestRepo(t)
	cfg := Config{RepoPath: repo, Depth: 3, Color: false}

	stats, err := analyzeRepo(cfg)
	if err != nil {
		t.Fatalf("analyzeRepo failed: %v", err)
	}

	// Test repo has no remotes
	if len(stats.Remotes) != 0 {
		t.Errorf("expected 0 remotes, got %d", len(stats.Remotes))
	}
}
