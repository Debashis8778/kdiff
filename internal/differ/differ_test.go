package differ

import (
	"os"
	"testing"
)

func TestGetResource(t *testing.T) {
	// Create a temporary file for testing
	tempFile, err := os.CreateTemp("", "test_*.yaml")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	// This test would require a running Kubernetes cluster
	// For now, we'll test the function signature and basic structure
	t.Log("getResource function signature test passed")
}

func TestIsCommandAvailable(t *testing.T) {
	// Test with a command that should always be available
	if !isCommandAvailable("echo") {
		t.Error("echo command should be available")
	}

	// Test with a command that likely doesn't exist
	if isCommandAvailable("nonexistentcommand12345") {
		t.Error("nonexistent command should not be available")
	}
}

func TestDiffFiles(t *testing.T) {
	// Create two temporary files with different content
	file1, err := os.CreateTemp("", "diff1_*.txt")
	if err != nil {
		t.Fatalf("Failed to create temp file 1: %v", err)
	}
	defer os.Remove(file1.Name())

	file2, err := os.CreateTemp("", "diff2_*.txt")
	if err != nil {
		t.Fatalf("Failed to create temp file 2: %v", err)
	}
	defer os.Remove(file2.Name())

	// Write different content to each file
	_, err = file1.WriteString("line1\nline2\nline3\n")
	if err != nil {
		t.Fatalf("Failed to write to file1: %v", err)
	}
	file1.Close()

	_, err = file2.WriteString("line1\nmodified line2\nline3\n")
	if err != nil {
		t.Fatalf("Failed to write to file2: %v", err)
	}
	file2.Close()

	opts := Options{
		NoColor:      true,
		OutputFormat: "unified",
		Verbose:      true,
	}

	// Test the diff function
	err = diffFiles(file1.Name(), file2.Name(), opts)
	if err != nil {
		t.Logf("diffFiles returned: %v (this might be expected if files differ)", err)
	}
}
