package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

const (
	colorReset  = "\033[0m"
	colorBold   = "\033[1m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorBlue   = "\033[34m"
	colorCyan   = "\033[36m"
	colorGray   = "\033[90m"
)

type Config struct {
	RepoPath string
	Depth    int
	Color    bool
}

type DirInfo struct {
	Path     string
	Files    int
	SubDirs  int
	Size     int64
}

type RepoStats struct {
	Branches   []string
	Remotes    []string
	RecentLogs []string
	DirTree    []DirInfo
	FileTypes  map[string]int
	TotalFiles int
	TotalSize  int64
	TotalDirs  int
}

func main() {
	depth := flag.Int("depth", 3, "directory tree depth")
	format := flag.String("format", "color", "output format: color or plain")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: repo-topology [flags] [repo-path]\n\n")
		fmt.Fprintf(os.Stderr, "Analyze and visualize a git repository's topology.\n\n")
		fmt.Fprintf(os.Stderr, "Flags:\n")
		flag.PrintDefaults()
	}
	flag.Parse()

	repoPath := "."
	if flag.NArg() > 0 {
		repoPath = flag.Arg(0)
	}

	absPath, err := filepath.Abs(repoPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if !isGitRepo(absPath) {
		fmt.Fprintf(os.Stderr, "Error: %s is not a git repository\n", absPath)
		os.Exit(1)
	}

	cfg := Config{
		RepoPath: absPath,
		Depth:    *depth,
		Color:    *format == "color",
	}

	stats, err := analyzeRepo(cfg)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error analyzing repo: %v\n", err)
		os.Exit(1)
	}

	render(cfg, stats)
}

func isGitRepo(path string) bool {
	gitDir := filepath.Join(path, ".git")
	info, err := os.Stat(gitDir)
	if err != nil {
		return false
	}
	return info.IsDir() || info.Mode().IsRegular() // .git can be a file (worktree)
}

func gitCmd(repoPath string, args ...string) (string, error) {
	cmd := exec.Command("git", append([]string{"-C", repoPath}, args...)...)
	out, err := cmd.Output()
	return strings.TrimSpace(string(out)), err
}

func analyzeRepo(cfg Config) (RepoStats, error) {
	var stats RepoStats
	stats.FileTypes = make(map[string]int)

	// Branches
	if out, err := gitCmd(cfg.RepoPath, "branch", "--format=%(refname:short)"); err == nil && out != "" {
		stats.Branches = strings.Split(out, "\n")
	}

	// Remotes
	if out, err := gitCmd(cfg.RepoPath, "remote", "-v"); err == nil && out != "" {
		seen := map[string]bool{}
		for line := range strings.SplitSeq(out, "\n") {
			parts := strings.Fields(line)
			if len(parts) >= 2 && !seen[parts[0]] {
				seen[parts[0]] = true
				stats.Remotes = append(stats.Remotes, parts[0]+"\t"+parts[1])
			}
		}
	}

	// Recent commits
	if out, err := gitCmd(cfg.RepoPath, "log", "--oneline", "-10"); err == nil && out != "" {
		stats.RecentLogs = strings.Split(out, "\n")
	}

	// Walk directory tree
	err := walkDir(cfg.RepoPath, cfg.Depth, &stats)
	return stats, err
}

func walkDir(root string, maxDepth int, stats *RepoStats) error {
	dirFiles := map[string]int{}
	dirSubDirs := map[string]int{}
	dirSize := map[string]int64{}

	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil // skip errors
		}

		rel, _ := filepath.Rel(root, path)
		if rel == "." {
			return nil
		}

		// Skip .git directory
		if info.IsDir() && info.Name() == ".git" {
			return filepath.SkipDir
		}

		depth := strings.Count(rel, string(os.PathSeparator))

		if info.IsDir() {
			if depth >= maxDepth {
				return filepath.SkipDir
			}
			stats.TotalDirs++
			parent := filepath.Dir(rel)
			if parent == "." {
				parent = "."
			}
			dirSubDirs[parent]++
			return nil
		}

		// File
		stats.TotalFiles++
		stats.TotalSize += info.Size()

		ext := strings.ToLower(filepath.Ext(info.Name()))
		if ext == "" {
			ext = "(no ext)"
		}
		stats.FileTypes[ext]++

		// Count files per directory (up to maxDepth)
		dir := filepath.Dir(rel)
		if dir == "." {
			dir = "."
		}
		// Truncate to maxDepth
		parts := strings.Split(dir, string(os.PathSeparator))
		if len(parts) > maxDepth {
			dir = strings.Join(parts[:maxDepth], string(os.PathSeparator))
		}
		dirFiles[dir]++
		dirSize[dir] += info.Size()

		return nil
	})

	// Build DirTree sorted
	allDirs := map[string]bool{}
	for d := range dirFiles {
		allDirs[d] = true
	}
	for d := range dirSubDirs {
		allDirs[d] = true
	}

	for d := range allDirs {
		stats.DirTree = append(stats.DirTree, DirInfo{
			Path:    d,
			Files:   dirFiles[d],
			SubDirs: dirSubDirs[d],
			Size:    dirSize[d],
		})
	}
	sort.Slice(stats.DirTree, func(i, j int) bool {
		return stats.DirTree[i].Path < stats.DirTree[j].Path
	})

	return err
}

func render(cfg Config, stats RepoStats) {
	c := colorizer(cfg.Color)

	// Header
	fmt.Println(c(colorBold, "=== Repo Topology: "+filepath.Base(cfg.RepoPath)+" ==="))
	fmt.Println()

	// Branches & Remotes
	renderBranches(c, stats)
	renderRemotes(c, stats)
	renderRecentCommits(c, stats)
	renderDirTree(c, stats)
	renderFileTypes(c, stats)
	renderSizeStats(c, stats)
}

type colorFunc func(color, text string) string

func colorizer(enabled bool) colorFunc {
	if enabled {
		return func(color, text string) string {
			return color + text + colorReset
		}
	}
	return func(_, text string) string { return text }
}

func renderBranches(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "Branches") + c(colorGray, " ("+strconv.Itoa(len(stats.Branches))+")"))
	for _, b := range stats.Branches {
		fmt.Println("  " + c(colorGreen, b))
	}
	fmt.Println()
}

func renderRemotes(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "Remotes"))
	for _, r := range stats.Remotes {
		parts := strings.SplitN(r, "\t", 2)
		if len(parts) == 2 {
			fmt.Println("  " + c(colorYellow, parts[0]) + "  " + c(colorGray, parts[1]))
		}
	}
	fmt.Println()
}

func renderRecentCommits(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "Recent Commits"))
	for _, l := range stats.RecentLogs {
		parts := strings.SplitN(l, " ", 2)
		if len(parts) == 2 {
			fmt.Println("  " + c(colorYellow, parts[0]) + " " + parts[1])
		} else {
			fmt.Println("  " + l)
		}
	}
	fmt.Println()
}

func renderDirTree(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "Directory Tree"))

	type node struct {
		name     string
		files    int
		children []*node
	}

	root := &node{name: "."}
	nodeMap := map[string]*node{".": root}

	for _, d := range stats.DirTree {
		parts := strings.Split(d.Path, string(os.PathSeparator))
		current := "."
		for i, p := range parts {
			if current == "." && i == 0 && p == "." {
				nodeMap["."].files = d.Files
				continue
			}
			var fullPath string
			if current == "." {
				fullPath = p
			} else {
				fullPath = current + string(os.PathSeparator) + p
			}

			if _, exists := nodeMap[fullPath]; !exists {
				n := &node{name: p}
				nodeMap[fullPath] = n
				parent := nodeMap[current]
				if parent != nil {
					parent.children = append(parent.children, n)
				}
			}
			if i == len(parts)-1 {
				nodeMap[fullPath].files = d.Files
			}
			current = fullPath
		}
	}

	// Render tree
	var printTree func(n *node, prefix string, isLast bool)
	printTree = func(n *node, prefix string, isLast bool) {
		connector := "├── "
		if isLast {
			connector = "└── "
		}
		fileInfo := ""
		if n.files > 0 {
			fileInfo = c(colorGray, " ("+strconv.Itoa(n.files)+" files)")
		}
		if n == root {
			fmt.Println("  " + c(colorBlue, ".") + fileInfo)
		} else {
			fmt.Println("  " + prefix + connector + c(colorBlue, n.name) + fileInfo)
		}

		childPrefix := prefix
		if n != root {
			if isLast {
				childPrefix += "    "
			} else {
				childPrefix += "│   "
			}
		}

		sort.Slice(n.children, func(i, j int) bool {
			return n.children[i].name < n.children[j].name
		})

		for i, child := range n.children {
			printTree(child, childPrefix, i == len(n.children)-1)
		}
	}
	printTree(root, "", true)
	fmt.Println()
}

func renderFileTypes(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "File Types"))

	type extCount struct {
		ext   string
		count int
	}
	var sorted []extCount
	for ext, count := range stats.FileTypes {
		sorted = append(sorted, extCount{ext, count})
	}
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].count > sorted[j].count
	})

	maxCount := 0
	if len(sorted) > 0 {
		maxCount = sorted[0].count
	}
	barWidth := 30

	shown := 0
	for _, ec := range sorted {
		if shown >= 15 {
			break
		}
		width := (ec.count * barWidth) / maxCount
		width = max(width, 1)
		bar := strings.Repeat("█", width)
		fmt.Printf("  %-12s %s %s\n",
			c(colorYellow, ec.ext),
			c(colorGreen, bar),
			c(colorGray, strconv.Itoa(ec.count)))
		shown++
	}
	if len(sorted) > 15 {
		fmt.Printf("  %s\n", c(colorGray, "... and "+strconv.Itoa(len(sorted)-15)+" more"))
	}
	fmt.Println()
}

func renderSizeStats(c colorFunc, stats RepoStats) {
	fmt.Println(c(colorCyan, "Summary"))
	fmt.Printf("  Total files:       %s\n", c(colorBold, strconv.Itoa(stats.TotalFiles)))
	fmt.Printf("  Total directories: %s\n", c(colorBold, strconv.Itoa(stats.TotalDirs)))
	fmt.Printf("  Total size:        %s\n", c(colorBold, formatSize(stats.TotalSize)))
	fmt.Printf("  File types:        %s\n", c(colorBold, strconv.Itoa(len(stats.FileTypes))))
	fmt.Printf("  Branches:          %s\n", c(colorBold, strconv.Itoa(len(stats.Branches))))
	fmt.Println()
}

func formatSize(bytes int64) string {
	const (
		KB = 1024
		MB = KB * 1024
		GB = MB * 1024
	)
	switch {
	case bytes >= GB:
		return fmt.Sprintf("%.1f GB", float64(bytes)/float64(GB))
	case bytes >= MB:
		return fmt.Sprintf("%.1f MB", float64(bytes)/float64(MB))
	case bytes >= KB:
		return fmt.Sprintf("%.1f KB", float64(bytes)/float64(KB))
	default:
		return fmt.Sprintf("%d B", bytes)
	}
}
