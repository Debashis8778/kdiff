package differ

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"
)

type Options struct {
	Namespace1   string
	Resource1    string
	Namespace2   string
	Resource2    string
	NoColor      bool
	NoNeat       bool
	OutputFormat string
	Verbose      bool
}

func Run(opts Options) error {
	// Create temporary files for the YAML outputs
	tempFile1, err := ioutil.TempFile("", "kdiff_a_*.yaml")
	if err != nil {
		return fmt.Errorf("failed to create temporary file: %w", err)
	}
	defer os.Remove(tempFile1.Name())
	defer tempFile1.Close()

	tempFile2, err := ioutil.TempFile("", "kdiff_b_*.yaml")
	if err != nil {
		return fmt.Errorf("failed to create temporary file: %w", err)
	}
	defer os.Remove(tempFile2.Name())
	defer tempFile2.Close()

	// Get first resource
	if err := getResource(opts.Namespace1, opts.Resource1, tempFile1.Name(), opts); err != nil {
		return fmt.Errorf("failed to get resource %s from namespace %s: %w", opts.Resource1, opts.Namespace1, err)
	}

	// Get second resource
	if err := getResource(opts.Namespace2, opts.Resource2, tempFile2.Name(), opts); err != nil {
		return fmt.Errorf("failed to get resource %s from namespace %s: %w", opts.Resource2, opts.Namespace2, err)
	}

	// Perform diff
	return diffFiles(tempFile1.Name(), tempFile2.Name(), opts)
}

func getResource(namespace, resource, outputFile string, opts Options) error {
	log(opts, "Getting resource %s from namespace %s", resource, namespace)

	// Execute kubectl get command
	cmd := exec.Command("kubectl", "get", resource, "-n", namespace, "-o", "yaml")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("kubectl get failed: %w", err)
	}

	var finalOutput []byte
	if !opts.NoNeat {
		// Pipe through kubectl neat
		neatCmd := exec.Command("kubectl", "neat")
		neatCmd.Stdin = strings.NewReader(string(output))
		finalOutput, err = neatCmd.Output()
		if err != nil {
			log(opts, "kubectl neat failed, using raw output: %v", err)
			finalOutput = output
		}
	} else {
		finalOutput = output
	}

	// Write to temporary file
	return ioutil.WriteFile(outputFile, finalOutput, 0644)
}

func diffFiles(file1, file2 string, opts Options) error {
	var diffCmd *exec.Cmd

	switch opts.OutputFormat {
	case "context":
		diffCmd = exec.Command("diff", "-c", file1, file2)
	case "side-by-side":
		diffCmd = exec.Command("diff", "-y", file1, file2)
	default: // unified
		diffCmd = exec.Command("diff", "-u", file1, file2)
	}

	// If color is enabled and colordiff is available, pipe through colordiff
	if !opts.NoColor && isCommandAvailable("colordiff") {
		diffOutput, err := diffCmd.Output()
		if err != nil {
			// diff returns non-zero exit code when files differ, which is expected
			if exitError, ok := err.(*exec.ExitError); ok {
				diffOutput = exitError.Stderr
				// Get stdout as well
				if stdout, stdoutErr := diffCmd.Output(); stdoutErr == nil {
					diffOutput = stdout
				}
			}
		}

		colorCmd := exec.Command("colordiff")
		colorCmd.Stdin = strings.NewReader(string(diffOutput))
		colorCmd.Stdout = os.Stdout
		colorCmd.Stderr = os.Stderr
		return colorCmd.Run()
	} else {
		// Direct output without colordiff
		diffCmd.Stdout = os.Stdout
		diffCmd.Stderr = os.Stderr
		err := diffCmd.Run()
		// diff returns exit code 1 when files differ, which is normal
		if err != nil {
			if exitError, ok := err.(*exec.ExitError); ok && exitError.ExitCode() == 1 {
				return nil // Files differ, which is expected
			}
			return err
		}
		return nil
	}
}

func isCommandAvailable(command string) bool {
	_, err := exec.LookPath(command)
	return err == nil
}

func log(opts Options, fmtStr string, a ...any) {
	if opts.Verbose {
		fmt.Printf(fmtStr+"\n", a...)
	}
}

// ReadUserInput reads a line of input from the user
func ReadUserInput(prompt string) (string, error) {
	fmt.Print(prompt)
	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(input), nil
}
